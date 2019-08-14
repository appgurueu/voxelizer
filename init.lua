voxelizer={}
minetest.mkdir(minetest.get_worldpath().."/media") -- Create media dir
--cmd_ext.register_chatcommand()
extend_mod("voxelizer", "conf") -- Load JSON configuration stored in worldpath
extend_mod("voxelizer", "vector") -- Own vector lib, operating on lists
extend_mod("voxelizer", "closest_color") -- Closest color finder, uses linear search / k-d tree depending on number of colors
extend_mod("voxelizer", "texture_reader") -- Texture reader, reads textures, uses Java program
extend_mod("voxelizer", "dithering") -- Error diffusion dithering
extend_mod("voxelizer", "obj_reader") -- OBJ reader, reads simple OBJ models
extend_mod("voxelizer", "node_map_reader") -- Node map reader, reads minetestmapper-colors.txt like files
extend_mod("voxelizer", "main") -- Main : Actual API for placing of models using VoxelManip
extend_mod("voxelizer", "chatcommands") -- Chatcommands for making use of the API

-- Tests : Only uncomment if you actually want to test something !
--[[minetest.register_on_mods_loaded(function()
    extend_mod("voxelizer", "test")
end)]]