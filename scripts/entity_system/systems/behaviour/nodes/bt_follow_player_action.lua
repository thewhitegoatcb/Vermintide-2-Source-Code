require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTFollowPlayerAction = class(BTFollowPlayerAction, BTNode)

function BTFollowPlayerAction:init(...)
	BTFollowPlayerAction.super.init(self, ...)
end

BTFollowPlayerAction.name = "BTFollowPlayerAction"

function BTFollowPlayerAction:enter(unit, blackboard, t)
	local locomotion = blackboard.locomotion_extension
	locomotion:enter_state_combat(blackboard, t)
end

function BTFollowPlayerAction:leave(unit, blackboard, t, reason, destroy)

	return end

function BTFollowPlayerAction:run(unit, blackboard, t)

	if not Unit.alive(blackboard.target_unit) then
		return
	end

	return self

end

function BTFollowPlayerAction:exit_running(unit, blackboard, t)
	local locomotion = blackboard.locomotion_extension
	locomotion:enter_state_onground(blackboard, t)
end