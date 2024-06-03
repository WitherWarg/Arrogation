--#region constant variables
local WIDTH, HEIGHT = 10, 50
local ORIGIN_X, ORIGIN_Y = 8.5, 33
local FLAG_SCALE = 1
--#endregion

--#region animation
local sprite_sheet = love.graphics.newImage('entities/flag/animation.png')
local FRAME_WIDTH, FRAME_HEIGHT = 60, 60

local grid = anim8.newGrid(FRAME_WIDTH, FRAME_HEIGHT, sprite_sheet:getWidth(), sprite_sheet:getHeight())
local animation = anim8.newAnimation(grid('1-5', 1), 0.1)
--#endregion

local Flag = Class {}

function Flag:init(object)
    object.width, object.height = WIDTH * FLAG_SCALE, HEIGHT * FLAG_SCALE

    local Entity = require('entities.entity')
    Entity.init(self, object)

    self.collider:setPosition(self.x - self.width/2, self.y - self.height/2)
    self.x, self.y = self.collider:getPosition()

    world:setCollisionClasses(self.collider, 'flag')
    self.collider:setType('static')

    self.animation = animation:clone()
end

function Flag:update(dt)
    self.animation:update(dt)
end

function Flag:draw()
    self.animation:draw(sprite_sheet, self.x, self.y, nil, FLAG_SCALE, nil, ORIGIN_X, ORIGIN_Y)
end

return Flag