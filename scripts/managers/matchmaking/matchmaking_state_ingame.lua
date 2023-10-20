MatchmakingStateIngame = class(MatchmakingStateIngame)
MatchmakingStateIngame.NAME = "MatchmakingStateIngame"

function MatchmakingStateIngame:init(params)
	self.lobby = params.lobby
	self.matchmaking_manager = params.matchmaking_manager
end

function MatchmakingStateIngame:destroy()
	return end

function MatchmakingStateIngame:on_enter(state_context)
	self.state_context = state_context
end

function MatchmakingStateIngame:on_exit()
	return end

function MatchmakingStateIngame:update(dt, t)
	return nil
end