vector={}

vector.subtract=function(v1, v2)
    local res={}
    for i=1, #v1 do
        res[i] = v1[i]-v2[i]
    end
    return res
end

vector.add=function(v1, v2)
    local res={}
    for i=1, #v1 do
        res[i] = v1[i]+v2[i]
    end
    return res
end

vector.multiply_vector=function(v1, v2)
    local res={}
    for i=1, #v1 do
        res[i] = v1[i]*v2[i]
    end
    return res
end

-- Scalar multiplication
vector.multiply=function(v1, s2)
    local res={}
    for i=1, #v1 do
        res[i] = v1[i]*s2
    end
    return res
end

vector.divide=function(v1, v2)
    local res={}
    for i=1, #v1 do
        if v2[i] ~= 0 then
            res[i] = v1[i]/v2[i]
        else
            res[i] = 0
        end
    end
    return res
end

vector.length=function(v)
    local res=0
    for i=1, #v do
        res = res + (v[i] * v[i])
    end
    return math.sqrt(res)
end

vector.floor=function(v)
    local res={}
    for i=1, #v do
        res[i] = math.floor(v[i])
    end
    return res
end

vector.convert=function(v)
    return {x=v[1], y=v[2], z=v[3]}
end

vector.to_minetest=vector.convert

vector.from_minetest = function(v)
    return {v.x, v.y, v.z}
end

vector.clamp=function(v, min, max)
    local res={}
    for i=1, #v do
        res[i] = math.max(min, math.min(v[i], max))
    end
    return res
end

vector.to_string = function(v)
    local c = {}
    for i=1, #v do
        c[i] = number_ext.round(v[i], 100)
    end
    return table.concat(c, ", ")
end