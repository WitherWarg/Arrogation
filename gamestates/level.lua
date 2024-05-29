local Level = {}

function Level:enter(last, level_name)
    self.last = last

    local WORLD_SCALE = 3
    WORLD_WIDTH = love.graphics.getWidth() / WORLD_SCALE
    WORLD_HEIGHT = love.graphics.getHeight() / WORLD_SCALE

    world = newWorld('wall', 'player')

    local MapManager = require('manager.map_manager')
    map_manager = MapManager(level_name)

    player = map_manager.players[#map_manager.players]

    local CameraManager = require('manager.camera_manager')
    camera_manager = CameraManager(WORLD_SCALE, map_manager.map)

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
    camera_manager:follow(player.collider:getPosition())
    camera_manager:clamp()
end

function Level:draw()
    camera_manager:draw('background')
    camera_manager:draw('foreground')

    camera_manager:push()
    
    player:draw()
    
    camera_manager:pop()

    camera_manager:draw('foreplayer')
end

function Level:leave()
    
end

return Level