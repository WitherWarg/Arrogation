local Entity = require('entities.entity')

local Border = Class {}

function Border:init(x, y, width, height)
    Entity.init(self, x, y, width, height)

    self.collider:setType('static')
end

return Border