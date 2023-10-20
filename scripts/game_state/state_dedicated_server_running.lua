

StateDedicatedServerRunning = class(StateDedicatedServerRunning)
StateDedicatedServerRunning.NAME = "StateDedicatedServerRunning"

function StateDedicatedServerRunning:on_enter(params)
	local loading_context = self.parent.parent.loading_context

	self._game_server = loading_context.game_server
end

function StateDedicatedServerRunning:update(dt, t)
	local game_server = self._game_server
	local old_state = game_server:state()

	local new_state = game_server:update(dt, t)

	if
	old_state ~= new_state and new_state == GameServerState.DISCONNECTED then
		error("DISCONNECTED, RESTART!")
	end

end

function StateDedicatedServerRunning:on_exit()
	return end