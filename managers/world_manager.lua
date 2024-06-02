local bf = require('libraries.breezefield')
local world = bf.newWorld(0, 2000)
world:addCollisionClasses(
    {'player', ignores = {'player'}},
    {'wall', ignores = {'wall'}},
    {'border', ignores = {'border'}}
)

-- local function update_normals(parent_a, parent_b, nx, ny)
--     for name, collision_class in pairs(world.collision_classes) do
--         for _, category in ipairs({parent_a:getCategory()}) do
--             if collision_class.category == category then
--                 if not parent_b.normals[name] then
--                     parent_b.normals[name] = { x = 0, y = 0 }
--                 end
    
--                 if nx ~= 0 then
--                     parent_b.normals[name].x = nx
--                 end
            
--                 if ny ~= 0 then
--                     parent_b.normals[name].y = ny
--                 end
--             end
--         end
--     end
-- end

-- local function onCollisionEnter(a, b, contact)

-- end

-- local function onCollisionExit(a, b, contact)
--     -- local parents = { a:getUserData(), b:getUserData() }

--     -- local nx, ny = contact:getNormal()
    
--     -- for _, parent in ipairs(parents) do
--     --     for name, _ in pairs(world.collision_classes) do

--     --     end
--     -- end

--     -- local index = b:getCategory()

--     -- normal[index].x = 0

--     -- normal[index].y = 0
-- end

-- local function onPreSolve(a, b, contact)
--     local parent_a = a:getUserData()
--     local parent_b = b:getUserData()

--     local nx, ny = contact:getNormal()

--     update_normals(parent_a, parent_b, nx, ny)
--     update_normals(parent_b, parent_a, nx, ny)
-- end

-- local function onPostSolve(a, b, contact, normalimpulse, tangentimpulse)
    
-- end

-- world:setCallbacks(onCollisionEnter, onCollisionExit, onPreSolve, onPostSolve)

return world