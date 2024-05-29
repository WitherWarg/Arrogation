local MapManager = Class {}

function MapManager:init(name)
    local sti = require('libraries.sti')
    self.map = sti('maps/' .. name .. '/map.lua')
    self.update_objects = {}

    self.players = {}
    local Player = require('entities.player.player')
    for _, object in ipairs(self.map.layers["hitboxes.player"].objects) do
        local player = Player(object.x, object.y)
        table.insert(self.players, player)
        table.insert(self.update_objects, player)
    end

    self.main_player = self.players[math.random(1, #self.players)]

    self.walls = {}
    local Wall = require('entities.wall')
    for _, object in ipairs(self.map.layers["hitboxes.wall"].objects) do
        table.insert(self.walls, Wall(object.x, object.y, object.width, object.height))
    end

    self.borders = {}
    local Border = require('entities.border')
    for _, object in ipairs(self.map.layers["hitboxes.border"].objects) do
        table.insert(self.borders, Border(object.x, object.y, object.width, object.height))
    end
end

function MapManager:update(dt)
    for _, object in ipairs(self.update_objects) do
        object:update(dt)
    end

    self.x, self.y = self.main_player.collider:getPosition()
end

return MapManager