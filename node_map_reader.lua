-- Reads a node map in a similar format as minetestmapper.txt
function read_node_map(minetestmapper_content)
    local lines=modlib.text.split_without_limit(minetestmapper_content, "\n")
    local iterator, _, index=ipairs(lines)
    local color_to_cid={}

    --Process lines
    index, line=iterator(lines, index)
    while line do
        parts=modlib.text.split(line, " ",5)
        if #parts >= 4 then
            local c_id=tonumber(parts[1], 16)
            if not c_id then c_id=minetest.get_content_id(parts[1]) end
            local r, g, b=tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])
            if c_id and r and g and b and minetest.get_name_from_content_id(c_id) ~= "unknown" and minetest.get_name_from_content_id(c_id) ~= "ignore" then color_to_cid[r*256*256+g*256+b]=c_id end
        end
        index, line=iterator(lines, index)
    end

    return color_to_cid
end