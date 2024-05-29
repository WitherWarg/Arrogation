local Entity = require('entities.entity')

local Border = Class {}

function Border:init(x, y, width, height)
    if width == 0 then
        width = 1
    end

    if height == 0 then
        height = 1
    end

    Entity.init(self, x, y, width, height)

    self.collider:setType('static')
end

return Border