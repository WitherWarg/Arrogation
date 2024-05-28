local Entity = require('entities.entity')

local Player = Class {
    state = '',
    direction = 1,
    is_state_complete = true,
}

local consts = {
    run_speed = 260,
    accel = 5,
    decel = 5,
    friction = 2.1,

    sprite_scale = 1.5,
    sprite_sheet = love.graphics.newImage('entities/player/animations/Colour2/Outline/SpriteSheet.png'),
    frame_width = 120, frame_height = 80,
    sprite_width = 20, sprite_height = 38,
    width = 12, height = 28,

    animations = {
        idle = { frames = 10, row = 17, durations = {['1-4']=0.1, ['4-4'] = 0.5, ['5-10'] = 0.15} },
        run = { frames = 10, row = 21, durations = 0.1 },
        turn = { frames = 3, row = 26, durations = 0.07, onLoop = 'pauseAtEnd', flippedH = true, position = 3 },
    },
}

function loadAnimations()
    consts.ox, consts.oy = consts.frame_width / 2 - consts.sprite_width / 2, consts.frame_height - consts.height / 2

    local sheet_width, sheet_height = consts.sprite_sheet:getDimensions()
    local grid = anim8.newGrid(consts.frame_width, consts.frame_height, sheet_width, sheet_height)

    for name, data in pairs(consts.animations) do
        consts.animations[name] = anim8.newAnimation(grid('1-' .. data.frames, data.row), data.durations, data.onLoop)
        consts.animations[name].flippedH = data.flippedH or false
        consts.animations[name].position = data.position
    end
end

loadAnimations()

local run
local groundState
local selectState
local direction

function Player:init(x, y)
    Entity.init(self, x, y, consts.width * consts.sprite_scale, consts.height * consts.sprite_scale)

    self.collider:setMass(1)

    self.animation = consts.animations.idle
end

function Player:update(dt)
    groundState(self)
    selectState(self)

    direction(self)

    run(self)

    self.animation:update(dt)
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

function run(self)
    local vx, _ = player.collider:getLinearVelocity()
    local ix = player:getInputX()
    local rate_of_change = ix ~= 0 and consts.accel or consts.decel
    local force = rate_of_change * (consts.run_speed * ix - vx)
    
    player.collider:applyForce(force, 0)

    player.collider:applyForce(force * consts.friction, 0)
end

function groundState(self)
    local width, height = self.width, 1
    local x, y = self.collider:getX() - width / 2, self.collider:getY() + self.height / 2 - height/2
    self.is_grounded = #world:queryRectangleArea(x, y, width, height, {'wall'}) > 0
end

function selectState(self)
    if not self.is_state_complete then
        return
    end

    local last = self.state
    local ix = player:getInputX()
    local vx, _ = player.collider:getLinearVelocity()

    if self.is_grounded then
        if self.state ~= 'idle' and ix == 0 then
            self.state = 'idle'
            self.is_state_complete = true
        end
        
        if ix ~= 0 then
            if self.state ~= 'run' then
                self.state = 'run'
                self.is_state_complete = true
            end

            if ix ~= math.sign(vx) and math.sign(vx) ~= 0 then
                self.is_state_complete = false
                self.state = 'turn'

                timer.after(consts.animations.turn.totalDuration, function ()
                    self.is_state_complete = true
                end)
            end
        end
    end

    if self.state ~= last then
        self.animation = consts.animations[self.state]:clone()
    end
end

function direction(self)
    if input("right") and not input("left") then
        self.direction = 1
    end

    if not input("right") and input("left") then
        self.direction = -1
    end
end

function Player:draw()
    local x, y = player.collider:getPosition()
    local sprite_scale = self.direction * consts.sprite_scale
    
    self.animation:draw(consts.sprite_sheet, x, y, nil, sprite_scale, consts.sprite_scale, consts.ox, consts.oy)
end

return Player