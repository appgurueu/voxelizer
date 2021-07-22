modlib.mod.create_namespace()
minetest.mkdir(minetest.get_worldpath().."/media") -- Create media dir
local os_execute_base = os.execute or (minetest.request_insecure_environment() or
    error("Please add voxelizer to the trusted mods in settings, or disable it. See the Readme for details.")).os.execute
local function os_execute(command, ...)
    local args = {}
    for i, a in pairs{...} do
        args[i] = table.concat(modlib.table.map(modlib.text.split(a, "'"), function(p) return "'"..p.."'" end), [["'"]])
    end
    return os_execute_base(command.." "..table.concat(args, " "))
end
local extend = modlib.mod.extend
extend("conf") -- Load JSON configuration stored in worldpath
extend("closest_color") -- Closest color finder, uses linear search / k-d tree depending on number of colors
extend("texture_reader") -- Texture reader, reads textures, uses Java program
voxelizer.set_os_execute(os_execute) -- Passing insecure os.execute while keeping it local
extend("dithering") -- Error diffusion dithering
extend("obj_reader") -- OBJ reader, reads simple OBJ models
extend("node_map_reader") -- Node map reader, reads minetestmapper-colors.txt like files
extend("main") -- Main : Actual API for placing of models using VoxelManip
extend("chatcommands") -- Chatcommands for making use of the API
voxelizer.set_os_execute(os_execute) -- Passing insecure os.execute while keeping it local

-- Tests, not intended for production use
--[[minetest.register_on_mods_loaded(function()
    extend("test")
end)]]