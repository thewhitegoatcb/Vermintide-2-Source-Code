require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTGlobadierSuicideStaggerAction = class(BTGlobadierSuicideStaggerAction, BTNode)

BTGlobadierSuicideStaggerAction.name = "BTGlobadierSuicideStaggerAction"

function BTGlobadierSuicideStaggerAction:init(...)
	BTGlobadierSuicideStaggerAction.super.init(self, ...)
end

function BTGlobadierSuicideStaggerAction:enter(unit, blackboard, t)
	local damage_type = "kinetic"
	local damage_direction = Vector3(0, 0, -1)
	AiUtils.kill_unit(unit, nil, nil, damage_type, damage_direction)
end

function BTGlobadierSuicideStaggerAction:leave(unit, blackboard, t, reason, destroy)

	return end

function BTGlobadierSuicideStaggerAction:run(unit, blackboard, t, dt)
	return "done"
end