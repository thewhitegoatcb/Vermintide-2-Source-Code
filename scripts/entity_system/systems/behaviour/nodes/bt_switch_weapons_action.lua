require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTSwitchWeaponsAction = class(BTSwitchWeaponsAction, BTNode)
BTSwitchWeaponsAction.name = "BTSwitchWeaponsAction"

function BTSwitchWeaponsAction:init(...)
	BTSwitchWeaponsAction.super.init(self, ...)
end

function BTSwitchWeaponsAction:enter(unit, blackboard, t)
	local action = self._tree_node.action_data
	blackboard.action = action
	blackboard.active_node = BTSwitchWeaponsAction

	blackboard.navigation_extension:set_enabled(false)
	blackboard.locomotion_extension:set_wanted_velocity(Vector3(0, 0, 0))

	local ai_inventory_ext = ScriptUnit.has_extension(unit, "ai_inventory_system")
	local wanted_set = action and action.switch_weapon_index or blackboard.switching_weapons
	ai_inventory_ext:wield_item_set(wanted_set)
	blackboard.inventory_item_set = wanted_set
	blackboard.switching_done_time = t + (action and action.switch_done_time or 0.75)
	blackboard.move_state = "idle"
	local switch_animation = action and action.switch_animation

	if switch_animation then
		Managers.state.network:anim_event(unit, switch_animation)
	end
end

function BTSwitchWeaponsAction:leave(unit, blackboard, t, reason, destroy)
	blackboard.switching_weapons = false
	blackboard.has_switched_weapons = true
	blackboard.spawn_to_running = nil

	local navigation_extension = blackboard.navigation_extension
	navigation_extension:set_enabled(true)
end

function BTSwitchWeaponsAction:run(unit, blackboard, t, dt)

	if blackboard.switching_done_time < t then
		return "done"
	end

	return "running"
end