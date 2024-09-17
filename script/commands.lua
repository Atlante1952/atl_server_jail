
minetest.register_chatcommand("set_jail", {
    params = "",
    description = "Set the jail coordinates to your current position",
    privs = {ban = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        local pos = player:get_pos()
        local rounded_pos = {
            x = atl_server_jail.round(pos.x, 1),
            y = atl_server_jail.round(pos.y, 1),
            z = atl_server_jail.round(pos.z, 1)
        }
        atl_server_jail.set_JailCoords(rounded_pos)

        return true, "-!- Jail coordinates set to: " .. minetest.pos_to_string(rounded_pos)
    end,
})

minetest.register_chatcommand("jail", {
    params = "<player_name> <time> <reason>",
    description = "Jail a player for a specified time with a reason",
    privs = {ban = true},
    func = function(name, param)
        local args = param:split(" ")
        if #args < 3 then
            return false, "-!- Usage: /jail <player_name> <time> <reason>"
        end

        local player_name = args[1]
        local time = tonumber(args[2])
        local reason = table.concat(args, " ", 3)

        if not time or time <= 0 then
            return false, "-!- Time must be a positive number."
        end

        return atl_server_jail.jail_player(player_name, time, reason)
    end,
})

minetest.register_chatcommand("unjail", {
    params = "<player_name>",
    description = "Release a player from jail",
    privs = {ban = true},
    func = function(name, param)
        local player_name = param:trim()
        if player_name == "" then
            return false, "-!- Usage: /unjail <player_name>"
        end

        return atl_server_jail.unjail_player(player_name)
    end,
})