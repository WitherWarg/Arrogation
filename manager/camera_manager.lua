local CameraManager = Class {}

function CameraManager:init(scale, map_manager)
    local Camera = require('libraries.camera')

    self.scale = scale
    self.main_camera = Camera{ scale = scale, mode = 'all' }

    self.map = map_manager.map
    self.layers = {}

    for _, layer in ipairs(map_manager.map.layers) do
        if layer.type == 'tilelayer' then
            self.main_camera:addLayer(layer.name, 1, { relativeScale = layer.parallaxx })
            table.insert(self.layers, layer)
        end
    end

    self.left, self.right = math.huge, 0
    self.top, self.bottom = math.huge, 0

    for _, border in ipairs(map_manager.borders) do
        self.left = math.min(self.left, border.x)
        self.right = math.max(self.right, border.x)

        self.top = math.min(self.top, border.y)
        self.bottom = math.max(self.bottom, border.y)
    end

    -- for _, player in ipairs(map_manager.players) do
    --     table.print(table.merge(player, { opacity = 1 }))
    --     table.print(player)
    --     table.insert(self.layers, table.merge(player, { opacity = 1 }))
    -- end
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

function CameraManager:draw()
    for _, layer in ipairs(self.layers) do
            self.main_camera:push(layer.name)

            self.map:drawLayer(layer)

            self.main_camera:pop()           
    end
end

function CameraManager:push()
    self.main_camera:push()
end

function CameraManager:pop()
    self.main_camera:pop()
end

return CameraManager