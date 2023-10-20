GameServerManager = class(GameServerManager)

function GameServerManager:init(level_transition_handler)

	self._last_error_reason = ""
end

function GameServerManager:setup_network_context(network_context)
	self._network_server = network_context.network_server
	self._network_transmit = network_context.network_transmit
	self._game_server = network_context.game_server
	self._profile_synchronizer = network_context.profile_synchronizer
end

function GameServerManager:destroy()
	if self._network_transmit then
		self._network_transmit:destroy()
		self._network_transmit = nil
	end
end

function GameServerManager:update(dt, t)
	self:_notify_backend_errors()
end


function GameServerManager:peer_name(peer_id)
	return self._game_server:user_name(peer_id)
end

function GameServerManager:remove_peer(peer_id)
	self._game_server:remove_peer(peer_id)
end

function GameServerManager:_update_game_server(dt, t)
	self:_update_leader()
end

function GameServerManager:server_name()
	return self._game_server:server_name()
end

function GameServerManager:set_leader_peer_id(leader_peer_id)
	Managers.party:set_leader(leader_peer_id)


	local non_nil_leader = leader_peer_id == nil and "0" or leader_peer_id
	local members = self._game_server:members():get_members()
	for _, peer_id in ipairs(members) do
		local channel_id = PEER_ID_TO_CHANNEL [peer_id]
		RPC.rpc_game_server_set_group_leader(channel_id, non_nil_leader)
	end
end

function GameServerManager:start_game_params()
	return self._start_game_params
end

function GameServerManager:restart()
	self._wants_restart = true
end

function GameServerManager:get_transition()
	if self._wants_restart then
		return "restart_game_server"
	end
end

function GameServerManager:hot_join_sync(peer_id)

	local matchmaking_manager = Managers.matchmaking
	if matchmaking_manager and matchmaking_manager:on_dedicated_server() then
		return
	end

	local leader = Managers.party:leader()

	local non_nil_leader = leader == nil and "0" or leader

	local channel_id = PEER_ID_TO_CHANNEL [peer_id]
	RPC.rpc_game_server_set_group_leader(channel_id, non_nil_leader)
end

function GameServerManager:set_start_game_params(sender, level_key, game_mode, difficulty, private_game)
	local current_leader = Managers.party:leader()
	if sender ~= current_leader then
		mm_printf("Peer (%s) tried starting the game without being leader (%s)", sender, current_leader)
		return
	end

	local stored_lobby_data = self._game_server:get_stored_lobby_data()

	stored_lobby_data.level_key = level_key
	stored_lobby_data.difficulty = difficulty
	stored_lobby_data.game_mode = not IS_PS4 and NetworkLookup.game_modes [game_mode] or game_mode
	stored_lobby_data.is_private = private_game and "true" or "false"

	self._game_server:set_lobby_data(stored_lobby_data)

	self._start_game_params = {
		level_key = level_key,
		game_mode = game_mode,
		difficulty = difficulty,
		private_game = private_game }

end


function GameServerManager:_notify_backend_errors()
	local backend = Managers.backend

	if backend ~= nil and backend:has_error() then
		local reason = backend:error_string()
		if self._last_error_reason ~= reason then

			self:_say(reason)
			self._last_error_reason = reason
		end
	end
end


function GameServerManager:_say(text)

	text = UTF8Utils.sub_string(text, 1, 128)

	local chat = Managers.chat
	if chat ~= nil and chat:has_channel(1) then
		local localize_parameters = false
		chat:send_system_chat_message(1, "backend_error_on_server", text, localize_parameters, true)
	end
end