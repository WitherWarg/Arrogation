--#region constant variables
local X_SPEED_PERCENT = 10
local UP_SPEED_PERCENT = 5
local DOWN_SPEED_PERCENT = 35
local DOWN_THRESHOLD = 570
--#endregion

local CameraManager = Class {}

function CameraManager:init(map_manager, scale)
    local Camera = require('libraries.camera')

    self.camera = Camera{ scale = scale, mode = 'all' }

    self.map = map_manager.map
    self.layers = {}

    for _, layer in ipairs(map_manager.map.layers) do
        if layer.type == 'tilelayer' then
            self.camera:addLayer(layer.name, 1, { relativeScaleX = layer.parallaxx, relativeScaleY = layer.parallaxy })
            for name, active_object in pairs(map_manager.active_objects) do
                local name_after_dot = string.gsub(string.match(layer.name, "(%..*)$"), "%.", "")
                if name == name_after_dot then
                    for _, object in ipairs(active_object) do
                        table.insert(self.layers, object)
                    end
                else
                    table.insert(self.layers, layer)
                end
            end
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

    self.target = map_manager.players[math.random(#map_manager.players)].collider
    self:follow(self.target:getPosition())
end

function CameraManager:update()
    local _, vy = self.target:getLinearVelocity()
    local x, y = self.camera:getTranslation()

    local Y_SPEED_PERCENT = UP_SPEED_PERCENT

    if vy > DOWN_THRESHOLD then
        Y_SPEED_PERCENT = DOWN_SPEED_PERCENT
    end

    self:follow(
        math.lerp(x, self.target:getX(), X_SPEED_PERCENT/100),
        math.lerp(y, self.target:getY(), Y_SPEED_PERCENT/100)
    )
    self:clamp()
end

function CameraManager:follow(x, y)
    self.camera:setTranslation(math.round(x), math.round(y))
end

function CameraManager:clamp()
    local x, y = self.camera:getTranslation()

    self.camera:setTranslation(
        math.clamp(x, self.left + WORLD_WIDTH / 2, self.right - WORLD_WIDTH / 2),
        math.clamp(y, self.top + WORLD_HEIGHT / 2, self.bottom - WORLD_HEIGHT / 2)
    )
end

function CameraManager:draw()
    for _, layer in ipairs(self.layers) do
        self.camera:push(layer.name)

        self.map:drawLayer(layer)

        self.camera:pop()           
    end
end

function CameraManager:world()
    self.camera:push()

    world:draw()

    self.camera:pop()
end

return CameraManager