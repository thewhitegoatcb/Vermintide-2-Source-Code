require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTSkulkIdleAction = class(BTSkulkIdleAction, BTNode)
BTSkulkIdleAction.name = "BTSkulkIdleAction"

function BTSkulkIdleAction:init(...)
	BTSkulkIdleAction.super.init(self, ...)
end

function BTSkulkIdleAction:enter(unit, blackboard, t)
	local action = self._tree_node.action_data
	blackboard.action = action

	local skulk_data = blackboard.skulk_data
	skulk_data.skulk_idle_timer = t + math.random(5, 10)

	Managers.state.network:anim_event(unit, "to_crouch")
	Managers.state.network:anim_event(unit, "idle")
	blackboard.navigation_extension:set_enabled(false)
	blackboard.locomotion_extension:set_wanted_velocity(Vector3.zero())

	local ai_simple_extension = ScriptUnit.extension(unit, "ai_system")
	ai_simple_extension:set_perception("perception_all_seeing_re_evaluate", "pick_ninja_skulking_target")

	if not skulk_data.attack_timer or skulk_data.attack_timer < t then
		skulk_data.attack_timer = t + math.random(25, 30)
	end

end

function BTSkulkIdleAction:leave(unit, blackboard, t, reason, destroy)

	Managers.state.network:anim_event(unit, "to_upright")

	if blackboard.approach_target then
		local skulk_data = blackboard.skulk_data
		skulk_data.attack_timer = nil
	end

	blackboard.navigation_extension:set_enabled(true)
end


local found_units = { }
local move_distance_squared = 400
function BTSkulkIdleAction:run(unit, blackboard, t, dt)

	local skulk_data = blackboard.skulk_data


	if skulk_data.attack_timer < t then
		blackboard.approach_target = true
		return "failed"
	end


	local urgency_to_engage = PerceptionUtils.special_opportunity(unit, blackboard)
	if urgency_to_engage > 0 then
		blackboard.approach_target = true
		return "failed"
	end


	if skulk_data.skulk_idle_timer < t then
		return "done"
	end


	local pos = POSITION_LOOKUP [unit]
	local side = blackboard.side
	local enemy_player_and_bot_positions = side.ENEMY_PLAYER_AND_BOT_POSITIONS
	for i = 1, #enemy_player_and_bot_positions do
		local enemy_pos = enemy_player_and_bot_positions [i]
		if Vector3.distance_squared(pos, enemy_pos) < move_distance_squared then
			return "done"
		end
	end

	return "running"
end

function BTSkulkIdleAction:pick_new_hiding_place(unit, blackboard, t, dt)

	return end