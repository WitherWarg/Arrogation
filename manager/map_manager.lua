local MapManager = Class {}

function MapManager:init(name)
    local sti = require('libraries.sti')
    self.map = sti('maps/' .. name .. '/map.lua')

    self.players = {}
    local Player = require('entities.player.player')
    for _, object in ipairs(self.map.layers["hitboxes.player"].objects) do
        table.insert(self.players, Player(object.x, object.y))
    end

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

return MapManager