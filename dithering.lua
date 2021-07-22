local vector = modlib.vector

dithering_matrices = {
    {
        name = "Floyd-Steinberg",
        {x_off=1, 7/16},
        {x_off=-1, 3/16, 5/16, 1/16}
    },
    {
        name = "Jarvis, Judice & Ninke",
        {x_off = 1,  7/48, 5/48},
        {x_off = -2, 3/48, 5/48, 7/48, 5/48, 3/48},
        {x_off = -2, 1/48, 3/48, 5/48, 3/48, 1/48}
    },
    {
        name = "Stucke",
        {x_off = 1,  8/42, 4/42},
        {x_off = -2, 2/42, 4/42, 8/42, 4/42, 2/42},
        {x_off = -2, 1/42, 2/42, 4/42, 2/42, 1/42}
    },
    {
        name = "Atkinson",
        {x_off=1, 1/8, 1/8},
        {x_off = -1, 1/8, 1/8, 1/8},
        {x_off =   0, 1/8}
    },
    {
        name = "Burkes",
        {x_off = 1,  8/42, 4/42},
        {x_off = -2, 2/42, 4/42, 8/42, 4/42, 2/42}
    },
    {
        name = "Sierra",
        {x_off = 1, 4/16, 3/16},
        {x_off = -2, 1/16, 2/16, 3/16, 2/16, 1/16}
    },
    {
        name = "Sierra Lite",
        {x_off = 1, 2/4},
        {x_off = -1, 1/4, 1/4}
    },
    {
        name = "Two row Sierra",
        {x_off = 1,  5/32, 3/32},
        {x_off = -2, 2/32, 4/32, 5/32, 4/32, 2/32},
        {x_off = -1, 2/32, 3/32, 2/32}
    },
    {
        name = "No dithering"
    }
}
function dither(texture, closest_color_finder, matrix)
    matrix = matrix or dithering_matrices[1]
    local newtexture = {width = texture.width, height = texture.height}
    for x=0, texture.width-1 do
        for y=0, texture.height-1 do
            local color = rgba_number_to_table(get_texture_color_at(texture, x, y))
            local alpha = color[1]
            table.remove(color, 1)
            local closest_color = closest_color_finder(color)
            set_texture_color_at(newtexture, x, y, rgba_tuple_to_number(alpha, unpack(closest_color)))
            local error = vector.subtract(closest_color, color) -- Difference between closest color - actual color
            table.insert(error, 1, 0)
            -- now push the error to unprocessed pixels
            for ydif, line in ipairs(matrix) do
                for index, diff in ipairs(line) do
                    local nx, ny = x + index + line.x_off-1, y+ydif-1
                    if nx >= 0 and ny >= 0 and nx <= texture.width-1 and ny <= texture.height-1 then
                        local tab = assert(rgba_number_to_table(get_texture_color_at(texture, x, y)))
                        local target_color = vector.floor(vector.clamp(vector.add(tab, vector.multiply_scalar(error, diff)), 0, 255))
                        set_texture_color_at(texture, x, y, rgba_table_to_number(target_color))
                    end
                end
            end
        end
    end
    return newtexture
end