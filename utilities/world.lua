local current = {}

function newWorld(...)
    local wf = require('libraries/windfield')
    local world = wf.newWorld(0, 2000)
    world:setQueryDebugDrawing(true)
    world.draw_query_for_n_frames = 1

    current = world

    for _, v in pairs({...}) do
        if type(v) == 'table' then
            assert(type(v[2]) == 'table', 'Your second argument must be a table.')

            local class, flags = unpack(v)

            assert(type(flags['ignores']) == 'table', 'The ignores argument must be a table.')

            world:addCollisionClass(class, flags)
        else
            world:addCollisionClass(v)
        end
    end

    return world
end

function newCollider(object, data)
    local collider = {}
    local x, y, width, height = object.x, object.y, object.width, object.height

    if object.shape == 'polygon' then
        local polygon = {}

        for _, vec2 in ipairs(object.polygon) do
            table.insert(polygon, vec2.x)
            table.insert(polygon, vec2.y)
        end

        collider = current:newPolygonCollider(polygon)
    end

    if object.shape == 'point' then
        collider = current:newRectangleCollider(x, y, 1, 1)
    end

    if object.shape == 'rectangle' or object.shape == 'point' then
    if object.width == 0 or object.height == 0 then
            collider = current:newLineCollider(x, y, x + width, y + height)
        else
            collider = current:newRectangleCollider(x, y, width, height)
        end
    end

    if object.shape == 'ellipse' then
        collider = current:newCircleCollider(x + width / 2, y + height / 2, width / 2)
    end

    collider:setFixedRotation(true)
    collider:setFriction(0)
    collider:setType(data.type or 'static')
    collider:setCollisionClass(data.class)
    collider:setMass(data.mass or 0)
    collider:setAngle(math.rad(object.rotation))

    return collider
end