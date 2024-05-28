local Entity = require('entities.entity')

local Wall = Class {}

function Wall:init(x, y, width, height)
    Entity.init(self, x, y, width, height)

    self.collider:setType('static')
    self.collider:setCollisionClass('wall')
end

return Wall