require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTBotHealAction = class(BTBotHealAction, BTNode)

function BTBotHealAction:init(...)
	BTBotHealAction.super.init(self, ...)
end

BTBotHealAction.name = "BTBotHealAction"


function BTBotHealAction:enter(unit, blackboard, t)
	local health_extension = blackboard.health_extension
	local health_percent = health_extension:current_health_percent()
	blackboard.starting_health_percent = health_percent

	blackboard.is_healing_self = true
end

function BTBotHealAction:leave(unit, blackboard, t, reason, destroy)
	blackboard.force_use_health_pickup = nil
	blackboard.starting_health_percent = nil

	blackboard.is_healing_self = false
end

function BTBotHealAction:run(unit, blackboard, t, dt)
	if blackboard.force_use_health_pickup then

		local health_extension = blackboard.health_extension
		local health_percent = health_extension:current_health_percent()
		if blackboard.starting_health_percent < health_percent then
			return "done"
		end
	end
	blackboard.input_extension:hold_attack()

	return "running"
end