require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTTeleportToCommanderAction = class(BTTeleportToCommanderAction, BTNode)

function BTTeleportToCommanderAction:init(...)
	BTTeleportToCommanderAction.super.init(self, ...)
end

BTTeleportToCommanderAction.name = "BTTeleportToCommanderAction"

function BTTeleportToCommanderAction:enter(unit, blackboard, t)
	self.commander_system = Managers.state.entity:system("ai_commander_system")
end

function BTTeleportToCommanderAction:leave(unit, blackboard, t, reason, destroy)
	return end

local CHECKS_PER_DIRECTION = 5
local ANGLE_INCREMENT = math.pi / (2 * CHECKS_PER_DIRECTION)
local CHECK_DISTANCE = 5

function BTTeleportToCommanderAction:run(unit, blackboard, t, dt)

	local commander_unit = self.commander_system:get_commander_unit(unit)
	if not ALIVE [commander_unit] then
		return "done"
	end


	local career_extension = ScriptUnit.extension(commander_unit, "career_system")
	local passive = career_extension:get_passive_ability_by_name("bw_necromancer")
	passive:resummon_pet(unit)





























































	return "done"
end