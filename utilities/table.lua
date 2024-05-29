function table.print(t, keys)
    local output = ""

    for key1, value in pairs(t) do
        output = output .. key1 .. ': ' .. tostring(value)

        if keys and #keys > 0 then
            for _, key2 in ipairs(keys) do
                output = output .. ', ' .. value[key2]
            end
        end
        
        output = output .. '\n'
    end

    print(string.sub(output, 1, -2))
end

function table.merge(...)
    local result = {}

    for _, t in ipairs({...}) do
        for key, value in pairs(t) do
            result[key] = value
        end
    end

    return result
end

function table.clone(t)
    local result = {}

    for key, value in pairs(t) do
        result[key] = value
    end

    return result
end