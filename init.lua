atl_server_jail = {}
atl_server_jail.modpath = minetest.get_modpath("atl_server_jail")
atl_server_jail.mod_storage = minetest.get_mod_storage()


function atl_server_jail.load_file(path)
    local status, err = pcall(dofile, path)
    if not status then
        minetest.log("error", "-!- Failed to load file: " .. path .. " - Error: " .. err)
    else
        minetest.log("action", "-!- Successfully loaded file: " .. path)
    end
end

if atl_server_jail.modpath then
    local files_to_load = {
        "script/api.lua",
        "script/commands.lua",
        "script/events.lua",
    }

    for _, file in ipairs(files_to_load) do
        atl_server_jail.load_file(atl_server_jail.modpath .. "/" .. file)
    end
else
    minetest.log("error", "-!- Files in " .. atl_server_jail.modpath .. " mod are not set or valid.")
end
