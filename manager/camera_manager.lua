local CameraManager = Class {}

function CameraManager:init(scale, map)
    local Camera = require('libraries.camera')

    self.scale = scale
    self.main_camera = Camera{ scale = scale, mode = 'all' }

    self.map = map
    self.layers = {}

    for _, layer in ipairs(map.layers) do
        if layer.type == 'tilelayer' then
            self.main_camera:addLayer(layer.name, 1, { relativeScale = layer.parallaxx })
            table.insert(self.layers, layer)       
        end
    end

    self.left, self.right = math.huge, 0
    self.top, self.bottom = math.huge, 0

    for _, object in ipairs(map.layers["hitboxes.border"].objects) do
        self.left = math.min(self.left, object.x)
        self.right = math.max(self.right, object.x)

        self.top = math.min(self.top, object.y)
        self.bottom = math.max(self.bottom, object.y)
    end
end

function CameraManager:follow(x, y)
    self.main_camera:setTranslation(x, y)
end

function CameraManager:clamp()
    local cam_x, cam_y = self.main_camera:getTranslation()

    local x = math.clamp(cam_x, self.left + WORLD_WIDTH / 2, self.right - WORLD_WIDTH / 2)
    local y = math.clamp(cam_y, self.top + WORLD_HEIGHT / 2, self.bottom - WORLD_HEIGHT / 2)

    self.main_camera:setTranslation(x, y)
end

function CameraManager:draw(group_layer)
    for _, layer in ipairs(self.layers) do
        if string.find(layer.name, group_layer) then
            self.main_camera:push(layer.name)

            self.map:drawLayer(layer)

            self.main_camera:pop()           
        end
    end
end

function CameraManager:push()
    self.main_camera:push()
end

function CameraManager:pop()
    self.main_camera:pop()
end

return CameraManager