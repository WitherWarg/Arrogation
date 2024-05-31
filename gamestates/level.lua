local Level = {}

function Level:enter(previous, level_name)
    self.previous = previous

    WORLD_SCALE = 3
    WORLD_WIDTH = WIDTH / WORLD_SCALE
    WORLD_HEIGHT = HEIGHT / WORLD_SCALE

    world = newWorld(0, 2000, {'wall', 'player'})

    local MapManager = require('managers.map_manager')
    map_manager = MapManager(level_name)

    local CameraManager = require('managers.camera_manager')
    camera_manager = CameraManager(map_manager, WORLD_SCALE, map_manager.player.collider)

    pause = false

    love.mouse.setVisible(false)
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
    WORLD_SCALE, WORLD_WIDTH, WORLD_HEIGHT = nil, nil, nil

    pause = nil

    map_manager = nil

    camera_manager = nil

    timer.clear()

    world:destroy()
    world = nil

    love.mouse.setVisible(true)
end

return Level