--#region init functions
local players
local flags
local walls
local borders
--#endregion

local MapManager = Class {}

function MapManager:init(name)
    local sti = require('libraries.sti')
    self.map = sti('maps/' .. name .. '/map.lua')
    self.active_objects = {}

    players(self)

    flags(self)

    walls(self)

    borders(self)
end

function MapManager:update(dt)
    for _, active_object in pairs(self.active_objects) do
        for _, object in ipairs(active_object) do
            object:update(dt)
        end
    end
end

function players(self)
    self.players = {}
    self.active_objects.players = {}
    local Player = require('entities.player.player')
    for _, object in ipairs(self.map.layers["hitboxes.player"].objects) do
        local player = Player(object)
        table.insert(self.players, player)
        table.insert(self.active_objects.players, player)
    end
end

function flags(self)
    self.flags = {}
    self.active_objects.flags = {}
    local Flag = require('entities.flag.flag')
    for _, object in ipairs(self.map.layers["hitboxes.flag"].objects) do
        local flag = Flag(object)
        table.insert(self.flags, flag)
        table.insert(self.active_objects.flags, flag)
    end
end

function walls(self)
    self.walls = {}
    local Wall = require('entities.wall')
    for _, object in ipairs(self.map.layers["hitboxes.wall"].objects) do
        table.insert(self.walls, Wall(object))
    end
end

function borders(self)
    self.borders = {}
    local Border = require('entities.border')
    for _, object in ipairs(self.map.layers["hitboxes.border"].objects) do
        table.insert(self.borders, Border(object))
    end
end

return MapManager