MatchmakingStateIdle = class(MatchmakingStateIdle)
MatchmakingStateIdle.NAME = "MatchmakingStateIdle"

function MatchmakingStateIdle:init(params, reason)
	self.lobby = params.lobby
	self.reason = reason
end

function MatchmakingStateIdle:destroy()
	return end

function MatchmakingStateIdle:on_enter(state_context)
	self.state_context = state_context
end

function MatchmakingStateIdle:on_exit()
	self.reason = nil
end

function MatchmakingStateIdle:update(dt, t)

	return nil
end