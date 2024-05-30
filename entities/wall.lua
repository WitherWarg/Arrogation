local Entity = require('entities.entity')

local Wall = Class {}

function Wall:init(object)
    Entity.init(self, object)

    self.collider:setType('static')
    self.collider:setCollisionClass('wall')
end

return Wall