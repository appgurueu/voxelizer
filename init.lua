voxelizer={}
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
modlib.mod.extend("voxelizer", "conf") -- Load JSON configuration stored in worldpath
modlib.mod.extend("voxelizer", "vector") -- Own vector lib, operating on lists
modlib.mod.extend("voxelizer", "closest_color") -- Closest color finder, uses linear search / k-d tree depending on number of colors
modlib.mod.extend("voxelizer", "texture_reader") -- Texture reader, reads textures, uses Java program
voxelizer.set_os_execute(os_execute) -- Passing insecure os.execute while keeping it local
modlib.mod.extend("voxelizer", "dithering") -- Error diffusion dithering
modlib.mod.extend("voxelizer", "obj_reader") -- OBJ reader, reads simple OBJ models
modlib.mod.extend("voxelizer", "node_map_reader") -- Node map reader, reads minetestmapper-colors.txt like files
modlib.mod.extend("voxelizer", "main") -- Main : Actual API for placing of models using VoxelManip
modlib.mod.extend("voxelizer", "chatcommands") -- Chatcommands for making use of the API
voxelizer.set_os_execute(os_execute) -- Passing insecure os.execute while keeping it local

-- Tests : Only uncomment if you actually want to test something !
--[[minetest.register_on_mods_loaded(function()
    modlib.mod.extend("voxelizer", "test")
end)]]