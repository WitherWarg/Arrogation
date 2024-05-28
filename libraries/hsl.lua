local function to(p, q, t)
    if t < 0 then
        t = t + 1
    end

    if t > 1 then
        t = t - 1
    end

    if t < 1/6 then
        return p + (q - p) * 6 * t
    end

    if t < 1/2 then
        return q
    end

    if t < 2/3 then
        return p + (q - p) * (2/3 - t) * 6
    end

    return p
end

local function hsl(h, s, l, a)
    h, s, l = h / 360, s / 100, l / 100

    if a then
        a = a / 100
    end

    if s == 0 then
        return l, l, l, a
    end

    local q = l < 1/2 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q

    return to(p, q, h + 1/3), to(p, q, h), to(p, q, h - 1/3), a
end

return hsl