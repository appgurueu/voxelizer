local os_execute
function set_os_execute(os_exec)
    os_execute = os_exec
end

function rgba_number_to_table(number)
    local b = number % 256
    local g = math.floor(number / 256) % 256
    local r = math.floor(number / 256 / 256) % 256
    local a = math.floor(number / 256 / 256 / 256) % 256
    return {a, r, g, b}
end

function rgb_number_to_table(number)
    local b = number % 256
    local g = math.floor(number / 256) % 256
    local r = math.floor(number / 256 / 256) % 256
    return {r, g, b}
end

function rgba_tuple_to_number(a, r, g, b)
    return a*256*256*256+r*256*256+g*256+b
end

function rgba_table_to_number(table)
    return rgba_tuple_to_number(unpack(table))
end

function rgb_tuple_to_number(r, g, b)
    return r*256*256+g*256+b
end

function rgb_table_to_number(table)
    return rgb_tuple_to_number(unpack(table))
end

function get_texture_color_at(texture, x, y)
    return texture[x+y*texture.width+1]
end

function set_texture_color_at(texture, x, y, color)
    texture[x+y*texture.width+1] = color
end

function in_bounds(texture, x, y)
    return x >= 0 and y >= 0 and x < texture.width and x < texture.height
end

function nearest_filtering(texture, pos_uv)
    local x = math.min(math.floor(pos_uv[1]*texture.width), texture.width-1)
    local y = math.min(math.floor((1-pos_uv[2])*texture.height), texture.height-1)
    return get_texture_color_at(texture, x, y)
end

function bilinear_filtering(texture, pos_uv)
    local x = pos_uv[1]*texture.width
    local x_line = number_ext.round(x)
    local y = (1-pos_uv[2])*texture.height
    local y_line = number_ext.round(y)

    local affected, affected_alpha = 0, 0
    local avg_alpha = 0
    local avg = {0, 0, 0}
    for xf = -1, 1, 2 do
        local px = x+xf*0.5
        local f1 = math.max(0, xf*x_line-px)
        for xf = -1, 1, 2 do
            local py = y+xf*0.5
            local f2 = math.max(0, xf*y_line-py)
            local factor = f1 * f2
            if factor > 0 then
                local a, r, g, b = unpack(get_texture_color_at(texture, math.floor(px), math.floor(py)))
                affected = affected + factor * a
                avg = vector.add(avg, vector.multiply({r, g, b}, factor * a))
                affected_alpha = affected_alpha + factor
                avg_alpha = avg_alpha + factor * a
            end
        end
    end

    avg_alpha = avg_alpha / affected_alpha
    avg = vector.multiply(avg, 1 / affected)
    local color = {avg_alpha, unpack(avg)}
    return color
end

local errors = {
    "Output and input path need to be given",
    "Couldn't create output file",
    "Output or input file doesn't exist or can't be read/written",
    "File couldn't be written"
}

function read_texture(path_to_texture)
    local last_dot
    for i = path_to_texture:len(), 1, -1 do
        if path_to_texture:sub(i, i) == "." then
            last_dot = i
            break
        elseif path_to_texture:sub(i, i) == "/" then
            break
        end
    end
    local path_to_output
    if path_to_texture:sub(last_dot+1):lower() == "sif" then -- we can assume it's already .sif
        path_to_output = path_to_texture
    else -- else, convert
        if not last_dot then
            path_to_output = path_to_texture..".sif"
        else
            path_to_output = path_to_texture:sub(1, last_dot-1)..".sif"
        end
        local response_code = os_execute('java -classpath "'..minetest.get_modpath("voxelizer")..'/production" TextureLoader "'..path_to_texture..'" "'..path_to_output..'"')
        if response_code ~= 0 then
            return errors[response_code] or "Texture couldn't be converted"
        end
    end

    local texture_content = io.open(path_to_output, "rb")
    -- Image ending : .sif (Simple Image Format)
    -- 4 bytes image header (2 bytes width, 2 bytes height)
    -- Content : 4 byte ARGB colors
    local image={}
    image.width = texture_content:read(1):byte()*255+texture_content:read(1):byte()
    image.height = texture_content:read(1):byte()*255+texture_content:read(1):byte()
    local bytes = texture_content:read("*all")
    for i=1, bytes:len(), 4 do
        table.insert(image, rgba_tuple_to_number(bytes:byte(i), bytes:byte(i+1), bytes:byte(i+2), bytes:byte(i+3)))
    end
    texture_content:close()
    return image
end