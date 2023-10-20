require("scripts/network/lobby_aux")
require("scripts/network/lobby_host")
require("scripts/network/lobby_client")
require("scripts/network/lobby_finder")
require("scripts/network/lobby_members")

LobbyInternal = LobbyInternal or { }

LobbyInternal.TYPE = "steam"

LobbyInternal.lobby_data_version = 2


function LobbyInternal.network_initialized()
	return not not LobbyInternal.client
end

function LobbyInternal.create_lobby(network_options)

	local privacy = network_options.privacy or "public"
	local use_eac = true
	return Network.create_steam_lobby(privacy, network_options.max_members, use_eac)
end

function LobbyInternal.join_lobby(lobby_data)
	local use_eac = true
	return Network.join_steam_lobby(lobby_data.id, use_eac)
end

function LobbyInternal.leave_lobby(lobby)
	Network.leave_steam_lobby(lobby)
end

function LobbyInternal.open_channel(lobby, peer)
	local channel_id = SteamLobby.open_channel(lobby, peer)
	printf("LobbyInternal.open_channel lobby: %s, to peer: %s channel: %s", lobby, peer, channel_id)
	return channel_id
end

function LobbyInternal.close_channel(lobby, channel)
	printf("LobbyInternal.close_channel lobby: %s, channel: %s", lobby, channel)
	SteamLobby.close_channel(lobby, channel)
end

function LobbyInternal.is_orphaned(engine_lobby)
	return engine_lobby:is_orphaned()
end

function LobbyInternal.init_client(network_options)
	LobbyInternal.client = Network.init_steam_client(network_options.config_file_name)
	GameSettingsDevelopment.set_ignored_rpc_logs()
end

function LobbyInternal.shutdown_client()
	Network.shutdown_steam_client(LobbyInternal.client)

	GameServerInternal.forget_server_browser()
	LobbyInternal.client = nil
end

function LobbyInternal.get_lobby_data_from_id(id)
	SteamLobby.request_lobby_data(id)
	local data = SteamMisc.get_lobby_data(id)
	return data
end

function LobbyInternal.get_lobby_data_from_id_by_key(id, key)
	local data = SteamMisc.get_lobby_data_by_key(id, key)
	return data ~= "" and data or nil
end

function LobbyInternal.ping(peer_id)
	return Network.ping(peer_id)
end

function LobbyInternal.get_lobby(lobby_browser, index)
	local lobby_data = lobby_browser:lobby(index)
	local lobby_data_all = lobby_browser:data_all(index)
	lobby_data_all.id = lobby_data.id




	local formatted_lobby_data = { }
	for key, value in pairs(lobby_data_all) do
		formatted_lobby_data [string.lower(key)] = value
	end

	return formatted_lobby_data
end

function LobbyInternal.clear_filter_requirements(lobby_browser)
	SteamLobbyBrowser.clear_filters(lobby_browser)
end

function LobbyInternal.add_filter_requirements(requirements, lobby_browser)
	SteamLobbyBrowser.clear_filters(lobby_browser)
	SteamLobbyBrowser.add_slots_filter(lobby_browser, requirements.free_slots)

	local distance_filter = requirements.distance_filter
	fassert(distance_filter, "Missing or bad distance filer: %s", distance_filter)
	SteamLobbyBrowser.add_distance_filter(lobby_browser, distance_filter)

	mm_printf("Filter: Free slots = %s", tostring(requirements.free_slots))
	mm_printf("Filter: Distance = %s", tostring(requirements.distance_filter))
	for key, filter in pairs(requirements.filters) do
		local value = filter.value local comparison = filter.comparison
		SteamLobbyBrowser.add_filter(lobby_browser, key, value, comparison)
		mm_printf("Filter: %s, comparison(%s), value=%s", tostring(key), tostring(comparison), tostring(value))
	end

	for _, filter in ipairs(requirements.near_filters) do
		local key = filter.key local value = filter.value
		SteamLobbyBrowser.add_near_filter(lobby_browser, key, value)
		mm_printf("Near Filter: %s, value=%s", tostring(key), tostring(value))
	end






end

function LobbyInternal.user_name(user)
	return Steam.user_name(user)
end

function LobbyInternal.lobby_id(lobby)
	return lobby:id()
end

function LobbyInternal.is_friend(peer_id)
	return Friends.in_category(peer_id, Friends.FRIEND_FLAG)
end

function LobbyInternal.set_max_members(lobby, max_members)
	SteamLobby.set_max_members(lobby, max_members)
end