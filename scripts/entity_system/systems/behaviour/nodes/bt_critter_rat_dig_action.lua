require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTCritterRatDigAction = class(BTCritterRatDigAction, BTNode)

function BTCritterRatDigAction:init(...)
	BTCritterRatDigAction.super.init(self, ...)
end

BTCritterRatDigAction.name = "BTCritterRatDigAction"

function BTCritterRatDigAction:enter(unit, blackboard, t)
	local navigation_extension = blackboard.navigation_extension
	navigation_extension:set_enabled(false)

	local locomotion_extension = blackboard.locomotion_extension
	locomotion_extension:set_wanted_velocity(Vector3.zero())

	Managers.state.network:anim_event(unit, "dig_ground")
end

function BTCritterRatDigAction:leave(unit, blackboard, t, reason, destroy)
	if reason ~= "aborted" then
		local conflict = Managers.state.conflict
		conflict:destroy_unit(unit, blackboard, "dig_ground")
	else
		blackboard.navigation_extension:set_enabled(true)
	end
end

function BTCritterRatDigAction:run(unit, blackboard, t)
	if blackboard.anim_cb_dig_finished then
		do return "done" end
	else
		return "running"
	end
end