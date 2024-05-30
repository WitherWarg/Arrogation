local Entity = require('entities.entity')

local Border = Class {}

function Border:init(object)
    Entity.init(self, object)

    self.collider:setType('static')
end

return Border