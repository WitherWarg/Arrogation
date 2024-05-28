local Entity = Class {}

function Entity:init(x, y, width, height, angle)
    self.collider = world:newRectangleCollider(x, y, width, height)

    self.collider:setFriction(0)
    self.collider:setAngle(math.rad(angle or 0))
    self.collider:setFixedRotation(true)

    self.x, self.y, self.width, self.height = x, y, width, height
end

return Entity