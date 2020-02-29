local os_execute = os.execute
function set_os_execute(os_exec)
    os_execute = os_exec
    set_os_execute = nil
end
local defaults = config.defaults

minetest.register_privilege("protection_bypass", {
    description = "Can bypass protection",
    give_to_admin = true,
    give_to_singleplayer = true
})

minetest.register_privilege("voxelizer", {
    description = "Can use the voxelizer mod",
    give_to_admin = true,
    give_to_singleplayer = true
})

cmdlib.register_chatcommand("vox", {
    description = "Voxelizer",
    privs = {voxelizer = true},
    func = function(sendername, params)
        return false, "Use the commands of the voxelizer mod using /vox <command> {params} - for a list of commands do /help vox."
    end
})

function get_setting_int(playername, settingname)
    local setting = minetest.get_player_by_name(playername):get_meta():get_int("voxelizer_"..settingname)
    return setting ~= 0 and setting
end

function set_setting_int(playername, settingname, value)
    return minetest.get_player_by_name(playername):get_meta():set_int("voxelizer_"..settingname, value)
end

function get_setting_float(playername, settingname)
    local setting = minetest.get_player_by_name(playername):get_meta():get_float("voxelizer_"..settingname)
    return setting ~= 0 and setting
end

function set_setting_float(playername, settingname, value)
    return minetest.get_player_by_name(playername):get_meta():set_float("voxelizer_"..settingname, value)
end

function get_setting(playername, settingname)
    local setting = minetest.get_player_by_name(playername):get_meta():get_string("voxelizer_"..settingname)
    return setting ~= "" and setting
end

function set_setting(playername, settingname, value)
    return minetest.get_player_by_name(playername):get_meta():set_string("voxelizer_"..settingname, value)
end

function register_setting_command(commandname, values, settingname)
    settingname = settingname or commandname
    local root = modlib.number.round(math.sqrt(#values))
    local display_vals = {}
    for index, val in ipairs(values) do
        table.insert(display_vals, index..". "..val)
    end
    cmdlib.register_chatcommand("vox "..commandname, {
        description = "Get and list or set player-specific setting "..settingname,
        params = "[index]",
        func = function(sendername, params)
            if params.index then
                params.index = tonumber(params.index)
                if not params.index or params.index < 1 or params.index > #values or params.index % 1 > 0 then
                    return false, "Index out of range : Needs to be an integer between 1 and "..#values
                end
                set_setting_int(sendername, settingname, params.index)
                return true, string.format('Setting "%s" was set to %d - "%s"', settingname, params.index, values[params.index])
            end
            local display_vals = {unpack(display_vals)}
            local setting = get_setting_int(sendername, settingname, params.index) or defaults[settingname]
            if display_vals[setting] then
                display_vals[setting] = minetest.get_color_escape_sequence("#FFFF66")..display_vals[setting].." (active)"..minetest.get_color_escape_sequence("#FFFFFF")
            end
            local options = {}
            for i=1, #values, root do
                local row = {unpack(display_vals, i, i+root-1)}
                table.insert(options, table.concat(row, ", "))
            end
            return nil, table.concat(options, "\n")
        end
    })
end

function register_file_command(commandname, settingname)
    settingname = settingname or commandname
    cmdlib.register_chatcommand("vox "..commandname, {
        description = "Get or set player-specific file "..settingname,
        params = "[filename]",
        func = function(sendername, params)
            if params.filename then
                local path = get_media(params.filename)
                if not modlib.file.exists(path) then return false, "File doesn't exist" end
                set_setting(sendername, settingname, params.filename)
                return true, string.format('File "%s" was set to "%s"', settingname, params.filename)
            end
            local value = get_setting(sendername, settingname)
            if value then
                return true, string.format('File "%s" is currently set to "%s"', settingname, value)
            end
            return true, string.format('File "%s" is currently not set, using default', settingname)
        end
    })
end

local algorithm_names = {}
for index, matrix in ipairs(dithering_matrices) do
    algorithm_names[index] = matrix.name
end
table.insert(algorithm_names, "No preprocessing")

register_setting_command("dithering", algorithm_names)

local color_choosing = {"best", "average"}
register_setting_command("color_choosing", {"Best", "Average"})

local merge_mode = {"overwrite", "add", "intersection"}
register_setting_command("placement", {"Overwrite", "Add", "Intersection"})

local filtering = {"nearest", "bilinear"}
register_setting_command("filtering", {"Nearest neighbor", "Bilinear"})

register_file_command("model")
register_file_command("texture")
register_file_command("nodemap")

function register_bool_setting_command(name)
    cmdlib.register_chatcommand("vox "..name, {
        description = "Check whether "..name.." is enabled",
        func = function(sendername)
            local enabled = get_setting_int(sendername, name) == 1
            return true, string.format("Setting %s is %s", name, (enabled and "enabled") or "disabled")
        end
    })

    cmdlib.register_chatcommand("vox "..name.." enable", {
        description = "Enable "..name,
        privs = {protection_bypass = true},
        func = function(sendername)
            set_setting_int(sendername, name, 1)
            return true, name.." was enabled."
        end
    })

    cmdlib.register_chatcommand("vox "..name.." disable", {
        description = "Disable "..name,
        privs = {protection_bypass = true},
        func = function(sendername)
            set_setting_int(sendername, name, 2)
            return true, name.." was disabled."
        end
    })
end

register_bool_setting_command("protection_bypass")

register_bool_setting_command("alpha_weighing")

local max_precision = config.max_precision
cmdlib.register_chatcommand("vox precision", {
    description = "Set/get current precision",
    params = "[number]",
    func = function(sendername, params)
        if params.number then
            params.number = tonumber(params.number)
            if params.number % 1 ~= 0 or params.number < 1 or params.number > max_precision then
                return false, "Number needs to be an integer between 1 and "..max_precision
            end
            set_setting_int(sendername, "precision", params.number)
            return true, "Precision was set to "..params.number
        end
        return true, "Precision currently is "..(get_setting_int(sendername, "precision") or defaults.precision)
    end
})

cmdlib.register_chatcommand("vox min_density", {
    description = "Set/get minimum density",
    params = "[number]",
    func = function(sendername, params)
        if params.number then
            params.number = tonumber(params.number)
            if params.number < 0 or params.number > 1 then
                return false, "Number needs to be a floating-point number between 0 and 1"
            end
            set_setting_float(sendername, "min_density", params.number)
            return true, "Precision was set to "..params.number
        end
        return true, "Precision currently is "..(get_setting_int(sendername, "min_density") or defaults.min_density)
    end
})

local function substitute_coords(pos, playername)
    local player_pos = minetest.get_player_by_name(playername):get_pos()
    local x, y, z = unpack(pos)
    local pos = {x or player_pos.x, y or player_pos.y, z or player_pos.z}
    return pos
end

local function place(sendername, additional)
    local function setting(name) return get_setting(sendername, name) end
    local function setting_int(name) return get_setting_int(sendername, name) end
    local function setting_float(name) return get_setting_float(sendername, name) end
    local model, texture, nodemap = setting("model"), setting("texture"), setting("nodemap")
    local params = {
        playername = sendername,
        model = (model and get_media(model)) or defaults.model,
        texture = (texture and get_media(texture)) or defaults.texture,
        nodemap = (nodemap and get_media(nodemap)) or defaults.nodemap,
        min_density = setting_float("min_density") or defaults.min_density,
        precision = setting_int("precision") or defaults.precision,
        dithering = dithering_matrices[setting_int("dithering")],
        protection_bypass = setting_int("protection_bypass") == 1,
        weighed = setting_int("alpha_weighing") == 1,
        filtering = filtering[setting_int("filtering")],
        color_choosing = color_choosing[setting_int("color_choosing")],
        merge_mode = merge_mode[setting_int("placement")],
    }
    modlib.table.add_all(params, additional)
    return place_obj(params)
end

cmdlib.register_chatcommand("vox place", {
    description = "Place model at position with given size. Missing coordinates will be replaced by player coordinates.",
    params = "[scale] {position}",
    func = function(sendername, params)
        if params.scale then
            params.scale = tonumber(params.scale)
            if not params.scale then return false, "Scale needs to be a valid number" end
            if params.position and #params.position > 3 then return false, "Only 3 coordinates (x, y, z) are allowed" end
        end
        local pos = substitute_coords(params.position or {}, sendername)
        local error = place(sendername, { pos1 = pos, scale = params.scale })
        if error then return false, "Failed to place model : "..error end
        return true, "Placed model at "..vector.to_string(pos).." with the scale "..(params.scale or 1)
    end
})

cmdlib.register_chatcommand("vox 1", {
    description = "Set first corner position of model to be placed. Missing coordinates will be replaced by player coordinates.",
    params = "{position}",
    func = function(sendername, params)
        if params.position and #params.position > 3 then return false, "Only 3 coordinates (x, y, z) are allowed" end
        local pos = substitute_coords(params.position or {}, sendername)
        set_setting(sendername, "1", minetest.write_json(pos))
        local old_id = get_setting_int(sendername, "pos1_waypoint")
        if old_id then minetest.get_player_by_name(sendername):hud_remove(old_id) end
        local id = minetest.get_player_by_name(sendername):hud_add({hud_elem_type="waypoint",
        name="Voxelizer Position 1",
        number=0xFFFF00,
        world_pos = vector.to_minetest(pos)})
        minetest.add_particle({
            pos = vector.to_minetest(pos),
            velocity = {x=0, y=0, z=0},
            acceleration = {x=0, y=0, z=0},
            expirationtime = 6,
            size = 16,
            collisiondetection = false,
            collision_removal = false,
            object_collision = false,
            vertical = false,
            texture = "voxelizer_marker.png",
            playername = sendername,
            animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0 },
            glow = 14
        })
        set_setting_int(sendername, "pos1_waypoint", id)
    end
})

cmdlib.register_chatcommand("vox 2", {
    description = "Set second corner position of model & place it. Missing coordinates will be replaced by player coordinates.",
    params = "{position}",
    func = function(sendername, params)
        if params.position and #params.position > 3 then return false, "Only 3 coordinates (x, y, z) are allowed" end
        local pos1, pos2 = minetest.parse_json(get_setting(sendername, "1")), substitute_coords(params.position or {}, sendername)
        if not pos1 then
            return false, "First corner position not set. Do \"/vox 1\" first to set it."
        end
        local old_id = get_setting_int(sendername, "pos1_waypoint")
        if old_id then minetest.get_player_by_name(sendername):hud_remove(old_id) end
        local error = place(sendername, { pos1 = pos1, pos2 = pos2 })
        if error then return false, "Failed to place model : "..error end
        return true, "Placed model from "..vector.to_string(pos1).." to "..vector.to_string(pos2)
    end
})

cmdlib.register_chatcommand("vox reset", {
    description = "Reset settings",
    func = function(sendername)
        for setting, _ in pairs(defaults) do
            set_setting(sendername, setting, "")
        end
        return true, "Settings resetted."
    end
})

if config.download then
    minetest.register_privilege("voxelizer:download", {
        description = "Can download files from the internet using the voxelizer mod",
        give_to_admin = true,
        give_to_singleplayer = true
    })

    local errors = {
        "URL and output path need to be given",
        "Couldn't create file",
        "Output file doesn't exist or can't be written",
        "Couldn't download file",
        "Couldn't write to file",
        "Malformed URL"
    }

    cmdlib.register_chatcommand("vox download", {
        description = "Download a file from the internet",
        params = "<url> [filename]",
        privs = {["voxelizer:download"]=true},
        func = function(sendername, params)
            if not params.filename then
                local last_slash
                for i = params.url:len(), 1, -1 do
                    if params.url:sub(i, i) == "/" then
                        last_slash = i
                        break
                    end
                end
                params.filename = params.url:sub(last_slash+1)
            end

            local path = voxelizer.get_media(params.filename)
            local call = string.format('java -classpath "%s/production" FileDownloader "%s" "%s"', minetest.get_modpath("voxelizer"), params.url, path)
            local response_code = os_execute(call)
            if response_code ~= 0 then
                local error = errors[response_code]
                if error then return false, "Download failed : "..error end
                return false, "Download failed"
            end

            return true, "Download successful"
        end
    })
end