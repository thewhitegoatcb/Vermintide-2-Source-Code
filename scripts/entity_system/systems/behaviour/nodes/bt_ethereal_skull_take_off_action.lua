require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTEtherealSkullTakeOffAction = class(BTEtherealSkullTakeOffAction, BTNode)

function BTEtherealSkullTakeOffAction:init(...)
	BTEtherealSkullTakeOffAction.super.init(self, ...)
end

BTEtherealSkullTakeOffAction.name = "BTEtherealSkullTakeOffAction"

function BTEtherealSkullTakeOffAction:enter()
	self._duration = 2
end

function BTEtherealSkullTakeOffAction:leave(unit, blackboard, t, reason, destroy)

	return end

function BTEtherealSkullTakeOffAction:run(unit, blackboard, t, dt, bt_name)
	if not blackboard.take_off_duration then
		blackboard.take_off_duration = t + 2
	end

	if t < blackboard.take_off_duration then
		return "done"
	end

	return "running"
end