require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTThrowRockAction = class(BTThrowRockAction, BTNode)

function BTThrowRockAction:init(...)
	BTThrowRockAction.super.init(self, ...)
end

BTThrowRockAction.name = "BTThrowRockAction"

function BTThrowRockAction:enter(unit, blackboard, t)
	local action = self._tree_node.action_data
	Managers.state.network:anim_event(unit, action.attack_anim)
	blackboard.attack_cooldown = t + action.cooldown




end

function BTThrowRockAction:leave(unit, blackboard, t, reason, destroy)
	print("BTThrowRockAction LEAVE")
	blackboard.running_attack_action = nil
end

function BTThrowRockAction:run(unit, blackboard, t, dt)

	local rot = LocomotionUtils.rotation_towards_unit(unit, blackboard.target_unit)
	local locomotion = blackboard.locomotion_extension
	locomotion:set_wanted_rotation(rot)

	if blackboard.attack_cooldown < t then
		blackboard.running_attack_action = nil
	end
end