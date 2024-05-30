local Entity = require('entities.entity')

local Player = Class {
    state = '',
    direction = 1,
    can_switch_state = true,
    
    is_jump_registered = false,
    jump_timer = TIMER,
    is_grounded_registered = false,
    ground_timer = TIMER,

    can_dash = true,
    is_dashing = false,
    dashes = 0,

    air_jumps = 0,
}

local const = {
    run_speed = 260,
    accel = 5,
    decel = 5,
    friction = 2.1,

    turn_threshold = 30,

    jump_force = -490,
    jump_halt_power = 0.7,

    jump_buffer = 0.03,
    ground_buffer = 0.05,

    dash_time = 0.2,
    dash_speed = 400,
    dash_cooldown = 0.25,
    max_dashes = 1,

    max_air_jumps = 1,
    air_jump_velocity = -440,

    sprite_scale = 1,
    sprite_sheet = love.graphics.newImage('entities/player/animations/Colour2/Outline/SpriteSheet.png'),
    frame_width = 120, frame_height = 80,
    sprite_width = 20, sprite_height = 38,
    width = 12, height = 28,

    animations = {
        idle = { frames = 10, row = 17, durations = {['1-4']=0.1, ['4-4'] = 0.5, ['5-10'] = 0.15} },
        run = { frames = 10, row = 21, durations = 0.1 },
        turn = { frames = 3, row = 26, durations = 0.07, onLoop = 'pauseAtEnd', flipped = true, position = 3 },
        jump = { frames = 3, row = 18, durations = 0.1 },
        fall = { frames = 3, row = 15, durations = 0.1 },
        dash = { frames = 2, row = 12, durations = 0.1 },
    },
}

function loadAnimations()
    const.ox = const.frame_width / 2 - const.sprite_width / 2
    const.oy = const.frame_height - const.height / 2 - 1

    local sheet_width, sheet_height = const.sprite_sheet:getDimensions()
    local grid = anim8.newGrid(const.frame_width, const.frame_height, sheet_width, sheet_height)

    for name, data in pairs(const.animations) do
        const.animations[name] = anim8.newAnimation(grid('1-' .. data.frames, data.row), data.durations, data.onLoop)
        if data.flipped then
            const.animations[name]:flipH()
        end
        const.animations[name].position = data.position or 1
    end
end

loadAnimations()

local run
local jump
local groundState
local switchState
local setDirection
local dash

function Player:init(x, y)
    local height = const.height * const.sprite_scale
    Entity.init(self, x, y - height, const.width * const.sprite_scale, height)

    self.collider:setMass(1)

    self.animation = const.animations.idle
end

function Player:update(dt)
    timer.script(function (wait)
        dash(self, wait)
    end)
    
    groundState(self)
    switchState(self)
    self.animation:update(dt)

    if self.is_dashing then
        return
    end

    if self.is_grounded then
        self.dashes = 0
        self.air_jumps = 0
    end

    setDirection(self)

    run(self)
    jump(self)
end

function Player:getInputX()
    local ix = 0

    if input('right') then
        ix = ix + 1
    end

    if input('left') then
        ix = ix - 1
    end

    return ix
end

function dash(self, wait)
    if self.can_dash and input("dash") and self.dashes < const.max_dashes then
        self.is_dashing = true
        self.can_dash = false
        self.dashes = self.dashes + 1
    
        local g = self.collider:getGravityScale()
        self.collider:setGravityScale(0)
    
        self.collider:setLinearVelocity(0, 0)
        self.collider:applyLinearImpulse(self.direction * const.dash_speed, 0)
    
        wait(const.dash_time)
    
        self.collider:setGravityScale(g)
    
        self.is_dashing = false

        wait(const.dash_cooldown)

        self.can_dash = true
    end
end

function run(self)
    local vx, _ = self.collider:getLinearVelocity()
    local ix = self:getInputX()
    local rate_of_change = ix ~= 0 and const.accel or const.decel
    local force = rate_of_change * (const.run_speed * ix - vx)
    
    self.collider:applyForce(force, 0)

    self.collider:applyForce(force * const.friction, 0)
end

function jump(self)
    if input("jump") then
        self.is_jump_registered = true

        timer.after(const.jump_buffer, function ()
            self.is_jump_registered = false
        end)
    end

    if self.is_jump_registered and self.is_grounded_registered then
        self.is_jump_registered, self.is_grounded_registered = false, false

        local vx, _ = self.collider:getLinearVelocity()
        self.collider:setLinearVelocity(vx, 0)

        if self.is_grounded then
            self.collider:applyLinearImpulse(0, const.jump_force)
        end
    end
    
    if not self.is_grounded and input("jump") and self.air_jumps < const.max_air_jumps then
        local vx, _ = self.collider:getLinearVelocity()
        self.collider:setLinearVelocity(vx, 0)
        self.collider:applyLinearImpulse(0, const.air_jump_velocity)
        self.air_jumps = self.air_jumps + 1
    end

    if input("jump", "isReleased") then
        local _, vy = self.collider:getLinearVelocity()
        self.collider:applyLinearImpulse(0, -vy * const.jump_halt_power)
    end
end

function groundState(self)
    local width, height = self.width, 1
    local x, y = self.collider:getX() - width / 2, self.collider:getY() + self.height / 2
    self.is_grounded = #world:queryRectangleArea(x, y, width, height, {'wall'}) > 0

    if self.is_grounded then
        self.is_grounded_registered = true

        timer.cancel(self.ground_timer)

        self.ground_timer = timer.after(const.ground_buffer, function ()
            self.is_grounded_registered = false
        end)
    end
end

function switchState(self)
    if not self.can_switch_state then
        return
    end

    local last = self.state
    local ix = self:getInputX()
    local vx, vy = self.collider:getLinearVelocity()

    if self.is_grounded then
        self.state = 'idle'
        self.can_switch_state = true

        if ix ~= 0 then
            self.state = 'run'
            self.can_switch_state = true

            if ix == -math.sign(vx) and math.abs(vx) > const.turn_threshold then
                self.can_switch_state = false
                self.state = 'turn'

                timer.after(const.animations.turn.totalDuration, function ()
                    self.can_switch_state = true
                end)
            end
        end
    end

    if not self.is_grounded then
        self.state = 'jump'
        self.can_switch_state = true            

        if vy > 0 then
            self.can_switch_state = true
            self.state = 'fall'
        end
    end

    if self.is_dashing then
        self.state = 'dash'
    end

    if self.state ~= last then
        self.animation = const.animations[self.state]:clone()
    end
end

function setDirection(self)
    if input("right") and not input("left") then
        self.direction = 1
    end
    
    if not input("right") and input("left") then
        self.direction = -1
    end
end

function Player:draw()
    local x, y = self.collider:getPosition()
    local sprite_scale = self.direction * const.sprite_scale

    self.animation:draw(const.sprite_sheet, x, y, nil, sprite_scale, const.sprite_scale, const.ox, const.oy)
end

return Player