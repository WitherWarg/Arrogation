local Level = {}

function Level:enter()
    local WORLD_SCALE = 2
    WORLD_WIDTH = love.graphics.getWidth() / WORLD_SCALE
    WORLD_HEIGHT = love.graphics.getHeight() / WORLD_SCALE

    world = newWorld('wall', 'player')

    local Player = require('entities.player.player')
    player = Player(100, love.graphics.getHeight() - 100)

    local Wall = require('entities.wall')
    floor = Wall(0, love.graphics.getHeight() - 50, love.graphics.getWidth(), 50)

    local Camera = require('libraries.camera')
    camera = Camera{ scale = WORLD_SCALE, mode = 'all' }

    local Border = require('entities.border')
    Border(-1, 0, 1, love.graphics.getHeight())
    Border(floor.width, 0, 1, love.graphics.getHeight())

    background = love.graphics.newImage('rdm_back.png')

    pause = false
end

function Level:update(dt)
    love.keyboard.update()

    if input("pause") then
        pause = not pause
    end

    if pause then
        return
    end

    timer.update(dt)
    world:update(dt)
    player:update(dt)

    local x = math.clamp(player.collider:getX(), WORLD_WIDTH / 2, floor.width - WORLD_WIDTH / 2)
    local y = math.min(player.collider:getY(), WORLD_HEIGHT * 3 / 2)
    camera:setTranslation(x, y)
end

function Level:draw()
    camera:push()
    
    love.graphics.draw(background, floor.x, floor.y + floor.height, nil, 0.4, nil, nil, background:getHeight())

    player:draw()

    world:draw()

    camera:pop()
end

function Level:leave()
    
end

return Level