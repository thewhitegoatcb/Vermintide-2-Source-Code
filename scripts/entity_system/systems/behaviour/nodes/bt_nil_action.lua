require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTNilAction = class(BTNilAction, BTNode)

function BTNilAction:init(...)
	BTNilAction.super.init(self, ...)
end

BTNilAction.name = "BTNilAction"

function BTNilAction:enter()
	return end

function BTNilAction:leave()
	return end

function BTNilAction:run(unit, blackboard, t, dt, bt_name)
	return "running"
end