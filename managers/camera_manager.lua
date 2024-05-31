--#region constant variables
local X_SPEED = 0.1
local UP_SPEED = 0.05
local DOWN_SPEED = 0.15
--#endregion

local CameraManager = Class {}

function CameraManager:init(map_manager, scale, target_collider)
    local Camera = require('libraries.camera')

    self.scale = scale
    self.camera = Camera{ scale = scale, mode = 'all' }

    self.map = map_manager.map
    self.layers = {}

    local player_index = 0

    for i, layer in ipairs(map_manager.map.layers) do
        if layer.type == 'tilelayer' then
            self.camera:addLayer(layer.name, 1, { relativeScale = layer.parallaxx })
            table.insert(self.layers, layer)

            if string.find(layer.name, 'foreplayer') then
                local last = map_manager.map.layers[i - 1]
                if string.find(last.name, 'foreground') then
                    player_index = i
                end
            end
        end
    end

    for i, player in ipairs(map_manager.players) do
        table.insert(self.layers, player_index + i - 1, player)
    end

    self.left, self.right = math.huge, 0
    self.top, self.bottom = math.huge, 0

    for _, border in ipairs(map_manager.borders) do
        self.left = math.min(self.left, border.x)
        self.right = math.max(self.right, border.x)

        self.top = math.min(self.top, border.y)
        self.bottom = math.max(self.bottom, border.y)
    end

    self.target_collider = target_collider
    self:follow(target_collider:getPosition())
end

function CameraManager:update()
    -- TODO
    local _, vy = self.target_collider:getLinearVelocity()
    local x, y = self.target_collider:getPosition()
    local cam_x, cam_y = self.camera:getTranslation()

    local Y_SPEED = UP_SPEED

    if vy > 0 then
        Y_SPEED = DOWN_SPEED
    end

    self:follow(
        math.lerp(cam_x, x, X_SPEED),
        math.lerp(cam_y, y, Y_SPEED)
    )

    self:clamp()
end

function CameraManager:follow(x, y)
    self.camera:setTranslation(x, y)
end

function CameraManager:clamp()
    local cam_x, cam_y = self.camera:getTranslation()

    local x = math.clamp(cam_x, self.left + WORLD_WIDTH / 2, self.right - WORLD_WIDTH / 2)
    local y = math.clamp(cam_y, self.top + WORLD_HEIGHT / 2, self.bottom - WORLD_HEIGHT / 2)

    self.camera:setTranslation(x, y)
end

function CameraManager:draw()
    for _, layer in ipairs(self.layers) do
        self.camera:push(layer.name)

        self.map:drawLayer(layer)

        self.camera:pop()           
    end
end

function CameraManager:debugWorld()
    self.camera:push()

    world:draw()

    self.camera:pop()
end

return CameraManager