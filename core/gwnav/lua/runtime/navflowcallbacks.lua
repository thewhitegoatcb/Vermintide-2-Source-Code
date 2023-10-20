require("core/gwnav/lua/safe_require")
GwNavFlowCallbacks = safe_require_guard()

local NavRoute = safe_require("core/gwnav/lua/runtime/navroute")
local NavWorld = safe_require("core/gwnav/lua/runtime/navworld")
local NavBot = safe_require("core/gwnav/lua/runtime/navbot")
local NavBoxObstacle = safe_require("core/gwnav/lua/runtime/navboxobstacle")
local NavCylinderObstacle = safe_require("core/gwnav/lua/runtime/navcylinderobstacle")

local Unit = stingray.Unit
local Vector3 = stingray.Vector3
local Vector3Box = stingray.Vector3Box
local Matrix4x4 = stingray.Matrix4x4

local routes = { }

function GwNavFlowCallbacks.create_navworld(t)
	NavWorld(Unit.world(t.unit), Unit.level(t.unit))
end

function GwNavFlowCallbacks.destroy_navworld(t)
	local world = NavWorld.get_navworld(Unit.level(t.unit))
	world:shutdown()
end

function GwNavFlowCallbacks.update_navworld(t)
	local world = NavWorld.get_navworld(Unit.level(t.unit))
	world:update(t.delta_time)
end

function GwNavFlowCallbacks.add_navmesh(t)
	local world = NavWorld.get_navworld(Unit.level(t.unit))
	world:add_navdata(t.name)
end

function GwNavFlowCallbacks.create_navbot(t)
	local world = NavWorld.get_navworld(Unit.level(t.unit))
	if t.bot_configuration ~= nil then
		world:init_bot_from_unit(t.unit, t.bot_configuration)
	else
		world:init_bot(t.unit)
	end
end

function GwNavFlowCallbacks.destroy_navbot(t)
	local bot = NavBot.get_navbot(t.unit)
	if bot then
		bot:shutdown()
	end
end

function GwNavFlowCallbacks.navbot_velocity(t)
	local bot = NavBot.get_navbot(t.unit)
	if bot then
		t.input_velocity = bot:velocity()
	else
		t.input_velocity = Vector3(0, 0, 0)
	end
	return t
end

function GwNavFlowCallbacks.navbot_output_velocity(t)
	local bot = NavBot.get_navbot(t.unit)
	if bot then
		t.output_velocity = bot:output_velocity()
	else
		t.output_velocity = Vector3(0, 0, 0)
	end
	return t
end

function GwNavFlowCallbacks.navbot_local_output_velocity(t)
	local bot = NavBot.get_navbot(t.unit)
	if bot then
		t.local_output_velocity = Matrix4x4.transform_without_translation(Matrix4x4.inverse(Unit.local_pose(t.unit, 1)), bot:output_velocity())
	else
		t.local_output_velocity = Vector3(0, 0, 0)
	end
	return t
end

function GwNavFlowCallbacks.navbot_destination(t)
	local bot = NavBot.get_navbot(t.unit)
	if bot then
		t.destination = bot.destination:unbox()
	else
		t.destination = Vector3(0, 0, 0)
	end
	return t
end

function GwNavFlowCallbacks.set_navbot_destination(t)
	local bot = NavBot.get_navbot(t.unit)
	if bot then
		bot:set_destination(t.destination)
	end
end

function GwNavFlowCallbacks.navbot_move_unit(t)
	local bot = NavBot.get_navbot(t.unit)
	if bot then
		bot:move_unit(t.delta_time)
	end
end

function GwNavFlowCallbacks.navbot_move_unit_with_mover(t)
	local bot = NavBot.get_navbot(t.unit)
	if bot then
		bot:move_unit_with_mover(t.delta_time, t.gravity)
	end
end

function GwNavFlowCallbacks.set_navbot_route(t)
	local route = routes [t.id]
	if route then
		local bot = NavBot.get_navbot(t.unit)
		if bot then
			bot:set_route(route:positions())
		end
	end
end

function GwNavFlowCallbacks.navbot_set_layer_cost_multiplier(t)
	local bot = NavBot.get_navbot(t.unit)
	if bot then
		bot:set_layer_cost_multiplier(t.layer, t.cost)
	end
end

function GwNavFlowCallbacks.navbot_allow_layer(t)
	local bot = NavBot.get_navbot(t.unit)
	if bot then
		bot:allow_layer(t.layer)
	end
end

function GwNavFlowCallbacks.navbot_forbid_layer(t)
	local bot = NavBot.get_navbot(t.unit)
	if bot then
		bot:forbid_layer(t.layer)
	end
end

function GwNavFlowCallbacks.create_route(t)
	t.route_id = tostring(#routes + 1)
	routes [t.route_id] = NavRoute()
	return t
end

function GwNavFlowCallbacks.add_position_to_route(t)
	local route = routes [t.route_id]
	if route then
		route:add_position(Unit.local_position(t.unit, 1))
	end
end

function GwNavFlowCallbacks.navboxobstacle_create(t)
	local world = NavWorld.get_navworld(Unit.level(t.world_unit))
	world:add_boxobstacle(t.obstacle_unit)
end

function GwNavFlowCallbacks.navboxobstacle_destroy(t)
	local box = NavBoxObstacle.get_navboxstacle(t.obstacle_unit)
	if box then
		box:shutdown()
	end
end

function GwNavFlowCallbacks.cylinderobstacle_create(t)
	local world = NavWorld.get_navworld(Unit.level(t.world_unit))
	world:add_cylinderobstacle(t.obstacle_unit)
end

function GwNavFlowCallbacks.cylinderobstacle_destroy(t)
	local cylinder = NavCylinderObstacle.get_navcylinderostacle(t.obstacle_unit)
	if cylinder then
		cylinder:shutdown()
	end
end

return GwNavFlowCallbacks