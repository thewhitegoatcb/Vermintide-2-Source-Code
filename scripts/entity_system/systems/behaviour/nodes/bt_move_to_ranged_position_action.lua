require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTMoveToRangedPositionAction = class(BTMoveToRangedPositionAction, BTNode)

function BTMoveToRangedPositionAction:init(...)
	BTMoveToRangedPositionAction.super.init(self, ...)
end

BTMoveToRangedPositionAction.name = "BTMoveToRangedPositionAction"

function BTMoveToRangedPositionAction:enter(unit, blackboard, t)
	local action = self._tree_node.action_data
	blackboard.action = action
	blackboard.move_state = "moving"

	local navigation_extension = blackboard.navigation_extension
	local move_animation = action.move_animation
	local network_manager = Managers.state.network
	network_manager:anim_event(unit, move_animation)

	local ai_slot_system = Managers.state.entity:system("ai_slot_system")
	ai_slot_system:do_slot_search(unit, false)

	blackboard.next_t_to_evaluate = t + 0.5

	local nav_bot = navigation_extension._nav_bot
	GwNavBot.set_use_avoidance(nav_bot, true)
end

function BTMoveToRangedPositionAction:leave(unit, blackboard, t, reason, destroy)
	blackboard.ranged_position = nil
	blackboard.action = nil
	blackboard.next_t_to_evaluate = nil

	local nav_bot = blackboard.navigation_extension._nav_bot
	GwNavBot.set_use_avoidance(nav_bot, false)
end

function BTMoveToRangedPositionAction:run(unit, blackboard, t, dt)

	if not Unit.alive(blackboard.target_unit) then
		return "done"
	end

	local wanted_position = blackboard.ranged_position:unbox()
	local distance = Vector3.distance(POSITION_LOOKUP [unit], wanted_position)

	if distance < 1.5 then
		local ai_slot_system = Managers.state.entity:system("ai_slot_system")
		ai_slot_system:do_slot_search(unit, true)

		return "done"
	end

	if blackboard.next_t_to_evaluate < t then
		blackboard.next_t_to_evaluate = t + Math.random_range(1.2, 2)
		return "running", "evaluate"
	end

	return "running"
end