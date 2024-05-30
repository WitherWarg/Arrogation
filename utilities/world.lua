function newWorld(xg, yg, sleep, collision_classes)
    if type(sleep) == 'table' then
        collision_classes = sleep
        sleep = nil
    end

    local wf = require('libraries/windfield')
    local world = wf.newWorld(xg, yg, sleep)
    world:setQueryDebugDrawing(true)
    world.draw_query_for_n_frames = 1

    for _, v in pairs(collision_classes) do
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