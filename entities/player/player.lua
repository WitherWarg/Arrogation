local Entity = require('entities.entity')

local Player = Class {
    state = '',
    direction = 1
}

local run
local run_speed = 260
local accel = 5
local decel = 5
local friction = 2.1

local selectState
local sprite_scale = 1.5
local sprite_sheet = love.graphics.newImage('entities/player/animations/Colour2/Outline/SpriteSheet.png')
local frame_width, frame_height = 120, 80
local sheet_width, sheet_height = sprite_sheet:getDimensions()
local sprite_width, sprite_height = 20, 38
local width, height = 12, 28
local ox, oy = frame_width / 2 - sprite_width / 2, frame_height - height / 2
local grid = anim8.newGrid(frame_width, frame_height, sheet_width, sheet_height, 4.5)

local animations = {
    idle = { frames = 10, row = 17, durations = {['1-4']=0.1, ['4-4'] = 0.5, ['5-10'] = 0.15} },
    run = { frames = 10, row = 21, durations = 0.1 },
    turn = { frames = 3, row = 26, durations = 0.1, onLoop = 'pauseAtEnd', flippedH = true, position = 3 },
}

for name, data in pairs(animations) do
    animations[name] = anim8.newAnimation(grid('1-' .. data.frames, data.row), data.durations, data.onLoop)
    animations[name].flippedH = data.flippedH or false
    animations[name].position = data.position
end

local direction

function Player:init(x, y)
    Entity.init(self, x, y, width * sprite_scale, height * sprite_scale)

    self.collider:setMass(1)
end

function Player:update(dt)
    selectState(self)
    direction(self)
    run(self)

    animations[self.state]:update(dt)
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
    local rate_of_change = ix ~= 0 and accel or decel
    local force = rate_of_change * (run_speed * ix - vx)
    
    player.collider:applyForce(force, 0)

    player.collider:applyForce(force * friction, 0)
end

function selectState(self)
    local last = self.state
    local ix = player:getInputX()
    local vx, _ = player.collider:getLinearVelocity()

    if ix == 0 then
        self.state = 'idle'
    else
        if animations['turn'].position == #animations['turn'].frames then
            self.state = 'run'
        end

        if ix ~= math.sign(vx) and math.sign(vx) ~= 0 then
            self.state = 'turn'
        end
    end

    if self.state ~= last then
        animations[self.state]:gotoFrame(1)
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

    local animation = animations[self.state]
    
    animation:draw(sprite_sheet, x, y, nil, self.direction * sprite_scale, sprite_scale, ox, oy)
end

return Player