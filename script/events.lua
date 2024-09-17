
minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    atl_server_jail.check_and_apply_jail(player_name)
end)

minetest.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    local jail_data = atl_server_jail.get_JailedPlayers()
    local jail_info = jail_data[player_name]
    if jail_info then
        jail_info.remaining_time = jail_info.remaining_time - (os.time() - jail_info.last_update)
        jail_data[player_name] = jail_info
        atl_server_jail.set_JailedPlayers(jail_data)
    end
end)
