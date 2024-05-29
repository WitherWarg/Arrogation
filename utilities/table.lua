function table.print(t, keys)
    local output = ""
    local i = 0
    for key, value in pairs(t) do
        i = i + 1
        output = output .. key .. ': ' .. tostring(value)

        if keys and #keys > 0 then
            for _, key in ipairs(keys) do
                output = output .. ', ' .. value[key]
            end
        end
        
        if i < #t then
            output = output .. '\n'            
        end
    end

    print(output)
end

function table.merge(...)
    local result = {}

    for _, t in ipairs({...}) do
        for _, value in ipairs(t) do
            table.insert(result, value)
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