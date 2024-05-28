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

    local CameraManager = require('camera_manager')
    camera_manager = CameraManager(WORLD_SCALE)

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
    camera_manager:update()
end

function Level:draw()
    camera_manager:push()
    
    love.graphics.draw(background, floor.x, floor.y + floor.height, nil, 0.4, nil, nil, background:getHeight())

    player:draw()

    world:draw()

    camera_manager:pop()
end

function Level:leave()
    
end

return Level