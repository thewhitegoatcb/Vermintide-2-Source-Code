require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTDefendStandardAction = class(BTDefendStandardAction, BTNode)

function BTDefendStandardAction:init(...)
	BTDefendStandardAction.super.init(self, ...)
end

BTDefendStandardAction.name = "BTDefendStandardAction"

local function randomize(event)
	if type(event) == "table" then
		do return event [Math.random(1, #event)] end
	else
		return event
	end
end

function BTDefendStandardAction:enter(unit, blackboard, t)
	local action = self._tree_node.action_data
	blackboard.action = action
	blackboard.active_node = BTDefendStandardAction

	local ai_slot_system = Managers.state.entity:system("ai_slot_system")
	ai_slot_system:do_slot_search(unit, false)

	local position = Unit.local_position(blackboard.standard_unit, 0)

	blackboard.navigation_extension:move_to(position)
	blackboard.standard_position_boxed = Vector3Box(position)

	Managers.state.network:anim_event(unit, "move_start_fwd")

	blackboard.move_state = "moving"
	blackboard.moving_to_defend_standard = true
end

function BTDefendStandardAction:leave(unit, blackboard, t, reason, destroy)
	local default_move_speed = AiUtils.get_default_breed_move_speed(unit, blackboard)
	local navigation_extension = blackboard.navigation_extension
	navigation_extension:set_enabled(true)
	navigation_extension:set_max_speed(default_move_speed)

	blackboard.action = nil
	blackboard.active_node = nil
	blackboard.moving_to_defend_standard = nil
	blackboard.next_move_adjustment_t = nil
	blackboard.reached_standard = nil
	blackboard.standard_position_boxed = nil

	local ai_slot_system = Managers.state.entity:system("ai_slot_system")
	ai_slot_system:do_slot_search(unit, true)

	blackboard.move_state = "idle"
end

function BTDefendStandardAction:run(unit, blackboard, t, dt)
	if not HEALTH_ALIVE [blackboard.standard_unit] then
		return "done"
	end

	local standard_position = blackboard.standard_position_boxed:unbox()
	local self_position = POSITION_LOOKUP [unit]
	local distance_to_standard = Vector3.distance(standard_position, self_position)

	if distance_to_standard < 2.5 and not blackboard.reached_standard then
		blackboard.reached_standard = true
		Managers.state.network:anim_event(unit, "idle")
		self:_enable_navigation(blackboard, false)

		blackboard.next_move_adjustment_t = t + 1

		local navigation_extension = blackboard.navigation_extension
		navigation_extension:set_max_speed(blackboard.breed.walk_speed)
	end

	if blackboard.reached_standard then
		local target_unit = blackboard.target_unit

		if HEALTH_ALIVE [target_unit] then
			local rot = LocomotionUtils.rotation_towards_unit_flat(unit, target_unit)
			blackboard.locomotion_extension:set_wanted_rotation(rot)
			local target_distance_to_standard = blackboard.target_distance_to_standard
			if target_distance_to_standard and target_distance_to_standard < blackboard.breed.defensive_threshold_distance then
				return "done"
			end

			if blackboard.next_move_adjustment_t < t then
				self:_adjust_defend_position(unit, blackboard, target_unit, self_position, standard_position, rot)
				blackboard.next_move_adjustment_t = t + 1
			else
				local has_reached_destination = blackboard.navigation_extension:has_reached_destination()

				if has_reached_destination and not blackboard.has_reached_adjustment_position then
					self:_enable_navigation(blackboard, false)
					Managers.state.network:anim_event(unit, "idle")
					blackboard.has_reached_adjustment_position = true
				end
			end
		end
	end

	return "running"
end

function BTDefendStandardAction:_adjust_defend_position(unit, blackboard, target_unit, self_position, standard_position, rotation)
	local target_position = POSITION_LOOKUP [target_unit]
	local standard_to_target_direction = Vector3.normalize(target_position - standard_position)
	local wanted_move_position = standard_position + standard_to_target_direction * Math.random_range(1, 1.5)

	local nav_world = blackboard.nav_world
	local above = 1 local below = 1
	local is_on_navmesh, altitude = GwNavQueries.triangle_from_position(nav_world, wanted_move_position, above, below)
	local position_on_navmesh = nil

	if is_on_navmesh then
		position_on_navmesh = Vector3.copy(wanted_move_position)
		position_on_navmesh.z = altitude
	else
		local horizontal_limit = 1
		local distance_from_nav_border = 0.05
		position_on_navmesh = GwNavQueries.inside_position_from_outside_position(nav_world, wanted_move_position, above, below, horizontal_limit, distance_from_nav_border)
	end

	if position_on_navmesh then
		local distance_to_move_position = Vector3.distance(self_position, position_on_navmesh)

		if distance_to_move_position > 1 then
			self:_enable_navigation(blackboard, true)
			blackboard.has_reached_adjustment_position = nil
			blackboard.navigation_extension:move_to(position_on_navmesh)
			local wanted_move_direction = Vector3.normalize(position_on_navmesh - self_position)
			local walk_direction_identifier = self:_calculate_walk_dir(Quaternion.right(rotation), Quaternion.forward(rotation), wanted_move_direction, self_position)

			local walk_anim = self:_calculate_walk_animation(walk_direction_identifier)
			Managers.state.network:anim_event(unit, walk_anim)
			blackboard.move_state = "moving"
		end
	end
end

function BTDefendStandardAction:_enable_navigation(blackboard, enable)
	if enable then
		local navigation_extension = blackboard.navigation_extension
		navigation_extension:set_enabled(true)
	else
		local navigation_extension = blackboard.navigation_extension
		navigation_extension:set_enabled(false)
		blackboard.locomotion_extension:set_wanted_velocity(Vector3(0, 0, 0))
	end
end

function BTDefendStandardAction:_calculate_walk_animation(walk_dir)
	local anim = nil

	if walk_dir == "right" then
		anim = "move_right_walk"
	elseif walk_dir == "left" then
		anim = "move_left_walk"
	elseif walk_dir == "forward" then
		anim = "move_fwd_walk"
	else
		anim = "move_bwd_walk"
	end

	return anim
end

function BTDefendStandardAction:_calculate_walk_dir(right_vector, forward_vector, dir, pos)
	local right_dot = Vector3.dot(right_vector, dir)
	local fwd_dot = Vector3.dot(forward_vector, dir)

	local abs_right = math.abs(right_dot)
	local abs_fwd = math.abs(fwd_dot)

	if abs_fwd < abs_right and right_dot > 0 then
		dir = "right"
	elseif abs_fwd < abs_right then
		dir = "left"
	elseif fwd_dot > 0 then
		dir = "forward"
	else
		dir = "backward"
	end

	return dir
end