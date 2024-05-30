local Level = {}

function Level:enter(last, level_name)
    self.last = last

    local WORLD_SCALE = 3
    WORLD_WIDTH = love.graphics.getWidth() / WORLD_SCALE
    WORLD_HEIGHT = love.graphics.getHeight() / WORLD_SCALE

    world = newWorld('wall', 'player')

    local MapManager = require('manager.map_manager')
    map_manager = MapManager(level_name)

    local CameraManager = require('manager.camera_manager')
    camera_manager = CameraManager(WORLD_SCALE, map_manager)

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
    map_manager:update(dt)
    camera_manager:follow(map_manager.x, math.huge)
    camera_manager:clamp()
end

function Level:draw()
    camera_manager:draw()
end

function Level:leave()
    
end

return Level