


SimpleDoorExtension = class(SimpleDoorExtension)

local SIMPLE_ANIMATION_FPS = 30
local unit_alive = Unit.alive

function SimpleDoorExtension:init(extension_init_context, unit, extension_init_data)
	local world = extension_init_context.world
	self.unit = unit
	self.world = world
	self.is_server = Managers.player.is_server
	self.ignore_umbra = not World.umbra_available(world)
	self.is_umbra_gate = Unit.get_data(unit, "umbra_gate")
	local door_state = Unit.get_data(unit, "door_state")
	self.current_state = door_state == 0 and "open_forward" or door_state == 1 and "closed"

	self.animation_stop_time = 0
end

function SimpleDoorExtension:destroy()
	self:destroy_box_obstacle()

	self.unit = nil
	self.world = nil
end

function SimpleDoorExtension:destroy_box_obstacle()
	local obstacle = self.obstacle
	if obstacle then
		GwNavBoxObstacle.destroy(obstacle)
	end
end

function SimpleDoorExtension:extensions_ready()
	return end


function SimpleDoorExtension:interacted_with(interacting_unit)
	return end

function SimpleDoorExtension:is_opening()
	return self.current_state ~= "closed" and self.animation_stop_time
end

function SimpleDoorExtension:is_open()
	return self.current_state ~= "closed"
end

function SimpleDoorExtension:get_current_state()
	return self.current_state
end

function SimpleDoorExtension:set_door_state_and_duration(new_state, frames, speed)
	local current_state = self.current_state

	if current_state == new_state then
		return
	end

	local unit = self.unit

	local closed = new_state == "closed"
	if not closed and not self.ignore_umbra and self.is_umbra_gate then
		World.umbra_set_gate_closed(self.world, unit, closed)
	end

	self.current_state = new_state

	local animation_length = frames / SIMPLE_ANIMATION_FPS / speed
	local t = Managers.time:time("game")
	self.animation_stop_time = t + animation_length
end

function SimpleDoorExtension:hot_join_sync(sender)
	return end

function SimpleDoorExtension:update_nav_obstacle()
	local current_state = self.current_state
	local obstacle = self.obstacle

	if obstacle == nil then
		local transform = nil
		local unit = self.unit
		local nav_world = GLOBAL_AI_NAVWORLD
		obstacle, transform = NavigationUtils.create_exclusive_box_obstacle_from_unit_data(nav_world, unit)

		GwNavBoxObstacle.add_to_world(obstacle)
		GwNavBoxObstacle.set_transform(obstacle, transform)

		self.obstacle = obstacle
	end

	local does_trigger = current_state == "closed"
	GwNavBoxObstacle.set_does_trigger_tagvolume(obstacle, does_trigger)
end

function SimpleDoorExtension:update(unit, input, dt, context, t)
	local animation_stop_time = self.animation_stop_time
	if animation_stop_time and animation_stop_time <= t then
		self:update_nav_obstacle()
		self.animation_stop_time = nil

		local closed = self.current_state == "closed"
		if closed and not self.ignore_umbra and self.is_umbra_gate then
			World.umbra_set_gate_closed(self.world, unit, closed)
		end
	end
end