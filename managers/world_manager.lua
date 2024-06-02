local bf = require('libraries.breezefield')
local world = bf.newWorld(0, 2000)
world:addCollisionClasses(
    {'player', ignores = {'player'}},
    {'wall', ignores = {'wall'}},
    {'border', ignores = {'border'}}
)

local function update_normals(parent_a, parent_b, nx, ny, is_collision_exit)
    for name, collision_class in pairs(world.collision_classes) do
        for _, category in ipairs({parent_a:getCategory()}) do
            if collision_class.category == category then
                if not parent_b.normal[name] then
                    parent_b.normal[name] = { x = 0, y = 0 }
                end
    
                if nx ~= 0 or is_collision_exit then
                    parent_b.normal[name].x = nx
                end
            
                if ny ~= 0 or is_collision_exit then
                    parent_b.normal[name].y = ny
                end
            end
        end
    end
end

local function onCollisionEnter(a, b, contact)

end

local function onCollisionExit(a, b, contact)
    local parent_a = a:getUserData()
    local parent_b = b:getUserData()

    update_normals(parent_a, parent_b, 0, 0, true)
    update_normals(parent_b, parent_a, 0, 0, true)
end

local function onPreSolve(a, b, contact)
    local parent_a = a:getUserData()
    local parent_b = b:getUserData()

    local nx, ny = contact:getNormal()

    update_normals(parent_a, parent_b, nx, ny)
    update_normals(parent_b, parent_a, nx, ny)
end

local function onPostSolve(a, b, contact, normalimpulse, tangentimpulse)
    
end

world:setCallbacks(onCollisionEnter, onCollisionExit, onPreSolve, onPostSolve)

return world