function get_media(name)
    return minetest.get_worldpath().."/media/"..name
end

function get_obj_bounding_box(vertexes)
    local min={math.huge, math.huge, math.huge}
    local max={-math.huge, -math.huge, -math.huge}
    for _, vertex in pairs(vertexes) do
        for i=1, 3 do
            if vertex[i] < min[i] then
                min[i]=vertex[i]
            elseif vertex[i] > max[i] then
                max[i]=vertex[i]
            end
        end
    end
    return min, max
end

function get_voxel_area(min, max, vm)
    local vox_min, vox_max = {}, {}
    for i=1, 3 do
        if min[i] < 0 then vox_min[i]=math.floor(min[i]) else vox_min[i]=math.ceil(min[i]) end
        if max[i] < 0 then vox_max[i]=math.floor(max[i]) else vox_max[i]=math.ceil(max[i]) end
    end -- Floor/ceil min/max for VoxelArea
    vox_min, vox_max = vector.convert(vector.subtract(vox_min, {16,16,16})), vector.convert(vector.add(vox_max, {16,16,16}))
    local c1, c2 = vm:read_from_map(vox_min, vox_max)
    local area = VoxelArea:new{MinEdge=c1, MaxEdge=c2}
    return area
end

local steps = 6
local min_amount = 0.1
function place_obj(params)
    local path_to_obj, path_to_texture, path_to_nodemap, pos1, pos2, scale = params.model, params.texture, params.nodemap, params.pos1, params.pos2, params.scale
    local steps = params.precision or steps
    local min_amount = (params.min_amount or min_amount) * 255 * steps * steps
    local obj_content = modlib.file.read(path_to_obj)
    if not obj_content then
        return ("OBJ doesn't exist."):format(path_to_obj)
    end
    if not modlib.file.exists(path_to_texture) then
        return ("Texture doesn't exist."):format(path_to_texture)
    end
    local nodemap_content=modlib.file.read(path_to_nodemap)
    if not nodemap_content then
        return ("Nodemap doesn't exist."):format(path_to_nodemap)
    end
    local nodemap = read_node_map(nodemap_content)
    local colors = modlib.table.keys(nodemap)
    modlib.table.map(colors, rgb_number_to_table)
    local closest_color_finder = closest_color_finder(colors)
    local texture = read_texture(path_to_texture)
    if params.dithering then
        texture = dither(texture, closest_color_finder, params.dithering)
    end
    local filtering
    if params.filtering == "bilinear" then
        filtering = function(pos_uv) return bilinear_filtering(texture, pos_uv) end
    else -- default : nearest
        filtering = function(pos_uv) return nearest_filtering(texture, pos_uv) end
    end
    local triangle_consumer_factory, transform, min, max, area, nodes
    nodes={} -- VoxelArea index -> colors
    local vm = minetest.get_voxel_manip()

    local data

    triangle_consumer_factory=function(vertexes)
        min, max = get_obj_bounding_box(vertexes)
        if pos2 then -- do something with vertexes
            -- transforms a vector : OBJ space -> MT space from pos1 to pos2
            -- steps :
            -- 0. translate to 0
            -- 1. normalize it (squash/stretch it to a 1x1x1 cube)
            -- 2. stretch it to pos1 - pos2 thingy
            -- 3. translate to pos1
            local mt_space = vector.subtract(pos2, pos1)
            local obj_space = vector.subtract(max, min)
            local transform_vec = vector.divide(mt_space, obj_space)
            function transform(v)
                local vec = vector.subtract(v, min) -- translate to 0
                local res = vector.multiply_vector(vec, transform_vec)
                res = vector.add(res, pos1)
                return res
            end
        elseif scale then
            function transform(v)
                local res = vector.add(vector.multiply(v, scale), pos1)
                return res
            end
        else
            function transform(v)
                local res = vector.add(v, pos1)
                return res
            end
        end
        modlib.table.map(vertexes, transform) -- Transforming the vertices to MT space
        area = get_voxel_area(transform(min), transform(max), vm)

        data = vm:get_data()

        local is_protected = function(pos) return true end
        if params.playername and not params.protection_bypass then
            --is_protected = function(pos) return minetest.is_protected(pos, params.playername) end
        end

        local is_mergeable = function(index) return true end
        if params.merge_mode == "add" then
            is_mergeable = function(index)
                local d = data[index]
                if d == minetest.CONTENT_AIR or d == minetest.CONTENT_IGNORE or d == minetest.CONTENT_UNKNOWN then
                    return true
                end
                return false
            end
        elseif params.merge_mode == "intersection" then
            is_mergeable = function(index)
                local d = data[index]
                if d == minetest.CONTENT_AIR or d == minetest.CONTENT_IGNORE then
                    return false
                end
                return true
            end
        end

        local merge_at = function(pos, index) return is_protected(pos) and is_mergeable(index) end

        return function(points, uvs)
            local b1=vector.subtract(points[2], points[1]) -- First basis vector, vertices
            local len1=vector.length(b1)
            local b2=vector.subtract(points[3], points[1]) -- Second basis vector, vertices
            local len2=vector.length(b2)

            local u1=vector.subtract(uvs[2], uvs[1]) -- First basis vector, UVs
            local u2=vector.subtract(uvs[3], uvs[1]) -- Second basis vector, UVs
            for l1=0,1,1/(len1*steps) do -- Lambda 1 - scalar of first basis
                for l2=0,1,1/(len2*steps) do -- Lambda 2 - 2nd one
                    if l1+l2 <= 1 then -- On triangle
                        local res = vector.add(vector.multiply(b1, l1), vector.multiply(b2, l2))
                        local pos = vector.add(points[1], res)
                        local floor_pos = vector.convert(vector.floor(pos))
                        local index = area:indexp(floor_pos)
                        if merge_at(floor_pos, index) then
                            nodes[index] = nodes[index] or {amount=0}
                            nodes[index].amount = nodes[index].amount + 1
                            -- Now finding the same coord on texture
                            local pos_uv = vector.add(uvs[1], vector.add(vector.multiply(u1, l1), vector.multiply(u2, l2)))
                            local color_uv = get_texture_color_at(texture, math.floor(pos_uv[1]*(texture.width-0.0000001)), math.floor((1-pos_uv[2])*(texture.height-0.0000001)))
                            nodes[index][color_uv] = ((nodes[index][color_uv]) and (nodes[index][color_uv]+1)) or 1
                        end
                    end
                end
            end
        end
    end

    local get_color
    if params.color_choosing == "best" then
        function get_color(node)
            local best_color = -math.huge
            local best_amount = -math.huge
            for color, amount in pairs(node) do
                local color = rgba_number_to_table(color)
                if amount >= best_amount then
                    best_color = color
                    best_amount = amount
                end
            end
            return best_color, best_amount
        end
    else -- average
        function get_color(node)
            local average_color = {0, 0, 0, 0}
            local sumcount = 0
            for color, count in pairs(node) do
                sumcount = sumcount + count
                local color = rgba_number_to_table(color)
                average_color = vector.add(average_color, vector.multiply(color, count))
            end
            average_color = vector.multiply(average_color, 1/sumcount)
            return average_color
        end
    end

    read_obj(obj_content, triangle_consumer_factory)

    for index, node in pairs(nodes) do
        local amount = node.amount
        node.amount = nil

        if params.weighed or true then
            for c, v in pairs(node) do
                local k = rgba_number_to_table(c)
                node[c] = v * k[1]
            end
        end

        local best_color = get_color(node)
        if best_color then
            if best_color[1]*amount >= min_amount then
                table.remove(best_color, 1)
                local closest_color = closest_color_finder(best_color)
                closest_color = rgb_table_to_number(closest_color)
                data[index] = nodemap[closest_color]
            end
        end
    end

    vm:set_data(data)
    vm:calc_lighting()
    vm:update_liquids()
    vm:write_to_map()
end
