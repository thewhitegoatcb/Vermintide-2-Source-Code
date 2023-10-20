require("scripts/network/game_server/game_server_aux")
require("scripts/network/lobby_members")

GameServer = class(GameServer)

local function dprintf(string, ...)
	local s = string:format(...)
	printf("[GameServer]: %s", s)
end

function GameServer:init(network_options, server_name)
	dprintf("Initializing game server...")

	local config_file_name = network_options.config_file_name
	local project_hash = network_options.project_hash
	self._network_hash = GameServerAux.create_network_hash(config_file_name, project_hash)

	assert(network_options.max_members, "Has to pass max_members to GameServer")
	self._max_members = network_options.max_members

	self._game_server = GameServerInternal.init_server(network_options, server_name)
	self._data_table = { }

	self._server_name = server_name
	self._network_initialized = false
end

function GameServer:destroy()
	dprintf("Shutting down game server")

	self._members = nil

	self._data_table = nil

	GameServerInternal.shutdown_server(self._game_server)
	self._game_server = nil

	GarbageLeakDetector.register_object(self, "Game Server")
end

function GameServer:update(dt, t)
	local game_server = self._game_server
	local new_state = game_server:state()

	local old_state = self._state
	if new_state ~= old_state then
		dprintf("Changing state from %s to %s", old_state, new_state)
		self._state = new_state

		if new_state == "connected" then
			local data_table = self._data_table
			data_table.network_hash = self._network_hash
			for key, value in pairs(data_table) do
				game_server:set_data(key, value)
			end

			self._members = self._members or LobbyMembers:new(game_server)
		end

		if old_state == "connected" and self._members then
			self._members:clear()
		end
	end

	local members = self._members
	if members then
		members:update()
	end

	GameServerInternal.run_callbacks(self._game_server, self)

	return self._state
end

function GameServer:ping_by_peer(peer_id)
	return GameServerInternal.ping(peer_id)
end

function GameServer:remove_peer(peer_id)
	self._game_server:remove_member(peer_id)
end

function GameServer:close_channel(channel_id)
	GameServerInternal.close_channel(self._game_server, channel_id)
end


function GameServer:set_level_name(name)
	GameServerInternal.set_level_name(self._game_server, name)
end

function GameServer:set_lobby_data(data)
	print("Set lobby begin:")
	local internal_data_table = self._data_table
	local game_server = self._game_server

	for key, value in pairs(data) do
		print(string.format("  Lobby data %s = %s", key, tostring(value)))
		internal_data_table [key] = value

		game_server:set_data(key, value)
	end
	print("Set lobby end.")
end

function GameServer:get_stored_lobby_data()
	return self._data_table
end

function GameServer:attempting_reconnect()
	return false
end


function GameServer:is_dedicated_server()
	return true
end

function GameServer:lobby_data(key)
	return self._game_server:data(key)
end

function GameServer:lobby_host()
	return Network.peer_id()
end

function GameServer:state()
	return self._state
end

function GameServer:members()
	return self._members
end

function GameServer:user_name(peer_id)
	return GameServerInternal.user_name(self._game_server, peer_id)
end

function GameServer:get_max_members()
	return self._max_members
end

function GameServer:is_joined()
	return self._state == "connected"
end

function GameServer:id()
	return GameServerInternal.server_id and GameServerInternal.server_id(self._game_server) or "no_id"
end

function GameServer:server_name()
	return self._server_name
end

function GameServer:set_server_name(server_name)
	self._server_name = server_name
end

function GameServer:set_network_initialized(initialized)
	self._network_initialized = initialized
end

function GameServer:network_initialized()
	return self._network_initialized
end

function GameServer:failed()
	return self._state == "disconnected"
end



function GameServer:server_member_added(peer_id)
	printf("Member %s was added", peer_id)
end




function GameServer:server_slot_allocation_request(reserver, peers)
	if Managers.mechanism:try_reserve_game_server_slots(reserver, peers) then
		printf("Request by %s to allocate %d slots was approved", reserver, #peers)
		do return true end
	else
		printf("Request by %s to allocate %d slots was disapproved", reserver, #peers)
		return false
	end
end



function GameServer:server_slot_expired(peer_id)
	Managers.mechanism:game_server_slot_reservation_expired(peer_id)
	printf("Server slot %s was deallocated", peer_id)
end

function GameServer:lost_connection_to_lobby()
	return false
end