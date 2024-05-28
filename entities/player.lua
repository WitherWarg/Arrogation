local Entity = require('entities.entity')

local Player = Class {
    width = 20,
    height = 50
}

function Player:init(x, y)
    Entity.init(self, x, y, self.width, self.height)
end

return Player