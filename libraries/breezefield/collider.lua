-- a Collider object, wrapping shape, body, and fixtue
local set_funcs, lp, lg, COLLIDER_TYPES = unpack(
   require((...):gsub('collider', '') .. '/utils'))

local Collider = {}
Collider.__index = Collider



function Collider.new(world, collider_type, ...)
   print("Collider.new is deprecated and may be removed in a later version. use world:newCollider instead")
   return world:newCollider(collider_type, {...})
end

function Collider:draw_type()
   if self.collider_type == 'Edge' or self.collider_type == 'Chain' then
      return 'line'
   end
   return self.collider_type:lower()
end

function Collider:__draw__()
   self._draw_type = self._draw_type or self:draw_type()
   local args
   if self._draw_type == 'line' then
      args = {self:getSpatialIdentity()}
   else
      args = {'line', self:getSpatialIdentity()}
   end
   love.graphics[self:draw_type()](unpack(args))
end

function Collider:setDrawOrder(num)
   self._draw_order = num
   self._world._draw_order_changed = true
end

function Collider:getDrawOrder()
   return self._draw_order
end

function Collider:draw()
   self:__draw__()
end


function Collider:destroy()
   self._world:_remove(self)
   self.fixture:setUserData(nil)
   self.fixture:destroy()
   self.body:destroy()
end

function Collider:getSpatialIdentity()
   if self.collider_type == 'Circle' then
      return self:getX(), self:getY(), self:getRadius()
   else
      return self:getWorldPoints(self:getPoints())
   end
end

function Collider:collider_contacts()
   local contacts = self:getContacts()
   local colliders = {}
   for i, contact in ipairs(contacts) do
      if contact:isTouching() then
	 local f1, f2 = contact:getFixtures()
	 if f1 == self.fixture then
	    colliders[#colliders+1] = f2:getUserData()
	 else
	    colliders[#colliders+1] = f1:getUserData()
	 end
      end
   end
   return colliders
end

function Collider:setCollisionClasses(world, ...)
   assert(type(world) == 'table', "World must be provided as the first argument.")
   
   local collision_classes = {...}
   assert(#collision_classes > 0, "Must provide at least one collision class")

   for i, collision_class1 in ipairs(collision_classes) do
      for j, collision_class2 in ipairs(collision_classes) do
         assert(collision_class1 ~= collision_class2 or i == j, "Cannot provide the same collision class")
      end
   end

   local categories = {}
   local list_of_ignores = {}
   for _, collision_class in ipairs(collision_classes) do   
      assert(
         world.collision_classes[collision_class:lower()] ~= nil,
         "Collision class " .. collision_class  .. " is nil (see World:addCollisionClass)"
      )

      collision_class = world.collision_classes[collision_class:lower()]

      table.insert(categories, collision_class.category)
      table.insert(list_of_ignores, collision_class.ignores)
   end

   self.fixture:setCategory(unpack(categories))
   
   local masks = {}
   for _, ignores in ipairs(list_of_ignores) do
      for _, collision_class in ipairs(ignores) do
         assert(
            world.collision_classes[collision_class:lower()] ~= nil,
            "Collision class " .. collision_class .. " is nil (see World:addCollisionClass)"
         )
         table.insert(masks, world.collision_classes[collision_class:lower()].category)
      end
   end

   self.fixture:setMask(unpack(masks))
end

return Collider