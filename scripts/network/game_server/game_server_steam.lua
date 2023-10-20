GameServerInternal = GameServerInternal or { }

GameServerInternal.lobby_data_version = 2


function GameServerInternal.init_server(network_options, server_name)

	local config_file_name = network_options.config_file_name
	local project_hash = network_options.project_hash
	local network_hash = GameServerAux.create_network_hash(config_file_name, project_hash)
	local settings = { dedicated = true, server_version = "1.0.0.0",
		steam_port = network_options.steam_port,

		game_description = network_hash,
		gamedir = Managers.mechanism:server_universe(),
		ip_address = network_options.ip_address,
		map = network_options.map,
		max_players = network_options.max_members,
		query_port = network_options.query_port,
		server_name = server_name,
		server_port = network_options.server_port }



	table.dump(settings, "server settings")

	local use_eac = true
	local server = Network.init_steam_server(config_file_name, settings, use_eac)
	GameSettingsDevelopment.set_ignored_rpc_logs()

	cprintf("Appid: %s", SteamGameServer.app_id())
	return server
end

function GameServerInternal.ping(peer_id)
	return Network.ping(peer_id)
end

function GameServerInternal.shutdown_server(game_server)
	Network.shutdown_steam_server(game_server)
end

function GameServerInternal.server_id(game_server)
	return SteamGameServer.id(game_server)
end


function GameServerInternal.set_level_name(game_server, name)
	SteamGameServer.set_map(game_server, name)
end


function GameServerInternal.run_callbacks(game_server, callback_object)
	SteamGameServer.run_callbacks(game_server, callback_object)
end

function GameServerInternal.user_name(game_server, peer_id)
	return SteamGameServer.name(game_server, peer_id)
end

if DEDICATED_SERVER then
	function GameServerInternal.open_channel(game_server, peer)
		local channel_id = SteamGameServer.open_channel(game_server, peer)
		print("GameServerInternal.open_channel game_server: %s, to peer: %s channel: %s", game_server, peer, channel_id)
		return channel_id
	end

	function GameServerInternal.close_channel(game_server, channel)
		print("GameServerInternal.close_channel game_server: %s, channel: %s", game_server, channel)
		SteamGameServer.close_channel(game_server, channel)
	end end