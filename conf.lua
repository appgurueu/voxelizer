local int = function(value) if value % 1 ~= 0 then return "Integer instead of float expected." end end
local conf_spec = {
    type = "table",
    children = {
        max_precision = {
            type = "number",
            func = function(value) if value % 1 ~= 0 then return "Integer instead of float expected." end end
        },
        download = {
            type = "boolean"
        },
        defaults = {
            type = "table",
            possible_keys = {
                model = {type = "string"},
                texture = {type = "string"},
                nodemap = {type = "string"}
            },
            required_keys = {
                min_density = {type = "number", range = {0, 1}},
                precision = {
                    type = "number",
                    range = {1, 100},
                    func = int
                },
                dithering = {
                    type = "number",
                    range = {1, 10},
                    func = int
                },
                placement = {
                    type = "number",
                    range = {1, 3},
                    func = int
                },
                color_choosing = {
                    type = "number",
                    range = {1, 2},
                    func = int
                },
                filtering = {
                    type = "number",
                    range = {1, 2},
                    func = int
                }
            }
        }
    },
}

config=conf.import("voxelizer", conf_spec)
local mediapath = minetest.get_modpath("voxelizer").."/media/"
local fallback_defaults = {texture = mediapath.."character.png", model =  mediapath.."character.obj", nodemap = mediapath.."colors.txt"}
for key, alt in pairs(fallback_defaults) do
    if config.defaults[key] == nil then
        config.defaults[key] = alt
    end
end
