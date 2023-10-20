MatchmakingStateFriendClient = class(MatchmakingStateFriendClient)
MatchmakingStateFriendClient.NAME = "MatchmakingStateFriendClient"

function MatchmakingStateFriendClient:init(params)
	self.matchmaking_manager = params.matchmaking_manager
	self.wwise_world = params.wwise_world
	self.lobby = params.lobby
	self.network_transmit = params.network_transmit
	self.params = params
end

function MatchmakingStateFriendClient:destroy()
	return end

function MatchmakingStateFriendClient:on_enter(state_context)
	self._game_server_data = nil
	self._state_context = state_context






end















































function MatchmakingStateFriendClient:on_exit()
	return end

function MatchmakingStateFriendClient:update(dt, t)
	if not Managers.state.game_mode then
		return
	end

	local level_key = Managers.state.game_mode:level_key()
	local level_settings = LevelSettings [level_key]

	if not level_settings.hub_level then
		return
	end

	local gamepad_active_last_frame = self._gamepad_active_last_frame
	local gamepad_active = Managers.input:is_device_active("gamepad")

	self._gamepad_active_last_frame = gamepad_active
end

function MatchmakingStateFriendClient:get_transition()
	if self._game_server_data then
		return "join_server", self._game_server_data
	end
end

function MatchmakingStateFriendClient:rpc_matchmaking_broadcast_game_server_ip_address(channel_id, ip_address)
	self._game_server_data = {
		server_info = {
			ip_port = ip_address } }


end