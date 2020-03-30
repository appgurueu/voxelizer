--obj_content: string, OBJ file content; triangle_consumer_factory: function(vertexes), returns triangle_consumer: function(vertexes, uvs)
-- TODO add support for colors
function read_obj(obj_content, triangle_consumer_factory)
    local lines=modlib.text.split_without_limit(obj_content, "\n")
    local iterator, _, index=ipairs(lines)

    local function read_object()
        -- Vertices
        local vertices = {}
        local counter=1
        index, line=iterator(lines, index)
        repeat
            if modlib.text.starts_with(line, "v ") then
                local parts=modlib.text.split(line:sub(3), " ", 4) -- x, y, z, unneeded
                local x, y, z = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
                if x and y and z then
                    vertices[counter] = {x,y,z}
                end
                counter = counter + 1
            end
            index, line=iterator(lines, index)
        until modlib.text.starts_with(line, "vt ")

        --UVs
        local uvs={}
        counter=1
        repeat
            if modlib.text.starts_with(line, "vt ") then
                local parts=modlib.text.split(line:sub(4), " ", 3)
                local x, y = tonumber(parts[1]), tonumber(parts[2])
                if x and y then
                    uvs[counter] = {x, y}
                end
                counter = counter + 1
            end
            index, line=iterator(lines, index)
        until modlib.text.starts_with(line, "f ")

        local triangle_consumer=triangle_consumer_factory(vertices)
        --Faces (need to be triangles), polygons are ignored
        repeat
            if modlib.text.starts_with(line, "f ") then --Face
                local parts=modlib.text.split(line:sub(3), " ", 4)
                local verts={}
                local texs={}
                local valid = true
                for i=1, 3 do
                    local indices = modlib.text.split(parts[i], "/", 3)
                    local vert, uv = tonumber(indices[1]), tonumber(indices[2])
                    verts[i] = vertices[vert]
                    texs[i] = uvs[uv]
                    if not verts[i] or not texs[i] then
                        valid = false
                        break
                    end
                end
                if valid then
                    triangle_consumer(verts, texs)
                end
            elseif modlib.text.starts_with(line, "o ") then
                read_object()
            end
            index, line=iterator(lines, index)
        until not line
    end
    read_object()
end