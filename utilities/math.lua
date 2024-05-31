function math.sign(n)
    if n > 0 then
        return 1
    end

    if n < 0 then
        return -1
    end

    return 0
end

function math.clamp(a, b, c)
    return math.min( math.max(a, b), c )
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end