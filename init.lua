voxelizer={}
minetest.mkdir(minetest.get_worldpath().."/media") -- Create media dir
local os_execute = os.execute or (minetest.request_insecure_environment() or
    error("Please add voxelizer to the trusted mods in settings, or disable it. See the Readme for details.")).os.execute
extend_mod("voxelizer", "conf") -- Load JSON configuration stored in worldpath
extend_mod("voxelizer", "vector") -- Own vector lib, operating on lists
extend_mod("voxelizer", "closest_color") -- Closest color finder, uses linear search / k-d tree depending on number of colors
extend_mod("voxelizer", "texture_reader") -- Texture reader, reads textures, uses Java program
voxelizer.set_os_execute(os_execute) -- Passing insecure os.execute while keeping it local
extend_mod("voxelizer", "dithering") -- Error diffusion dithering
extend_mod("voxelizer", "obj_reader") -- OBJ reader, reads simple OBJ models
extend_mod("voxelizer", "node_map_reader") -- Node map reader, reads minetestmapper-colors.txt like files
extend_mod("voxelizer", "main") -- Main : Actual API for placing of models using VoxelManip
extend_mod("voxelizer", "chatcommands") -- Chatcommands for making use of the API
voxelizer.set_os_execute(os_execute) -- Passing insecure os.execute while keeping it local

-- Tests : Only uncomment if you actually want to test something !
--[[minetest.register_on_mods_loaded(function()
    extend_mod("voxelizer", "test")
end)]]