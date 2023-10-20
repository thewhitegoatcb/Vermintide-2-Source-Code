require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTDefensiveIdleAction = class(BTDefensiveIdleAction, BTNode)

function BTDefensiveIdleAction:init(...)
	BTDefensiveIdleAction.super.init(self, ...)
end

BTDefensiveIdleAction.name = "BTDefensiveIdleAction"

function BTDefensiveIdleAction:enter(unit, blackboard, t)
	local network_manager = Managers.state.network
	local action = self._tree_node.action_data
	blackboard.action = action
	blackboard.active_node = BTDefensiveIdleAction

	local animation = action.animation

	network_manager:anim_event(unit, animation)
	blackboard.move_state = "idle"
	if action.sound_event then
		local audio_system = Managers.state.entity:system("audio_system")
		audio_system:play_audio_unit_event(action.sound_event, unit)
	end

	blackboard.navigation_extension:set_enabled(false)
	blackboard.locomotion_extension:set_wanted_velocity(Vector3.zero())

	blackboard.idle_end_time = t + action.duration
end

function BTDefensiveIdleAction:leave(unit, blackboard, t, reason, destroy)

	blackboard.navigation_extension:set_enabled(true)
end

function BTDefensiveIdleAction:run(unit, blackboard, t, dt)
	if blackboard.idle_end_time < t then
		return "done"
	end
	return "running"
end