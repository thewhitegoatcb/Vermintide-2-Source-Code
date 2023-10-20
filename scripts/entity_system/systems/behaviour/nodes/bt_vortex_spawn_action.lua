require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTVortexSpawnAction = class(BTVortexSpawnAction, BTNode)

function BTVortexSpawnAction:init(...)
	BTVortexSpawnAction.super.init(self, ...)
end

BTVortexSpawnAction.name = "BTVortexSpawnAction"

function BTVortexSpawnAction:enter(unit, blackboard, t)
	local current_position = POSITION_LOOKUP [unit]
	local nav_world = blackboard.nav_world
	local is_position_on_navmesh = GwNavQueries.triangle_from_position(nav_world, current_position, 0.5, 0.5)
	if not is_position_on_navmesh then
		local conflict_director = Managers.state.conflict
		conflict_director:destroy_unit(unit, blackboard, "no_navmesh")
	end
end

function BTVortexSpawnAction:leave(unit, blackboard, t, reason, destroy)
	blackboard.spawn = false
end

function BTVortexSpawnAction:run(unit, blackboard, t, dt)
	return "done"
end