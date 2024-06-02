function table.print(t, keys)
    assert(type(t) == 'table', "Must give table.print a table")

    local output = ""

    for key1, value in pairs(t) do
        output = output .. tostring(key1) .. ': ' .. tostring(value)

        if keys and #keys > 0 then
            for _, key2 in ipairs(keys) do
                output = output .. ', ' .. tostring(value[key2])
            end
        end
        
        output = output .. '\n'
    end

    if output == '' then
        print("Table is empty")
        return
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

function table.len(t)
    local i = 0
    for _, _ in pairs(t) do
        i = i + 1
    end
    return i
end