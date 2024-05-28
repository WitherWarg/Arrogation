local CameraManager = Class {}

function CameraManager:init(scale)
    local Camera = require('libraries.camera')

    self.scale = scale
    self.main_camera = Camera{ scale = scale, mode = 'all' }
end

function CameraManager:update()
    self:follow(player.collider:getPosition())
    self:clamp(0, floor.width, 0, WORLD_HEIGHT)
end

function CameraManager:follow(x, y)
    self.main_camera:setTranslation(x, y)
end

function CameraManager:clamp(left, right, top, bottom)
    local cam_x, cam_y = self.main_camera:getTranslation()

    local x = math.clamp(cam_x, left + WORLD_WIDTH / 2, right - WORLD_WIDTH / 2)
    local y = math.clamp(cam_y, top - WORLD_HEIGHT / 2, bottom + WORLD_HEIGHT / 2)

    self.main_camera:setTranslation(x, y)
end

function CameraManager:push()
    self.main_camera:push()
end

function CameraManager:pop()
    self.main_camera:pop()
end

return CameraManager