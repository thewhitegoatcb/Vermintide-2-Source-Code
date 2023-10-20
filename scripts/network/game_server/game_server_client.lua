require("scripts/network/game_server/game_server_aux")

GameServerLobbyClient = class(GameServerLobbyClient)

local function dprintf(string, ...)
	local s = string:format(...)
	printf("[GameServerLobbyClient]: %s", s)
end


function GameServerLobbyClient:init(network_options, game_server_data, password, reserve_peers)
	dprintf("Joining lobby on address %s", game_server_data.server_info.ip_port)

	self._game_server_info = game_server_data.server_info

	if reserve_peers then
		self._game_server_lobby = GameServerInternal.reserve_server(self._game_server_info, password, reserve_peers)
	else

		self._game_server_lobby = GameServerInternal.join_server(self._game_server_info, password)
	end

	self._game_server_lobby_data = game_server_data

	local config_file_name = network_options.config_file_name
	local project_hash = network_options.project_hash
	self._network_hash = GameServerAux.create_network_hash(config_file_name, project_hash)


	self.lobby = self._game_server_lobby
	self.network_hash = self._network_hash

end

function GameServerLobbyClient:destroy()
	dprintf("Destroying Game Server Client, leaving server...")
	local host = GameServerInternal.lobby_host(self._game_server_lobby)
	local channel_id = PEER_ID_TO_CHANNEL [host]
	printf("closing channel %s", tostring(channel_id))
	if channel_id then
		GameServerInternal.close_channel(self._game_server_lobby, channel_id)
		PEER_ID_TO_CHANNEL [host] = nil
		CHANNEL_TO_PEER_ID [channel_id] = nil
	end


	Presence.stop_advertise_playing()
	GameServerInternal.leave_server(self._game_server_lobby)

	self._members = nil
	self._game_server_lobby = nil
	self._game_server_lobby_data = nil
	GarbageLeakDetector.register_object(self, "Game Server Client")
end

function GameServerLobbyClient:update(dt)
	local engine_lobby = self._game_server_lobby
	local new_state = engine_lobby:state()
	local old_state = self._state
	if new_state ~= old_state then
		dprintf("Changing state from %s to %s", old_state, new_state)
		self._state = new_state

		if new_state == "joined" then
			local game_server_peer_id = GameServerInternal.lobby_host(engine_lobby)


			if not PEER_ID_TO_CHANNEL [game_server_peer_id] then

				local channel_id = GameServerInternal.open_channel(engine_lobby, game_server_peer_id)
				PEER_ID_TO_CHANNEL [game_server_peer_id] = channel_id
				CHANNEL_TO_PEER_ID [channel_id] = game_server_peer_id
			end


			Presence.advertise_playing(self._game_server_info.ip_port)

			self._members = self._members or LobbyMembers:new(engine_lobby)
		end

		if old_state == "joined" and self._members then
			self._members:clear()
		end
	end

	if self._members then
		self._members:update()
	end
end


function GameServerLobbyClient:claim_reserved()
	GameServerInternal.claim_reserved(self._game_server_lobby)
end

function GameServerLobbyClient:state()
	return self._state
end

function GameServerLobbyClient:members()
	return self._members
end



function GameServerLobbyClient:invite_target()
	return self._game_server_info.ip_port
end


function GameServerLobbyClient:is_dedicated_server()
	return true
end

function GameServerLobbyClient:lobby_host()
	return GameServerInternal.lobby_host(self._game_server_lobby)
end

function GameServerLobbyClient:lobby_data(key)
	return self._game_server_lobby:data(key)
end

function GameServerLobbyClient:get_stored_lobby_data()
	return self._game_server_lobby_data
end

function GameServerLobbyClient:ip_address()
	return self._game_server_info.ip_port
end

function GameServerLobbyClient:is_joined()
	return self._state == "joined"
end

function GameServerLobbyClient:failed()
	return self._state == "failed"
end

function GameServerLobbyClient:id()
	return GameServerInternal.lobby_id and GameServerInternal.lobby_id(self._game_server_lobby) or "no_id"
end

function GameServerLobbyClient:request_data()
	self._game_server_lobby:request_data()
end

function GameServerLobbyClient:attempting_reconnect()
	return false
end

function GameServerLobbyClient:lost_connection_to_lobby()
	return false
end