require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTPackMasterHoistAction = class(BTPackMasterHoistAction, BTNode)

function BTPackMasterHoistAction:init(...)
	BTPackMasterHoistAction.super.init(self, ...)
end

BTPackMasterHoistAction.name = "BTPackMasterHoistAction"

function BTPackMasterHoistAction:enter(unit, blackboard, t)
	local action = self._tree_node.action_data
	blackboard.action = action
	blackboard.hosting_end_time = t + action.hoist_anim_length

	StatusUtils.set_grabbed_by_pack_master_network("pack_master_hoisting", blackboard.drag_target_unit, true, unit)

	LocomotionUtils.set_animation_driven_movement(unit, true, false, false)

	AiUtils.show_polearm(unit, false)
end

function BTPackMasterHoistAction:leave(unit, blackboard, t, reason, destroy)
	if reason == "done" then
		blackboard.needs_hook = true
		AiUtils.show_polearm(unit, false)
	else
		if Unit.alive(blackboard.drag_target_unit) then

			StatusUtils.set_grabbed_by_pack_master_network("pack_master_hoisting", blackboard.drag_target_unit, false, unit)
		end
		AiUtils.show_polearm(unit, true)
		blackboard.target_unit = nil
	end

	blackboard.drag_target_unit = nil
	blackboard.attack_cooldown = t + blackboard.action.cooldown

	if not destroy then
		LocomotionUtils.set_animation_driven_movement(unit, false)
		blackboard.locomotion_extension:set_movement_type("snap_to_navmesh")
	end
end

function BTPackMasterHoistAction:run(unit, blackboard, t, dt)
	local drag_target_unit = blackboard.drag_target_unit
	if not AiUtils.is_of_interest_to_packmaster(unit, drag_target_unit) then

		local status_extension = ScriptUnit.extension(drag_target_unit, "status_system")
		if not status_extension:is_knocked_down() then
			return "failed"
		end
	end

	if blackboard.hosting_end_time < t then
		StatusUtils.set_grabbed_by_pack_master_network("pack_master_hanging", drag_target_unit, true, unit)
		return "done"
	end

	return "running"
end