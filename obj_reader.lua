--obj_content: string, OBJ file content; triangle_consumer_factory: function(vertexes), returns triangle_consumer: function(vertexes, uvs)
-- TODO add support for colors
function read_obj(obj_content, triangle_consumer_factory)
    print(obj_content)
    local lines=string_ext.split_without_limit(obj_content, "\n")
    local iterator, _, index=ipairs(lines)

    ::next_object::
    -- Vertices
    local vertices = {}
    local counter=1
    index, line=iterator(lines, index)
    repeat
        if string_ext.starts_with(line, "v ") then
            local parts=string_ext.split(line:sub(3), " ", 4) -- x, y, z, unneeded
            local x, y, z = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
            if x and y and z then
                vertices[counter] = {x,y,z}
            end
            counter = counter + 1
        end
        index, line=iterator(lines, index)
    until string_ext.starts_with(line, "vt ")

    --UVs
    local uvs={}
    counter=1
    repeat
        if string_ext.starts_with(line, "vt ") then
            local parts=string_ext.split(line:sub(4), " ", 3)
            local x, y = tonumber(parts[1]), tonumber(parts[2])
            if x and y then
                uvs[counter] = {x, y}
            end
            counter = counter + 1
        end
        index, line=iterator(lines, index)
    until string_ext.starts_with(line, "f ")

    local triangle_consumer=triangle_consumer_factory(vertices)
    --Faces (need to be triangles), polygons are ignored
    repeat
        if string_ext.starts_with(line, "f ") then --Face
            local parts=string_ext.split(line:sub(3), " ", 4)
            local verts={}
            local texs={}
            for i=1, 3 do
                local indices = string_ext.split(parts[i], "/", 3)
                local vert, uv = tonumber(indices[1]), tonumber(indices[2])
                verts[i] = vertices[vert]
                texs[i] = uvs[uv]
                if not verts[i] or not texs[i] then goto invalid end
            end
            triangle_consumer(verts, texs)
            ::invalid::
        elseif string_ext.starts_with(line, "o ") then
            goto next_object
        end
        index, line=iterator(lines, index)
    until not line
end