local States = { END_OF_ROUND = 3, ERROR = 4, IN_GAME = 2, INITIALIZED = 1, UNINITIALIZED = 0 }







for key, value in pairs(States) do
	States [value] = key
end

local Session = class(Session)

function Session:init()
	self._peers = { }
	self._peer_queue = { }
	self._debug_backend_session_done_timeout = false
	self._debug_backend_session_stop_timeout = false
end

function Session:disable()
	self._disabled = true
end

function Session:enabled()
	return not self._disabled
end

function Session:register_rpcs(network_event_delegate)
	self._network_event_delegate = network_event_delegate

	if Managers.state.network.is_server then
		network_event_delegate:register(self, "rpc_backend_session_done")
	else
		network_event_delegate:register(self, "rpc_backend_session_join")
	end
end

function Session:rpc_backend_session_join(channel_id, session_id)
	BackendSession.join(session_id)
end

function Session:rpc_backend_session_done(channel_id)
	if not self._debug_backend_session_done_timeout then
		local peer_id = CHANNEL_TO_PEER_ID [channel_id]
		self:_dice_player_done(peer_id)
	end
end

function Session:_dice_player_done(peer_id)
	local players = self._dice_data.players
	players [peer_id] = nil
	if table.is_empty(players) and not self._debug_backend_session_stop_timeout then
		BackendSession.stop()
		self._dice_data = nil
	end
end

function Session:reset()
	if self._disabled then
		self._disabled = nil
	else
		local state = BackendSession.get_state()
		if Managers.state.network.is_server and state ~= States.UNINITIALIZED then
			BackendSession.stop()
		end
		self._post_dice_timeout = nil

		self:_unregister_rpcs()

		self._peers = { }
		self._peer_queue = { }
		self._disabled = nil
		self._dice_data = nil
	end
end

function Session:_unregister_rpcs()
	self._network_event_delegate:unregister(self)
	self._network_event_delegate = nil
end

function Session:update(dt)
	local state = BackendSession.get_state()

	if self._log_state then
		if state == States.UNINITIALIZED then
			print("Session state: done!")
			self._log_state = nil
		else
			print("Session state: ", States [state])
		end
	end

	if #self._peer_queue > 0 and BackendSession.get_session_id() then
		local session_id = BackendSession.get_session_id()

		local network_manager = Managers.state.network

		for key, peer_id in ipairs(self._peer_queue) do
			self._peer_queue [key] = nil
			network_manager.network_transmit:send_rpc("rpc_backend_session_join", peer_id, session_id)
			self._peers [peer_id] = true
		end
	end

	local dice_data = self._dice_data
	if dice_data and dice_data.timeout < Managers.time:time("main") then
		for peer_id, _ in pairs(dice_data.players) do
			self:_dice_player_done(peer_id)
		end
		self._error_data = { reason = BACKEND_LUA_ERRORS.ERR_DICE_TIMEOUT2 }
	elseif self._post_dice_timeout then
		if state == States.UNINITIALIZED then
			self._post_dice_timeout = nil
		elseif self._post_dice_timeout < Managers.time:time("main") then

			self._post_dice_timeout = nil
		end
	end




end

function Session:add_peer(peer_id)
	local session_id = BackendSession.get_session_id()
	if session_id then
		local network_manager = Managers.state.network
		network_manager.network_transmit:send_rpc("rpc_backend_session_join", peer_id, session_id)
		self._peers [peer_id] = true
	else
		self._peer_queue [#self._peer_queue + 1] = peer_id
	end
end

function Session:end_of_round()
	local dice_players = table.clone(self._peers)
	dice_players [Network.peer_id()] = true
	local timeout = Managers.time:time("main") + 20
	self._dice_data = { players = dice_players, timeout = timeout }
	BackendSession.end_of_round()
end

function Session:received_dice_game_loot()
	self._post_dice_timeout = Managers.time:time("main") + 20
	local network_manager = Managers.state.network
	network_manager.network_transmit:send_rpc_server("rpc_backend_session_done")
end

function Session:check_for_errors()
	local error_data = self._error_data
	self._error_data = nil
	return error_data
end

BackendInterfaceSession = class(BackendInterfaceSession)

function BackendInterfaceSession:init()
	self._backend_session = Session:new()
end

function BackendInterfaceSession:setup(network_event_delegate, disable_for_level)
	if disable_for_level then
		self._backend_session:disable()
	else
		self._backend_session:register_rpcs(network_event_delegate)
	end
end

function BackendInterfaceSession:update()
	local backend_session = self._backend_session
	if backend_session:enabled() then

		backend_session:update()
	end

end

function BackendInterfaceSession:check_for_errors()
	return self._backend_session:check_for_errors()
end

function BackendInterfaceSession:add_peer(peer_id)
	local backend_session = self._backend_session
	if backend_session:enabled() then
		backend_session:add_peer(peer_id)
	end
end

function BackendInterfaceSession:start()
	if self._backend_session:enabled() then
		BackendSession.start()
	end
end

function BackendInterfaceSession:end_of_round()
	local backend_session = self._backend_session
	if backend_session:enabled() then
		backend_session:end_of_round()
	end
end

function BackendInterfaceSession:received_dice_game_loot()
	local backend_session = self._backend_session
	if backend_session:enabled() then
		backend_session:received_dice_game_loot()
	end
end

function BackendInterfaceSession:get_state()
	local state = BackendSession.get_state()
	return States [state]
end

function BackendInterfaceSession:leave()
	self._backend_session:reset()
end

BackendInterfaceSessionLocal = class(BackendInterfaceSessionLocal)

function BackendInterfaceSessionLocal:init()
	local mt = { }
	function mt.__index() return mt.__index end
	setmetatable(self, mt)

	self.is_local = true
end

function BackendInterfaceSessionLocal:ready()
	return true
end