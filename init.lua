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
local function load(name, ...)
	assert(loadfile(modlib.mod.get_resource(name .. ".lua")))(...)
end
load"conf" -- Load JSON configuration stored in worldpath
load"closest_color" -- Closest color finder, uses linear search / k-d tree depending on number of colors
load("texture_reader", os_execute) -- Texture reader, reads textures, uses Java program
load"dithering" -- Error diffusion dithering
load"obj_reader" -- OBJ reader, reads simple OBJ models
load"node_map_reader" -- Node map reader, reads minetestmapper-colors.txt like files
load"main" -- Main : Actual API for placing of models using VoxelManip
load("chatcommands", os_execute) -- Chatcommands for making use of the API

-- Tests, not intended for production use
--[[minetest.register_on_mods_loaded(function()
    extend("test")
end)]]