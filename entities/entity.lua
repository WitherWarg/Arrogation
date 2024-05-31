local Entity = Class {}

function Entity:init(object)
    self.x, self.y, self.width, self.height = object.x, object.y, object.width, object.height

    if self.width == 0 then
        self.width = 1
    end

    if self.height == 0 then
        self.height = 1
    end

    self.collider = world:newCollider("rectangle", {self.x + self.width/2, self.y + self.height/2, self.width, self.height})

    self.collider:setFixedRotation(true)
    self.collider:setFriction(0)
end

return Entity