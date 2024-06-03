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
    self.width, self.height = WIDTH * FLAG_SCALE, HEIGHT * FLAG_SCALE
    self.x, self.y = object.x - self.width/2, object.y - self.height/2

    self.animation = animation:clone()
end

function Flag:update(dt)
    if #world:queryRectangleArea(self.x, self.y, self.x + self.width, self.y + self.height, 'player') > 0 then
        return GS.switch(MainMenu)
    end

    self.animation:update(dt)
end

function Flag:draw()
    self.animation:draw(sprite_sheet, self.x, self.y, nil, FLAG_SCALE, nil, ORIGIN_X, ORIGIN_Y)
end

return Flag