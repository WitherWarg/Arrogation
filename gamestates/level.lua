local Level = {}

function Level:enter(previous, level_name)
    self.previous = previous
    self.is_leaving = false

    WORLD_SCALE = 3
    WORLD_WIDTH = WIDTH / WORLD_SCALE
    WORLD_HEIGHT = HEIGHT / WORLD_SCALE

    newWorld = require('managers.world_manager')
    world = newWorld()

    local MapManager = require('managers.map_manager')
    map_manager = MapManager(level_name)

    local CameraManager = require('managers.camera_manager')
    camera_manager = CameraManager(map_manager, WORLD_SCALE)

    pause = false

    love.mouse.setVisible(false)
end

function Level:update(dt)
    if self.is_leaving then
        return
    end

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
    self.is_leaving = true

    love.mouse.setVisible(true)
    
    WORLD_SCALE, WORLD_WIDTH, WORLD_HEIGHT = nil, nil, nil

    pause = nil

    timer.clear()

    world:destroy()
    world = nil

    map_manager = nil

    camera_manager = nil
end

return Level