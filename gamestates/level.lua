local Level = {}

function Level:enter()
    local WORLD_SCALE = 2
    WORLD_WIDTH = love.graphics.getWidth() / WORLD_SCALE
    WORLD_HEIGHT = love.graphics.getHeight() / WORLD_SCALE

    local wf = require('libraries.windfield')
    world = wf.newWorld(0, 2000)

    local Player = require('entities.player')
    player = Player(100, love.graphics.getHeight() - 100)

    local Wall = require('entities.wall')
    floor = Wall(0, love.graphics.getHeight() - 50, love.graphics.getWidth(), 50)

    local Camera = require('libraries.camera')
    camera = Camera{ scale = WORLD_SCALE }
end

function Level:update(dt)
    world:update(dt)

    local x = math.clamp(player.x, WORLD_WIDTH / 2, floor.width - WORLD_WIDTH / 2)
    local y = math.min(player.y, WORLD_HEIGHT * 3 / 2)
    camera:setTranslation(x, y)
end

function Level:draw()
    camera:push()
    
    world:draw()
    
    camera:pop()
end

function Level:leave()
    
end

return Level