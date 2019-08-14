math.randomseed(os.time())

local function random_color()
    color={}
    for i=1, 3 do color[i]=math.random(0, 255) end
    return color
end

local function random_colors(k)
    local random_colors={}
    for i=1, k or 10000 do
        table.insert(random_colors, random_color())
    end
    return random_colors
end

local function test_correctness()
    local k=0
    for i = 1, 1000 do
        local colors=random_colors(1000)
        local tree=kd_closest_color_finder(colors)
        local color=random_color() --colors[math.random(1, 20)]
        local linear, lin_distance=linear_closest_color_finder(colors)(color)
        local kd, kd_distance=tree(color)
        if lin_distance == kd_distance then
            k=k+1
        end
    end
    print(tostring(k).." of 1000 samples")
end

local function test_performance()
    local color=random_color() --colors[math.random(1, 20)]
    local colors=random_colors(10000)
    local tree=kd_closest_color_finder(colors)
    local linear=linear_closest_color_finder(colors)
    for _, tree in ipairs({tree, linear}) do
        local x = os.clock()
        local s = 0
        for i = 1, 1000 do kd, kd_distance=tree(color) end
        print(string.format("elapsed time: %.2f", os.clock() - x))
    end
end

print("Closest Color Finder Test : ")
test_correctness()
test_performance()

local function test_texture_reader()
    image = read_texture(get_resource("voxelizer", "test/image.png"))
    print("Texture Reader Test : ")
    print(color_to_number(color_to_table(get_texture_color_at(image, 0, 0))) == 0x00000000)
    print(color_to_number(color_to_table(get_texture_color_at(image, 1, 0))) == 0xFFFF0000)
    print(color_to_number(color_to_table(get_texture_color_at(image, 0, 1))) == 0xFF00FF00)
    print(color_to_number(color_to_table(get_texture_color_at(image, 1, 1))) == 0xFF0000FF)
end

test_texture_reader()

local function test_nodemap_reader()
    print("Nodemap Reader Test : ")
    local color_to_cid = read_node_map(file_ext.read("/usr/share/games/minetest/minetestmapper-colors.txt"))
    for c, cid in pairs(color_to_cid) do
        print(string.format("%x", c).." -> "..minetest.get_name_from_content_id(cid))
    end
end

test_nodemap_reader()