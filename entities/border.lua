local Border = Class {}

function Border:init(object)
    local Entity = require('entities.entity')
    Entity.init(self, object)

    self.collider:setType('static')
    world:setCollisionClasses(self.collider, 'border')
end

return Border