function table.print(t)
    for key, value in pairs(t) do
        print(key .. ': ' .. tostring(value))
    end
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