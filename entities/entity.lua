local Entity = Class {}

function Entity:init(object)
    self.x, self.y, self.width, self.height = object.x, object.y, object.width, object.height

    if object.shape == 'polygon' then
        local polygon = {}

        for _, vec2 in ipairs(object.polygon) do
            table.insert(polygon, vec2.x)
            table.insert(polygon, vec2.y)
        end

        self.width, self.height = nil, nil
        self.polygon = object.polygon
        self.collider = world:newPolygonCollider(polygon)
    end

    if object.shape == 'rectangle' or object.shape == 'point' then
        if object.width == 0 or object.height == 0 then
            self.collider = world:newLineCollider(self.x, self.y, self.x + self.width, self.y + self.height)
        else
            self.collider = world:newRectangleCollider(self.x, self.y, self.width, self.height)
        end
    end

    if object.shape == 'ellipse' then
        self.collider = world:newCircleCollider(self.x + self.width / 2, self.y + self.height / 2, self.width / 2)
    end

    self.collider:setFixedRotation(true)
    self.collider:setFriction(0)

    return self.collider
end

return Entity