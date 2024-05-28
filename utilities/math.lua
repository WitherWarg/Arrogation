function math.sign(n)
    return ( n / math.abs(n) ) or 0
end

function math.clamp(a, b, c)
    assert(b < c, 'Min must be less than Max')

    return math.min( math.max(a, b), c )
end