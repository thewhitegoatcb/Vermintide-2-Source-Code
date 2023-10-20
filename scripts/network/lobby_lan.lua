require("scripts/network/lobby_aux")
require("scripts/network/lobby_host")
require("scripts/network/lobby_client")
require("scripts/network/lobby_finder")
require("scripts/network/lobby_members")

LobbyInternal = LobbyInternal or { }

LobbyInternal.lobby_data_version = 2

if IS_XB1 then
	LobbyInternal.state_map = {
		[LobbyState.WORKING] = LobbyState.WORKING,
		[LobbyState.SHUTDOWN] = LobbyState.SHUTDOWN,
		[LobbyState.JOINED] = LobbyState.JOINED,
		[LobbyState.FAILED] = LobbyState.FAILED }
end


LobbyInternal.TYPE = "lan"

function LobbyInternal.network_initialized()
	local client = LobbyInternal.client
	return not not client
end

function LobbyInternal.create_lobby(network_options)
	return Network.create_lan_lobby(network_options.max_members)
end

function LobbyInternal.join_lobby(lobby_data)
	return Network.join_lan_lobby(lobby_data.id)
end

LobbyInternal.leave_lobby = Network.leave_lan_lobby

function LobbyInternal.open_channel(lobby, peer)
	local channel_id = LanLobby.open_channel(lobby, peer)
	print("LobbyInternal.open_channel lobby: %s, to peer: %s channel: %s", lobby, peer, channel_id)
	return channel_id
end

function LobbyInternal.close_channel(lobby, channel)
	print("LobbyInternal.close_channel lobby: %s, channel: %s", lobby, channel)
	LanLobby.close_channel(lobby, channel)
end

function LobbyInternal.is_orphaned(engine_lobby)
	return false
end

function LobbyInternal.game_session_host(engine_lobby)
	return LanLobby.game_session_host(engine_lobby)
end

function LobbyInternal.init_client(network_options)
	local game_port = network_options.server_port
	if Development.parameter("client") then

		game_port = 0
	end

	local peer_id = Development.parameter("lan_peer_id")
	if peer_id then
		print("Forcing LAN peer_id ", peer_id)
		local peer_id_number = tonumber(peer_id, 16)
		LobbyInternal.client = Network.init_lan_client(network_options.config_file_name, game_port, peer_id_number)
	else
		LobbyInternal.client = Network.init_lan_client(network_options.config_file_name, game_port)
	end
	fassert(LobbyInternal.client, "Failed to initialize the network. The port is most likely in use, which means that another game instance is running at the same time.")
	GameSettingsDevelopment.set_ignored_rpc_logs()
end

function LobbyInternal.shutdown_client()
	Network.shutdown_lan_client(LobbyInternal.client)
	LobbyInternal.client = nil
end

function LobbyInternal.get_lobby_data_from_id(id)

	return nil
end

function LobbyInternal.get_lobby_data_from_id_by_key(id, key)

	return nil
end

function LobbyInternal.ping(peer_id)
	return Network.ping(peer_id)
end

LobbyInternal.get_lobby = LanLobbyBrowser.lobby

local XBOX_MOCK_LOBBY_BROWSER = {
	is_refreshing = function () return false end,
	refresh = function () return end,
	num_lobbies = function () return 0 end }


function LobbyInternal.lobby_browser()
	return XBOX_MOCK_LOBBY_BROWSER
end

function LobbyInternal.clear_filter_requirements()
	return end

function LobbyInternal.add_filter_requirements(requirements)
	return end

function LobbyInternal.user_name(user)
	return Network.peer_id()
end

function LobbyInternal.lobby_id(lobby)

	return 10000
end

function LobbyInternal.is_friend(peer_id)
	return false
end

function LobbyInternal.client_ready() return false end

function LobbyInternal.set_max_members(lobby, max_members)
	LanLobby.set_max_members(lobby, max_members)
end

function LobbyInternal.lobby_id_match(id1, id2)
	if id1 == nil or id2 == nil then
		return true
	end

	return id1 == id2
end