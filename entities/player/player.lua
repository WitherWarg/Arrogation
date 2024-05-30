--#region constant variables
local const = {}
    const.run_speed = 260
    const.accel = 5
    const.decel = 5
    const.friction = 2.1

    const.max_fall_speed = 1500

    const.turn_threshold = 30

    const.jump_force = -490
    const.jump_halt_power = 0.7

    const.jump_buffer = 0.03
    const.ground_buffer = 0.05

    const.dash_time = 0.2
    const.dash_speed = 400
    const.dash_cooldown = 0.25
    const.max_dashes = 1

    const.max_air_jumps = 1
    const.air_jump_velocity = -440

    const.wall_jump_force = vector(175, -520)
    const.wall_slide_speed = 12
    const.wall_buffer = 0.07

    const.sprite_scale = 1
    const.sprite_sheet = love.graphics.newImage('entities/player/animations/Colour2/Outline/SpriteSheet.png')
    const.frame_width, const.frame_height = 120, 80
    const.sprite_width, const.sprite_height = 20, 38
    const.width, const.height = 12, 28
    const.ox = const.frame_width / 2 - const.width / 2
    const.oy = const.frame_height - const.height / 2 - 1
--#endregion

--#region load animations
const.animations = {
    idle = { frames = 10, row = 17, durations = {['1-4']=0.1, ['4-4'] = 0.5, ['5-10'] = 0.15} },
    run = { frames = 10, row = 21, durations = 0.1 },
    turn = { frames = 3, row = 26, durations = 0.07, onLoop = 'pauseAtEnd', is_flipped = true },
    jump = { frames = 3, row = 18, durations = 0.1 },
    fall = { frames = 3, row = 15, durations = 0.1 },
    dash = { frames = 2, row = 12, durations = 0.1 },
    wall_slide = { frames = 3, row = 30, durations = 0.1 },
}

local sheet_width, sheet_height = const.sprite_sheet:getDimensions()
local grid = anim8.newGrid(const.frame_width, const.frame_height, sheet_width, sheet_height)

for name, data in pairs(const.animations) do
    const.animations[name] = anim8.newAnimation(grid('1-' .. data.frames, data.row), data.durations, data.onLoop)
    const.animations[name].is_flipped = data.is_flipped or false
end
--#endregion

--#region functions
local run
local jump
local wallSlide
local groundState
local wallState
local switchState
local setDirection
local dash
local fallDamp
--#endregion

local Player = Class {
    state = '',
    can_switch_state = true,

    direction = 1,
    
    is_jump_buffered = false,
    jump_timer = TIMER,

    is_grounded = false,
    is_grounded_buffered = false,
    ground_timer = TIMER,

    is_walled = false,
    is_walled_buffered = false,
    wall_timer = TIMER,
    has_wall_jump_item = true,

    can_dash = true,
    is_dashing = false,
    dashes = 0,
    has_dash_item = true,

    air_jumps = 0,
    has_air_jump_item = false,
}

function Player:init(object)
    object.width, object.height = const.width * const.sprite_scale, const.height * const.sprite_scale
    object.y = object.y - object.height

    local Entity = require('entities.entity')
    Entity.init(self, object)
    
    self.collider:setMass(1)

    self.animation = const.animations.idle
end

function Player:update(dt)
    timer.script(function (wait)
        dash(self, wait)
    end)
    
    groundState(self)
    wallState(self)
    switchState(self)
    self.animation:update(dt)

    if self.is_dashing then
        return
    end

    if self.is_grounded or self.is_walled then
        self.dashes = 0
        self.air_jumps = 0
    end

    setDirection(self)

    run(self)
    jump(self)
    wallSlide(self)
    fallDamp(self)
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

function Player:getNormal(collision_class)
    assert(collision_class ~= nil, 'Collision class must exist.')

    local nx, ny = 0, 0
    local data_list = {}

    self.collider:enter(collision_class)
    self.collider:exit(collision_class)
    if self.collider:stay(collision_class) then
        data_list = self.collider:getStayCollisionData(collision_class)
    end

    for i, data in ipairs(data_list) do
        if data.contact:isDestroyed() then
            table.remove(data_list, i)
        else
            local x, y = data.contact:getNormal()

            if x ~= 0 then nx = x end
            if y ~= 0 then ny = y end
        end
    end

    return nx, ny
end

--#region physics
function dash(self, wait)
    if self.can_dash and input("dash") and self.dashes < const.max_dashes and self.has_dash_item then
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
        self.is_jump_buffered = true

        timer.after(const.jump_buffer, function ()
            self.is_jump_buffered = false
        end)
    end

    local can_air_jump = self.air_jumps < const.max_air_jumps and self.has_air_jump_item

    if self.is_jump_buffered and (self.is_grounded_buffered or can_air_jump or self.is_walled_buffered) then
        self.is_jump_buffered = false
        timer.cancel(self.jump_timer)

        local vx, _ = self.collider:getLinearVelocity()
        self.collider:setLinearVelocity(vx, 0)

        if self.is_grounded_buffered then
            self.is_grounded_buffered = false
            timer.cancel(self.ground_timer)

            self.collider:applyLinearImpulse(0, const.jump_force)
        elseif self.is_walled_buffered then
            self.is_walled_buffered = false
            timer.cancel(self.wall_timer)

            local nx, _ = self:getNormal('wall')
            self.collider:applyLinearImpulse(const.wall_jump_force.x * -nx, const.wall_jump_force.y)
        elseif (not self.is_grounded and not self.is_walled) and self.air_jumps < const.max_air_jumps then
            self.collider:applyLinearImpulse(0, const.air_jump_velocity)
            self.air_jumps = self.air_jumps + 1
        end
    end

    if input("jump", "isReleased") then
        local _, vy = self.collider:getLinearVelocity()
        self.collider:applyLinearImpulse(0, -vy * const.jump_halt_power)
    end
end

function wallSlide(self)
    if self.is_walled then
        local vx, vy = self.collider:getLinearVelocity()
        self.collider:setLinearVelocity(vx, math.min(vy, const.wall_slide_speed))
    end
end

function fallDamp(self)
    local vx, vy = self.collider:getLinearVelocity()
    self.collider:setLinearVelocity(vx, math.min(vy, const.max_fall_speed))
end
--#endregion

--#region state updates
function groundState(self)
    local _, ny = self:getNormal('wall')
    self.is_grounded = ny == 1

    if self.is_grounded then
        self.is_grounded_buffered = true

        timer.cancel(self.ground_timer)

        self.ground_timer = timer.after(const.ground_buffer, function ()
            self.is_grounded_buffered = false
        end)
    end
end

function wallState(self)
    local nx, _ = self:getNormal('wall')
    local _, vy = self.collider:getLinearVelocity()
    self.is_walled = nx ~= 0 and not self.is_grounded and vy > 0 and self.has_wall_jump_item

    if self.is_walled then
        self.is_walled_buffered = true

        timer.cancel(self.wall_timer)

        self.wall_timer = timer.after(const.wall_buffer, function ()
            self.is_walled_buffered = false
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

        if ix ~= 0 then
            self.state = 'run'

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

        if vy > 0 then
            self.state = 'fall'
        end
    end

    if self.is_walled then
        self.state = 'wall_slide'
    end

    if self.is_dashing then
        self.state = 'dash'
    end

    if self.state ~= last then
        self.animation = const.animations[self.state]:clone()
        self.animation.is_flipped = const.animations[self.state].is_flipped
    end
end
--#endregion

--#region graphics
function setDirection(self)
    if input("right") and not input("left") then
        self.direction = 1
    end
    
    if not input("right") and input("left") then
        self.direction = -1
    end

    if self.is_walled then
        local nx, _ = self:getNormal('wall')
        self.direction = -nx
    end
end

function Player:draw()
    local x, y = self.collider:getPosition()
    local direction = self.direction

    if self.animation.is_flipped then
        direction = -direction
    end

    self.animation:draw(const.sprite_sheet, x, y, nil, direction * const.sprite_scale, const.sprite_scale, const.ox, const.oy)
end
--#endregion

return Player