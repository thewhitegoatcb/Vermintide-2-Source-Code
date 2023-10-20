require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTTentacleSpawnAction = class(BTTentacleSpawnAction, BTNode)

function BTTentacleSpawnAction:init(...)
	BTTentacleSpawnAction.super.init(self, ...)
end

BTTentacleSpawnAction.name = "BTTentacleSpawnAction"

function BTTentacleSpawnAction:enter(unit, blackboard, t)
	local action = self._tree_node.action_data
	blackboard.action = action
	if action and action.duration then
		blackboard.spawn_finished_t = t + action.duration
	end

	local network_manager = Managers.state.network

	if action and action.animation then
		network_manager:anim_event(unit, action.animation)
	end
end

function BTTentacleSpawnAction:leave(unit, blackboard, t, reason, destroy)
	blackboard.spawn = false
end

function BTTentacleSpawnAction:run(unit, blackboard, t, dt)
	local action = blackboard.action
	if action and action.duration then
		if blackboard.spawn_finished_t < t then
			blackboard.spawn_finished_t = nil
			return "done"
		end
		do return "running" end
	else
		return "done"
	end
end