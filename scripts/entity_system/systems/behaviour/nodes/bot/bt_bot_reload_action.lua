require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTBotReloadAction = class(BTBotReloadAction, BTNode)

function BTBotReloadAction:init(...)
	BTBotReloadAction.super.init(self, ...)
end

BTBotReloadAction.name = "BTBotReloadAction"

function BTBotReloadAction:enter(unit, blackboard, t)
	blackboard.reloading = true
end

function BTBotReloadAction:leave(unit, blackboard, t, reason, destroy)
	blackboard.reloading = false
end

function BTBotReloadAction:run(unit, blackboard, t, dt)
	local input_extension = blackboard.input_extension
	input_extension:weapon_reload()

	return "running", "evaluate"
end