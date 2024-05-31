local Wall = Class {}

function Wall:init(object)
    local Entity = require('entities.entity')
    Entity.init(self, object)

    self.collider:setType('static')
    self.collider:setCollisionClass(world, 'wall')
end

return Wall