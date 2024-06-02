--#region constant variables
local RUN_SPEED = 260
local ACCELERATION = 5
local DECELERATION = 5
local FRICTION = 2.1

local MAX_FALL_SPEED = 1500

local MIN_TURN_SPEED = 30

local JUMP_VELOCITY = -490
local JUMP_HALT_POWER = 0.7
local JUMP_BUFFER = 0.03

local GROUND_BUFFER = 0.05
local GROUND_QUERY_LENGTH = 5

local DASH_TIME = 0.2
local DASH_SPEED = 400
local DASH_COOLDOWN = 0.25
local MAX_DASHES = 1

local MAX_AIR_JUMPS = 1
local AIR_JUMP_VELOCITY = -440

local WALL_JUMP_VELOCITY = vector(175, -520)
local WALL_SLIDE_SPEED = 12
local WALL_BUFFER = 0.07
local WALL_QUERY_LENGTH = 10

local PLAYER_SCALE = 1
local SPRITE_SHEET = love.graphics.newImage('entities/player/animations/Colour2/Outline/SpriteSheet.png')
local SHEET_WIDTH, SHEET_HEIGHT = SPRITE_SHEET:getDimensions()
local FRAME_WIDTH, FRAME_HEIGHT = 120, 80
local PLAYER_WIDTH, PLAYER_HEIGHT = 12, 28
--#endregion

--#region animations
local animations = {
    idle = { frames = 10, row = 17, durations = { ['1-4'] = 0.1, ['4-4'] = 0.5, ['5-10'] = 0.15 } },
    run = { frames = 10, row = 21, durations = 0.1 },
    turn = { frames = 3, row = 26, durations = 0.07, onLoop = 'pauseAtEnd', is_flipped = true },
    jump = { frames = 3, row = 18, durations = 0.1 },
    fall = { frames = 3, row = 15, durations = 0.1 },
    dash = { frames = 2, row = 12, durations = 0.1 },
    wall_slide = { frames = 3, row = 30, durations = 0.1 },
}

local grid = anim8.newGrid(FRAME_WIDTH, FRAME_HEIGHT, SHEET_WIDTH, SHEET_HEIGHT)

for name, data in pairs(animations) do
    animations[name] = anim8.newAnimation(grid('1-' .. data.frames, data.row), data.durations, data.onLoop)
    animations[name].is_flipped = data.is_flipped or false
end
--#endregion

--#region functions
local run
local dash
local jump
local wallSlide
local fallDamp

local groundState
local wallState
local switchState

local setDirection
--#endregion

local Player = Class {
    state = '',
    can_switch_state = true,

    direction = 1,
    wall_direction = 1,

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
    object.width, object.height = PLAYER_WIDTH * PLAYER_SCALE, PLAYER_HEIGHT * PLAYER_SCALE
    object.y = object.y - object.height

    local Entity = require('entities.entity')
    Entity.init(self, object)

    self.x, self.y = nil, nil

    self.collider:setMass(1)
    world:setCollisionClasses(self.collider, 'player')

    self.animation = animations.idle
end

function Player:update(dt)
    timer.script(function(wait)
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

function Player:draw()
    local direction = self.direction

    if self.animation.is_flipped then
        direction = -direction
    end

    self.animation:draw(
        SPRITE_SHEET,
        self.collider:getX(),
        self.collider:getY(),
        nil,
        direction * PLAYER_SCALE,
        PLAYER_SCALE,
        FRAME_WIDTH / 2 - PLAYER_WIDTH / 2,
        FRAME_HEIGHT - PLAYER_HEIGHT / 2 - 1 -- For some reason animation is off by 1 (floating-point weirdness????)
    )
end

--#region physics
function dash(self, wait)
    if self.can_dash and input("dash") and self.dashes < MAX_DASHES and self.has_dash_item then
        self.is_dashing = true
        self.can_dash = false
        self.dashes = self.dashes + 1

        local g = self.collider:getGravityScale()
        self.collider:setGravityScale(0)

        self.collider:setLinearVelocity(0, 0)
        self.collider:applyLinearImpulse(self.direction * DASH_SPEED, 0)

        wait(DASH_TIME)

        self.collider:setGravityScale(g)

        self.is_dashing = false

        wait(DASH_COOLDOWN)

        self.can_dash = true
    end
end

function run(self)
    local vx, _ = self.collider:getLinearVelocity()
    local ix = self:getInputX()
    local rate_of_change = ix ~= 0 and ACCELERATION or DECELERATION
    local force = rate_of_change * (RUN_SPEED * ix - vx)

    self.collider:applyForce(force, 0)

    self.collider:applyForce(force * FRICTION, 0)
end

function jump(self)
    if input("jump") then
        self.is_jump_buffered = true

        timer.after(JUMP_BUFFER, function()
            self.is_jump_buffered = false
        end)
    end

    local can_air_jump = self.air_jumps < MAX_AIR_JUMPS and self.has_air_jump_item

    if self.is_jump_buffered and (self.is_grounded_buffered or can_air_jump or self.is_walled_buffered) then
        self.is_jump_buffered = false
        timer.cancel(self.jump_timer)

        local vx, _ = self.collider:getLinearVelocity()
        self.collider:setLinearVelocity(vx, 0)

        if self.is_grounded_buffered then
            self.is_grounded_buffered = false
            timer.cancel(self.ground_timer)

            self.collider:applyLinearImpulse(0, JUMP_VELOCITY)
        elseif self.is_walled_buffered then
            self.is_walled_buffered = false
            timer.cancel(self.wall_timer)

            self.collider:applyLinearImpulse(
                WALL_JUMP_VELOCITY.x,
                WALL_JUMP_VELOCITY.y
            )
        elseif (not self.is_grounded and not self.is_walled) and self.air_jumps < MAX_AIR_JUMPS then
            self.collider:applyLinearImpulse(0, AIR_JUMP_VELOCITY)
            self.air_jumps = self.air_jumps + 1
        end
    end

    if input("jump", "isReleased") then
        local _, vy = self.collider:getLinearVelocity()
        self.collider:applyLinearImpulse(0, -vy * JUMP_HALT_POWER)
    end
end

function wallSlide(self)
    if self.is_walled then
        local vx, vy = self.collider:getLinearVelocity()
        self.collider:setLinearVelocity(vx, math.min(vy, WALL_SLIDE_SPEED))
    end
end

function fallDamp(self)
    local vx, vy = self.collider:getLinearVelocity()
    self.collider:setLinearVelocity(vx, math.min(vy, MAX_FALL_SPEED))
end
--#endregion

--#region state updates
function groundState(self)
    local x, y = self.collider:getPosition()

    self.is_grounded = #world:queryRectangleArea(
        x - GROUND_QUERY_LENGTH/2, y + self.height/2,
        x + GROUND_QUERY_LENGTH/2, y + self.height/2,
        'wall'
    ) > 0

    if self.is_grounded then
        self.is_grounded_buffered = true

        timer.cancel(self.ground_timer)

        self.ground_timer = timer.after(GROUND_BUFFER, function()
            self.is_grounded_buffered = false
        end)
    end
end

function wallState(self)
    local _, vy = self.collider:getLinearVelocity()
    local x, y = self.collider:getPosition()

    self.is_walled = #world:queryRectangleArea(
        x + self.width/2 * self.direction, y - WALL_QUERY_LENGTH/2,
        x + self.width/2 * self.direction, y + WALL_QUERY_LENGTH/2,
        'wall'
    ) > 0 and self.has_wall_jump_item and vy > 0 and not self.is_grounded

    if self.is_walled then
        self.is_walled_buffered = true

        timer.cancel(self.wall_timer)

        self.wall_timer = timer.after(WALL_BUFFER, function()
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

            if ix == -math.sign(vx) and math.abs(vx) > MIN_TURN_SPEED then
                self.can_switch_state = false
                self.state = 'turn'

                timer.after(animations.turn.totalDuration, function()
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
        self.animation = animations[self.state]:clone()
        self.animation.is_flipped = animations[self.state].is_flipped
    end
end
--#endregion

--#region direction
function setDirection(self)
    if input("right") and not input("left") then
        self.direction = 1
    end

    if not input("right") and input("left") then
        self.direction = -1
    end
end
--#endregion

return Player
