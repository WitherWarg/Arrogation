local key_states = {}

local isDown = love.keyboard.isDown

local function getKeys(...)
    local keys = {}

    for _, v in ipairs({...}) do
        if type(v) == 'table' then
            keys = table.merge(keys, v)
        end

        if type(v) == 'string' or type(v) == 'number' then
            table.insert(keys, v)
        end
    end

    for _, k in ipairs(keys) do
        if not key_states[k] then
            key_states[k] = { last = false }
        end

        if type(k) == 'number' then
            key_states[k].now = love.mouse.isDown(k)
        else
            key_states[k].now = isDown(k)
        end
    end

    return keys
end

love.keyboard.isDown = function(...)
    local keys = getKeys(...)

    local is_down = false

    for _, k in ipairs(keys) do
        is_down = key_states[k].now or is_down
    end

    return is_down
end

love.keyboard.isUp = function(...)
    local keys = getKeys(...)

    local is_up = false

    for _, k in ipairs(keys) do
        is_up = not key_states[k].now or is_up
    end

    return is_up
end

love.keyboard.isPressed = function(...)
    local keys = getKeys(...)

    local is_pressed = false

    for _, k in ipairs(keys) do
        is_pressed = ( key_states[k].now and not key_states[k].last) or is_pressed
    end

    return is_pressed
end

love.keyboard.isReleased = function(...)
    local keys = getKeys(...)

    local is_released = false

    for _, k in ipairs(keys) do
        is_released = ( not key_states[k].now and key_states[k].last) or is_released
    end

    return is_released
end

love.keyboard.update = function()
    for k, _ in pairs(key_states) do
        key_states[k].last = key_states[k].now
    end
end

local actions = {
    right = { keys = {'right', 'd'}, method = 'isDown' },
    left = { keys = {'left', 'a'}, method = 'isDown' },

    jump = { keys = {'up', 'w'} },
    dash = { keys = {'space'} },

    pause = { keys = {'escape', 'p'} },

    left_click = { keys = {1} },
    right_click = { keys = {2} },
}

function input(action, method)
    return love.keyboard[method or actions[action].method or 'isPressed'](actions[action].keys)
end