require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTCritterNurglingWaitAction = class(BTCritterNurglingWaitAction, BTNode)

function BTCritterNurglingWaitAction:init(...)
	BTCritterNurglingWaitAction.super.init(self, ...)
end

BTCritterNurglingWaitAction.name = "BTCritterNurglingWaitAction"

function BTCritterNurglingWaitAction:enter(unit, blackboard, t)
	local wait_data = self._tree_node.action_data
	blackboard.exit_wait_time = t + Math.random_range(wait_data.wait_time_min, wait_data.wait_time_max)

	if blackboard.move_state ~= "idle" then
		self:start_idle_animation(unit, blackboard)
		blackboard.move_state = "idle"
	end
end

function BTCritterNurglingWaitAction:leave(unit, blackboard, t, reason, destroy)
	blackboard.exit_wait_time = nil
end

function BTCritterNurglingWaitAction:run(unit, blackboard, t)
	if blackboard.exit_wait_time < t then
		return "done"
	end

	return "running"
end

function BTCritterNurglingWaitAction:start_idle_animation(unit, blackboard)
	Managers.state.network:anim_event(unit, "idle")
	blackboard.move_state = "idle"
end