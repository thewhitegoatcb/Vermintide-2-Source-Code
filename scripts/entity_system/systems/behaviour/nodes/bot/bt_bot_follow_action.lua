require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTBotFollowAction = class(BTBotFollowAction, BTNode)

function BTBotFollowAction:init(...)
	BTBotFollowAction.super.init(self, ...)
end

BTBotFollowAction.name = "BTBotFollowAction"

function BTBotFollowAction:enter(unit, blackboard, t)
	blackboard.has_teleported = false
	local goal_selection = self._tree_node.action_data.goal_selection
	blackboard.follow.goal_selection_func = goal_selection
	blackboard.follow.needs_target_position_refresh = true
end

function BTBotFollowAction:leave(unit, blackboard, t, reason, destroy)
	blackboard.follow.goal_selection_func = nil
end

function BTBotFollowAction:run(unit, blackboard, t, dt)
	return "running", "evaluate"
end