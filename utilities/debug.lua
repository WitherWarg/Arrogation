---@diagnostic disable: deprecated

local font = love.graphics.newFont(30)
local margin = 20

function debug(...)
    local count = select('#', ...)
    
    if count == 0 then
        return
    end

    local values = {}
    local longest = ''
    local ouput = '%s'

    for i = 1, count do
        local v = tostring(select(i, ...))
        
        values[i] = v

        if string.len(longest) < string.len(v) then
            longest = values[i]
        end

        if i > 1 then
            ouput = ouput .. '\n%s'
        end
    end

    love.graphics.push('all')
        love.graphics.setFont(font)

        local width, height = font:getWidth(longest), font:getHeight() * count

        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 10, 10, width + margin, height + margin)


        love.graphics.setColor(hsl(0, 0, 100))
        love.graphics.print( string.format( ouput, unpack(values) ), margin, margin )
    love.graphics.pop()
end