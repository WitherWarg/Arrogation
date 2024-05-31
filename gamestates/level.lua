local Level = {}

local player

function Level:enter(previous, level_name)
    self.previous = previous

    WORLD_SCALE = 3
    WORLD_WIDTH = love.graphics.getWidth() / WORLD_SCALE
    WORLD_HEIGHT = love.graphics.getHeight() / WORLD_SCALE

    world = newWorld(0, 2000, {'wall', 'player'})

    local MapManager = require('managers.map_manager')
    map_manager = MapManager(level_name)

    player = map_manager.main_player

    local CameraManager = require('managers.camera_manager')
    camera_manager = CameraManager(map_manager, WORLD_SCALE, player.collider)

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
    camera_manager:update()
end

function Level:draw()
    camera_manager:draw()
end

function Level:leave()
    
end

return Level