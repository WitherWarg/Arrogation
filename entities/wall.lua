local Wall = Class {}

function Wall:init(object)
    local Entity = require('entities.entity')
    Entity.init(self, object)

    self.collider:setType('static')
    world:setCollisionClasses(self.collider, 'wall')
end

return Wall