function atl_server_jail.round(num, precision)
    local mult = 10^(precision or 0)
    return math.floor(num * mult + 0.5) / mult
end

function atl_server_jail.get_serialized_data(key)
    return minetest.deserialize(atl_server_jail.mod_storage:get_string(key))
end

function atl_server_jail.set_serialized_data(key, data)
    atl_server_jail.mod_storage:set_string(key, minetest.serialize(data))
end

function atl_server_jail.get_JailCoords()
    return atl_server_jail.get_serialized_data("jail_coords")
end

function atl_server_jail.set_JailCoords(pos)
    atl_server_jail.set_serialized_data("jail_coords", pos)
end

function atl_server_jail.get_JailedPlayers()
    return atl_server_jail.get_serialized_data("jailed_players") or {}
end

function atl_server_jail.set_JailedPlayers(data)
    atl_server_jail.set_serialized_data("jailed_players", data)
end

function atl_server_jail.get_PlayerPrivs(player_name)
    return atl_server_jail.get_serialized_data("player_privs_" .. player_name) or {}
end

function atl_server_jail.set_PlayerPrivs(player_name, privs)
    atl_server_jail.set_serialized_data("player_privs_" .. player_name, privs)
end

function atl_server_jail.jail_player(player_name, time, reason)
    local jail_data = atl_server_jail.get_JailedPlayers()
    jail_data[player_name] = {
        initial_time = time,
        remaining_time = time,
        reason = reason,
        last_update = os.time()
    }
    atl_server_jail.set_JailedPlayers(jail_data)

    local player = minetest.get_player_by_name(player_name)
    if player then
        local jail_coords = atl_server_jail.get_JailCoords()
        if jail_coords then
            player:set_pos(jail_coords)
            minetest.chat_send_player(player_name, "-!- You were put in jail | <> | During " .. time .. " seconds | <> | Reason: " .. reason)
        end

        local privs = minetest.get_player_privs(player_name)
        atl_server_jail.set_PlayerPrivs(player_name, privs)
        minetest.set_player_privs(player_name, {})

        minetest.after(time, function()
            atl_server_jail.unjail_player(player_name)
        end)
    end

    return true, "-!- " .. player_name .. " were put in jail | <> | During " .. time .. " seconds | <> | Reason: " .. reason
end

function atl_server_jail.unjail_player(player_name)
    local jail_data = atl_server_jail.get_JailedPlayers()
    if jail_data[player_name] then
        jail_data[player_name] = nil
        atl_server_jail.set_JailedPlayers(jail_data)

        local privs = atl_server_jail.get_PlayerPrivs(player_name)
        minetest.set_player_privs(player_name, privs)
        atl_server_jail.set_PlayerPrivs(player_name, {})

        local player = minetest.get_player_by_name(player_name)
        if player then
            player:set_pos({x = 0, y = 0, z = 0})
            minetest.chat_send_player(player_name, "You have been released from jail.")
        end

        return true, "Player " .. player_name .. " has been released from jail."
    else
        return false, "Player " .. player_name .. " is not in jail."
    end
end

function atl_server_jail.check_and_apply_jail(player_name)
    local jail_data = atl_server_jail.get_JailedPlayers()
    local jail_info = jail_data[player_name]
    if jail_info then
        local player = minetest.get_player_by_name(player_name)
        if player then
            local jail_coords = atl_server_jail.get_JailCoords()
            if jail_coords then
                player:set_pos(jail_coords)
                minetest.chat_send_player(player_name, "-!- You were put in jail | <> | During " .. jail_info.remaining_time .. " seconds | <> | Reason: " .. jail_info.reason)
            end

            local privs = minetest.get_player_privs(player_name)
            atl_server_jail.set_PlayerPrivs(player_name, privs)
            minetest.set_player_privs(player_name, {})

            minetest.after(jail_info.remaining_time, function()
                atl_server_jail.unjail_player(player_name)
            end)

            minetest.register_globalstep(function(dtime)
                local jail_data = atl_server_jail.get_JailedPlayers()
                local jail_info = jail_data[player_name]
                if jail_info then
                    jail_info.remaining_time = jail_info.remaining_time - dtime
                    jail_info.last_update = os.time()
                    atl_server_jail.set_JailedPlayers(jail_data)

                    if jail_info.remaining_time <= 0 then
                        atl_server_jail.unjail_player(player_name)
                        return
                    end
                end
            end)
        end
    end
end
