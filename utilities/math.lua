function math.sign(n)
    if n == 0 then
        return 0
    end

    return n / math.abs(n)
end

function math.clamp(a, b, c)
    assert(b <= c, 'Min must be less or equal than Max')

    return math.min( math.max(a, b), c )
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end