local NAVIGATION_NAVMESH_RADIUS = 0.38

script_data.debug_ai_movement = script_data.debug_ai_movement or Development.parameter("debug_ai_movement")

AINavigationExtension = class(AINavigationExtension)

function AINavigationExtension:init(extension_init_context, unit, extension_init_data)
	self._nav_world = extension_init_data.nav_world
	self._unit = unit

	self._enabled = true
	self._max_speed = 0
	self._movement_modifier = 1
	self._current_speed = 0
	self._wanted_destination = Vector3Box(Unit.local_position(unit, 0))
	self._destination = Vector3Box()

	self._using_smartobject = false
	self._next_smartobject_interval = GwNavSmartObjectInterval.create(self._nav_world)

	self._backup_destination = Vector3Box()
	self._original_backup_destination = Vector3Box()

	self._is_navbot_following_path = false
	self._is_computing_path = false

	self._failed_move_attempts = 0
	self._wait_timer = 0
	self._raycast_timer = 0


	local modifier_table_size = 8
	self._movement_modifiers = Script.new_array(modifier_table_size)
	self._num_movement_modifiers = 0
	self._movement_modifier_table_size = modifier_table_size
	self._last_movement_modifier_index = 1
end

function AINavigationExtension:extensions_ready()
	local blackboard = BLACKBOARDS [self._unit]
	self._blackboard = blackboard
	blackboard.next_smart_object_data = {

		entrance_pos = Vector3Box(),
		exit_pos = Vector3Box() }

	self._far_pathing_allowed = blackboard.breed.cannot_far_path ~= true
end

function AINavigationExtension:destroy()
	self:release_bot()
	GwNavSmartObjectInterval.destroy(self._next_smartobject_interval)
end

function AINavigationExtension:freeze()
	self:release_bot()
end

function AINavigationExtension:unfreeze()
	local blackboard = self._blackboard
	local next_smart_object_data = blackboard.next_smart_object_data
	next_smart_object_data.next_smart_object_id = nil
	next_smart_object_data.smart_object_type = nil
	self._far_pathing_allowed = blackboard.breed.cannot_far_path ~= true
	self._enabled = true
	self._using_smartobject = false
	self._is_navbot_following_path = false
	self._is_computing_path = false
	self._failed_move_attempts = 0
	self._wait_timer = 0
	self._raycast_timer = 0
	self._num_movement_modifiers = 0
	self._last_movement_modifier_index = 1
end

function AINavigationExtension:set_far_pathing_allowed(far_pathing_allowed)
	self._far_pathing_allowed = far_pathing_allowed
end

function AINavigationExtension:release_bot()
	if self._navtag_layer_cost_table then
		GwNavTagLayerCostTable.destroy(self._navtag_layer_cost_table)
		self._navtag_layer_cost_table = nil
	end
	if self._nav_cost_map_cost_table then
		GwNavCostMap.destroy_tag_cost_table(self._nav_cost_map_cost_table)
		self._nav_cost_map_cost_table = nil
	end
	if self._nav_bot then
		GwNavBot.destroy(self._nav_bot)
		self._nav_bot = nil
	end
	self._traverse_logic = nil
end

local DEFAULT_AVOIDANCE_CONFIG = { half_height = 0.5, radius = 4, frame_delay = 45, enable_forcing = true, sample_count = 20, enable_stop = false, stop_wait_time_s = 1, enable_slowing = true, forcing_time_s = 1, angle_span = 75, time_to_collision = 1.25, forcing_wait_time_s = 0.2 }

















function AINavigationExtension:init_position()
	local unit = self._unit
	local nav_world = self._nav_world
	local breed = Unit.get_data(unit, "breed")
	local height = 1.6
	local speed = breed.run_speed
	local pos = Unit.local_position(unit, 0)
	local enable_crowd_dispersion = not script_data.disable_crowd_dispersion and not breed.disable_crowd_dispersion

	local nav_cost_map_allowed_layers = { }
	if breed.nav_cost_map_allowed_layers then
		table.merge(nav_cost_map_allowed_layers, breed.nav_cost_map_allowed_layers)
	end
	local nav_cost_map_cost_table = GwNavCostMap.create_tag_cost_table()
	fassert(self._nav_cost_map_cost_table == nil, "Tried to create navbot cost table but already had one, freeze bug?")
	self._nav_cost_map_cost_table = nav_cost_map_cost_table
	AiUtils.initialize_nav_cost_map_cost_table(nav_cost_map_cost_table, nav_cost_map_allowed_layers)

	local nav_bot = GwNavBot.create(nav_world, height, NAVIGATION_NAVMESH_RADIUS, speed, pos, nav_cost_map_cost_table, enable_crowd_dispersion)
	fassert(self._nav_bot == nil, "Tried to create navbot but already had one, freeze bug?")
	self._nav_bot = nav_bot
	self._max_speed = speed
	self._destination:store(pos)
	self._wanted_destination:store(pos)

	self._is_avoiding = breed.use_avoidance == true
	GwNavBot.set_use_avoidance(nav_bot, self._is_avoiding)
	if self._is_avoiding then
		local config = breed.avoidance_config or DEFAULT_AVOIDANCE_CONFIG
		GwNavBot.set_avoidance_behavior(nav_bot, config.enable_slowing, config.enable_forcing, config.enable_stop, config.stop_wait_time_s, config.forcing_time_s, config.forcing_wait_time_s)
		GwNavBot.set_avoidance_collider_collector_configuration(nav_bot, config.half_height, config.radius, config.forcing_wait_time_s)
		GwNavBot.set_avoidance_computer_configuration(nav_bot, config.angle_span, config.time_to_collision, config.sample_count)
	end

	if not breed.ignore_nav_propagation_box then
		GwNavBot.set_propagation_box(nav_bot, 30)
	end


	local traverse_logic = GwNavBot.traverse_logic_data(nav_bot)
	fassert(self._traverse_logic == nil, "Tried to create _traverse_logic but already had one, freeze bug?")
	self._traverse_logic = traverse_logic

	local allowed_layers = { }
	if breed.allowed_layers then
		table.merge(allowed_layers, breed.allowed_layers)
	end
	table.merge(allowed_layers, NAV_TAG_VOLUME_LAYER_COST_AI)

	self._navtag_layer_cost_table = GwNavTagLayerCostTable.create()
	AiUtils.initialize_cost_table(self._navtag_layer_cost_table, allowed_layers)
	GwNavBot.set_navtag_layer_cost_table(nav_bot, self._navtag_layer_cost_table)

	local locomotion_extension = self._blackboard.locomotion_extension
	local engine_extension_id = locomotion_extension._engine_extension_id
	if engine_extension_id then
		EngineOptimizedExtensions.ai_locomotion_set_traverse_logic(engine_extension_id, traverse_logic)
	end

	if breed.use_navigation_path_splines then
		local config = breed.navigation_path_spline_config

		local CHANNEL_RADIUS = config and config.navigation_channel_radius or 4
		local TURN_SAMPLING_ANGLE = config and config.turn_sampling_angle or 30
		local CHANNEL_SMOOTHING_ANGLE = config and config.channel_smoothing_anle or 30
		local MIN_DISTANCE_BETWEEN_GATES = config and config.min_distance_between_gates or 0.5
		local MAX_DISTANCE_BETWEEN_GATES = config and config.max_distance_between_gates or 10
		GwNavBot.set_channel_computer_configuration(nav_bot,
		CHANNEL_RADIUS,
		TURN_SAMPLING_ANGLE,
		CHANNEL_SMOOTHING_ANGLE,
		MIN_DISTANCE_BETWEEN_GATES,
		MAX_DISTANCE_BETWEEN_GATES)

		local SCRIPT_DRIVEN = false
		local MAX_DISTANCE_TO_SPLINE_POSITION = config and config.max_distance_to_spline_position or 5
		local SPLINE_LENGTH = config and config.spline_length or 100
		local SPLINE_DISTANCE_TO_BORDERS = config and config.spline_distance_to_borders or 1
		local SPLINE_RECOMPUTION_RATIO = config and config.spline_recomputation_ratio or 1
		local TARGET_ON_SPLINE_DISTANCE = 0
		GwNavBot.set_spline_trajectory_configuration(nav_bot,
		SCRIPT_DRIVEN,
		MAX_DISTANCE_TO_SPLINE_POSITION,
		SPLINE_LENGTH,
		SPLINE_DISTANCE_TO_BORDERS,
		SPLINE_RECOMPUTION_RATIO,
		TARGET_ON_SPLINE_DISTANCE)

		if not breed.deactivate_navigation_path_splines_on_spawn then
			GwNavBot.set_use_channel(nav_bot, true)
		end
	end
end

function AINavigationExtension:traverse_logic()
	return self._traverse_logic
end

function AINavigationExtension:nav_world()
	return self._nav_world
end

function AINavigationExtension:desired_velocity()
	return GwNavBot.output_velocity(self._nav_bot)
end

function AINavigationExtension:set_enabled(enabled)
	if self._nav_bot == nil then return
	end
	local old_status = self._enabled
	self._enabled = enabled
	if not enabled then
		self._is_navbot_following_path = false
	end


	if enabled and not old_status then
		local position = Unit.local_position(self._unit, 0)
		GwNavBot.update_position(self._nav_bot, position)
	end
end

function AINavigationExtension:set_avoidance_enabled(enabled)
	if self._nav_bot == nil then return end
	self._is_avoiding = enabled
	GwNavBot.set_use_avoidance(self._nav_bot, enabled)
end




















































function AINavigationExtension:add_movement_modifier(new_modifier)
	fassert(new_modifier, "[AINavigationExtension] Trying to set invalid modifier")

	local size = self._movement_modifier_table_size
	local current_amount = self._num_movement_modifiers
	if size <= current_amount then
		size = size * 2
		if BUILD == "dev" then
			fassert(false, "[AINavigationExtension] More than %i movement modifers at the same time", self._movement_modifier_table_size)
		else
			printf("[AINavigationExtension] Doubled size of movement modifiers for %s to %i", tostring(self._unit), size)
		end
		self._movement_modifier_table_size = size
	end


	local modifiers = self._movement_modifiers
	local id = self._last_movement_modifier_index
	while modifiers [id] do
		id = id % size + 1
	end

	modifiers [id] = new_modifier
	self._num_movement_modifiers = current_amount + 1
	self._last_movement_modifier_index = id

	self:_recalculate_max_speed()

	return id
end

function AINavigationExtension:remove_movement_modifier(id)
	local modifiers = self._movement_modifiers
	fassert(modifiers [id], "[AINavigationExtension] Trying to remove unexisting modifier with id %i", id)
	modifiers [id] = nil
	self._num_movement_modifiers = self._num_movement_modifiers - 1

	self:_recalculate_max_speed()
end

function AINavigationExtension:_recalculate_max_speed()
	if self._nav_bot == nil then return
	end
	local aggregate_mod = 1
	local modifiers = self._movement_modifiers
	for i = 1, self._movement_modifier_table_size do
		local mod = modifiers [i]
		if mod then
			aggregate_mod = mod * aggregate_mod
		end
	end

	self._movement_modifier = aggregate_mod
	GwNavBot.set_max_desired_linear_speed(self._nav_bot, aggregate_mod * self._max_speed)
end

function AINavigationExtension:set_max_speed(speed)
	if self._max_speed == speed then return end
	self._max_speed = speed
	self:_recalculate_max_speed()
end

function AINavigationExtension:get_movement_modifier()
	return self._movement_modifier
end

function AINavigationExtension:get_max_speed()
	return self._max_speed
end

function AINavigationExtension:set_navbot_position(position)
	if self._nav_bot == nil then return end
	GwNavBot.update_position(self._nav_bot, position)
end

function AINavigationExtension:move_to(pos)
	if self._nav_bot == nil then return end
	if self._blackboard.far_path then
		self._backup_destination:store(pos)
		return
	end
	self._wanted_destination:store(pos)
	self._failed_move_attempts = 0
end

function AINavigationExtension:stop()
	local unit = self._unit
	local position = POSITION_LOOKUP [unit]
	self._wanted_destination:store(position)
	self._destination:store(position)
	self._failed_move_attempts = 0
	self._has_started_pathfind = nil

	local blackboard = self._blackboard
	blackboard.far_path = nil
	blackboard.current_far_path_index = nil
	blackboard.num_far_path_nodes = nil

	local nav_bot = self._nav_bot
	if self._is_computing_path then
		GwNavBot.cancel_async_path_computation(nav_bot)
	end
	GwNavBot.clear_followed_path(nav_bot)
end

function AINavigationExtension:number_failed_move_attempts()
	return self._failed_move_attempts
end

function AINavigationExtension:is_following_path()
	return self._is_navbot_following_path
end

function AINavigationExtension:is_computing_path()
	return self._is_computing_path
end

function AINavigationExtension:reset_destination(override_destination)
	if self._nav_bot == nil then return
	end
	local unit = self._unit
	local position = override_destination or POSITION_LOOKUP [unit]
	self._wanted_destination:store(position)
	self._destination:store(position)
	self._failed_move_attempts = 0

	local blackboard = self._blackboard
	blackboard.far_path = nil
	blackboard.current_far_path_index = nil
	blackboard.num_far_path_nodes = nil

	GwNavBot.compute_new_path(self._nav_bot, position)
end

function AINavigationExtension:destination()
	local blackboard = self._blackboard

	if blackboard.far_path then
		return self._backup_destination:unbox()
	else
		return self._wanted_destination:unbox()
	end
end

function AINavigationExtension:distance_to_destination(position)
	position = position or Unit.local_position(self._unit, 0)
	local destination = self:destination()
	return Vector3.distance(position, destination)
end

function AINavigationExtension:distance_to_destination_sq(position)
	position = position or Unit.local_position(self._unit, 0)
	local destination = self:destination()
	return Vector3.distance_squared(position, destination)
end

local navigation_stop_distance_before_destination = 0.3
function AINavigationExtension:has_reached_destination(reach_distance)
	local reach_distance_sq = ( reach_distance or navigation_stop_distance_before_destination ) ^ 2
	local distance_sq = self:distance_to_destination_sq()
	return distance_sq < reach_distance_sq
end

function AINavigationExtension:next_smart_object_data()
	return self._next_smart_object_data
end

function AINavigationExtension:use_smart_object(do_use)
	if self._nav_bot == nil then return
	end
	local success = nil
	if do_use then
		fassert(self._blackboard.next_smart_object_data.next_smart_object_id ~= nil, "Tried to use smart object with a nil smart object id")
		success = GwNavBot.enter_manual_control(self._nav_bot, self._next_smartobject_interval)
		if not success then --[[ Nothing --]]


		end else
		success = GwNavBot.exit_manual_control(self._nav_bot)
		if not success then

			GwNavBot.clear_followed_path(self._nav_bot)
		end
	end

	local using_smart_object = do_use and success
	self._using_smartobject = using_smart_object

	return success
end

function AINavigationExtension:is_using_smart_object()
	return self._using_smartobject
end

function AINavigationExtension:allow_layer(layer_name, layer_allowed)
	if self._nav_bot == nil then return end
	local layer_id = LAYER_ID_MAPPING [layer_name]
	if layer_allowed then
		GwNavTagLayerCostTable.allow_layer(self._navtag_layer_cost_table, layer_id)
	else
		GwNavTagLayerCostTable.forbid_layer(self._navtag_layer_cost_table, layer_id)
	end
end

function AINavigationExtension:set_layer_cost(layer_name, layer_cost)
	if self._nav_bot == nil then return end
	local layer_id = LAYER_ID_MAPPING [layer_name]
	GwNavTagLayerCostTable.set_layer_cost_multiplier(self._navtag_layer_cost_table, layer_id, layer_cost)
end

function AINavigationExtension:get_navtag_layer_cost_table()
	return self._navtag_layer_cost_table
end

function AINavigationExtension:get_current_and_next_node_positions_in_nav_path()
	local nav_bot = self._nav_bot
	if nav_bot == nil then
		return nil, nil
	end

	local following_path = self._is_navbot_following_path
	if not following_path then
		return nil, nil
	end

	local node_count = GwNavBot.get_path_nodes_count(nav_bot)
	if node_count < 1 then
		return nil, nil
	end

	local current_node_index = GwNavBot.get_path_current_node_index(nav_bot)
	local current_node_position = GwNavBot.get_path_node_pos(nav_bot, current_node_index)
	local next_node_1_index = current_node_index + 1
	if next_node_1_index == node_count then
		return current_node_position, nil
	end

	local next_node_1_position = GwNavBot.get_path_node_pos(nav_bot, next_node_1_index)
	local next_node_2_index = current_node_index + 2
	if next_node_2_index == node_count then
		return current_node_position, next_node_1_position
	end

	local next_node_2_position = GwNavBot.get_path_node_pos(nav_bot, next_node_2_index)
	return current_node_position, next_node_1_position, next_node_2_position
end

function AINavigationExtension:get_current_and_node_position_in_nav_path(wanted_node_index)
	local nav_bot = self._nav_bot
	if nav_bot == nil then
		return nil, nil
	end

	local following_path = self._is_navbot_following_path
	if not following_path then
		return nil, nil
	end

	local node_count = GwNavBot.get_path_nodes_count(nav_bot)
	if node_count < 1 then
		return nil, nil
	end

	local current_node_index = GwNavBot.get_path_current_node_index(nav_bot)
	local current_node_position = GwNavBot.get_path_node_pos(nav_bot, current_node_index)
	local wanted_node_index = current_node_index + wanted_node_index
	if node_count <= wanted_node_index then


		wanted_node_index = node_count
		return nil, nil
	end

	local wanted_node_position = GwNavBot.get_path_node_pos(nav_bot, wanted_node_index)
	return current_node_position, wanted_node_position
end

function AINavigationExtension:get_path_node_count()
	local nav_bot = self._nav_bot
	if nav_bot == nil then
		return 0
	end
	local following_path = self._is_navbot_following_path
	if not following_path then
		return 0
	end
	local node_count = GwNavBot.get_path_nodes_count(nav_bot)
	return node_count
end

function AINavigationExtension:get_remaining_distance_from_progress_to_end_of_path()
	local nav_bot = self._nav_bot
	if nav_bot == nil then
		return
	end
	local following_path = self._is_navbot_following_path
	if not following_path then
		return
	end
	local distance = GwNavBot.get_remaining_distance_from_progress_to_end_of_path(nav_bot)
	return distance
end