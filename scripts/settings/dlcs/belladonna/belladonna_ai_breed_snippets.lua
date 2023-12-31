AiBreedSnippets = AiBreedSnippets or { }

function AiBreedSnippets.on_beastmen_bestigor_spawn(unit, blackboard)
	local t = Managers.time:time("game")

	blackboard.charge_astar_data = {
		astar_timer = t }
	blackboard.num_charges_targeting_target = 0
	blackboard.target_is_charged = false
	blackboard.aggro_list = { }
	local breed = blackboard.breed

	if breed.use_charge_nav_layers then
		local allowed_layers = { planks = 1, bot_ratling_gun_fire = 1, doors = 1, bot_poison_wind = 1, fire_grenade = 1 }








		local navtag_layer_cost_table = GwNavTagLayerCostTable.create()
		table.merge(allowed_layers, NAV_TAG_VOLUME_LAYER_COST_AI)
		AiUtils.initialize_cost_table(navtag_layer_cost_table, allowed_layers)

		local nav_cost_map_cost_table = GwNavCostMap.create_tag_cost_table()
		AiUtils.initialize_nav_cost_map_cost_table(nav_cost_map_cost_table)

		local charge_traverse_logic = GwNavTraverseLogic.create(blackboard.nav_world, nav_cost_map_cost_table)
		GwNavTraverseLogic.set_navtag_layer_cost_table(charge_traverse_logic, navtag_layer_cost_table)

		blackboard.charge_nav_cost_map_cost_table = nav_cost_map_cost_table
		blackboard.charge_traverse_logic = charge_traverse_logic
		blackboard.charge_navtag_layer_cost_table = navtag_layer_cost_table
	end
end

function AiBreedSnippets.on_beastmen_bestigor_update(unit, blackboard, t)


	local traverse_logic = blackboard.charge_traverse_logic or blackboard.navigation_extension:traverse_logic()


	if traverse_logic and blackboard.charge_astar_data and not blackboard.charge_state and Unit.alive(blackboard.target_unit) then
		local data = blackboard.charge_astar_data
		local astar = data.astar
		if astar then
			local done = GwNavAStar.processing_finished(astar)
			if done then
				local path_found = GwNavAStar.path_found(astar)
				if path_found then
					blackboard.has_valid_astar_path = true
				else
					blackboard.has_valid_astar_path = false
				end

				GwNavAStar.destroy(astar)
				data.astar = nil
				data.astar_timer = t + 1
			end
		elseif data.astar_timer < t then
			local nav_world = blackboard.nav_world
			local target_position = POSITION_LOOKUP [blackboard.target_unit]
			local success, z = GwNavQueries.triangle_from_position(nav_world, target_position, 1, 1)
			if success then
				local wanted_position = Vector3(target_position [1], target_position [2], z)
				local width = 7
				local new_astar = GwNavAStar.create(nav_world)
				GwNavAStar.start_with_propagation_box(new_astar, nav_world, POSITION_LOOKUP [unit], wanted_position, width, traverse_logic)
				data.astar = new_astar
				data.astar_timer = t + 1
			else
				data.astar_timer = t + 0.1
			end
		end
	end

	if Unit.alive(blackboard.target_unit) then
		local target_unit_status_extension = ScriptUnit.has_extension(blackboard.target_unit, "status_system")

		if target_unit_status_extension then
			local num_charges_targeting_player = target_unit_status_extension.num_charges_targeting_player or 0
			blackboard.num_charges_targeting_target = num_charges_targeting_player
			blackboard.target_is_charged = target_unit_status_extension:is_charged()
		end
	end
end

function AiBreedSnippets.on_beastmen_bestigor_death(unit, blackboard, t)
	local astar_data = blackboard.charge_astar_data
	if astar_data and astar_data.astar then
		local astar = astar_data.astar
		if not GwNavAStar.processing_finished(astar) then
			GwNavAStar.cancel(astar)
			GwNavAStar.destroy(astar)
		else
			GwNavAStar.destroy(astar)
		end
	end
	blackboard.charge_astar_data = nil

	if blackboard.charge_navtag_layer_cost_table then
		GwNavTagLayerCostTable.destroy(blackboard.charge_navtag_layer_cost_table)
		blackboard.charge_navtag_layer_cost_table = nil
	end

	if blackboard.charge_nav_cost_map_cost_table then
		GwNavCostMap.destroy_tag_cost_table(blackboard.charge_nav_cost_map_cost_table)
		blackboard.charge_nav_cost_map_cost_table = nil
	end

	if blackboard.charge_traverse_logic then
		GwNavTraverseLogic.destroy(blackboard.charge_traverse_logic)
		blackboard.charge_traverse_logic = nil
	end
end

function AiBreedSnippets.on_beastmen_standard_bearer_spawn(unit, blackboard)
	blackboard.switching_weapons = 1

	local buff_extension = ScriptUnit.extension(unit, "buff_system")
	blackboard.buff_extension = buff_extension

	if blackboard.spawn_category ~= "patrol" then
		WwiseUtils.trigger_unit_event(blackboard.world, "Play_enemy_beastmen_standar_chanting_loop", unit, 0)
		blackboard.triggered_standard_chanting_sound = true
	end

	if blackboard.spawn_type ~= "terror_event" and blackboard.spawn_category ~= "patrol" then
		local ai_slot_system = Managers.state.entity:system("ai_slot_system")
		ai_slot_system:do_slot_search(unit, true)

		local num_columns = 3
		local rot = Unit.local_rotation(unit, 0)
		local conflict_director = Managers.state.conflict
		local nav_world = conflict_director.nav_world
		local bearer_position = Unit.world_position(unit, 0)

		local standard_bearer_spawn_list = BreedTweaks.standard_bearer_spawn_list
		local spawn_list = Managers.state.difficulty:get_difficulty_value_from_table(standard_bearer_spawn_list)


		local level_transition_handler = Managers.level_transition_handler
		local enemy_package_loader = level_transition_handler.enemy_package_loader
		local startup_breeds = enemy_package_loader:get_startup_breeds()
		local replacement_breeds = BreedTweaks.standard_bearer_spawn_list_replacements
		local new_spawn_list = { }

		for i = 1, #spawn_list do
			local breed_name = spawn_list [i]

			if not startup_breeds [breed_name] then
				local replacement = nil
				local check_breeds = false

				for j = 1, #replacement_breeds do
					local replacement_breed = replacement_breeds [j]

					if check_breeds and startup_breeds [replacement_breed] then
						replacement = replacement_breed
						break
					elseif replacement_breed == breed_name then
						check_breeds = true
					end
				end

				if replacement then
					new_spawn_list [#new_spawn_list + 1] = replacement
				end
			else
				new_spawn_list [#new_spawn_list + 1] = breed_name
			end
		end

		local num_to_spawn = #new_spawn_list
		local above = 1 local below = 1
		for i = 1, num_to_spawn do
			local offset = Vector3(-num_columns / 2 + i % num_columns, -num_columns / 2 + math.floor(i / num_columns), 0)
			local spawn_pos = bearer_position + offset * 2
			local spawn_pos_on_navmesh = LocomotionUtils.pos_on_mesh(nav_world, spawn_pos, above, below)
			local breed = Breeds [new_spawn_list [i]]
			local optional_data = nil

			if spawn_pos_on_navmesh then









				conflict_director:spawn_queued_unit(breed, Vector3Box(spawn_pos_on_navmesh), QuaternionBox(rot), "hidden_spawn", nil, "horde_hidden", optional_data)
			else
				local horizontal = 1
				local distance_from_border = 0.1
				local clamped_position = GwNavQueries.inside_position_from_outside_position(nav_world, spawn_pos, above, below, horizontal, distance_from_border)

				clamped_position =

				clamped_position or POSITION_LOOKUP [unit]











				conflict_director:spawn_queued_unit(breed, Vector3Box(clamped_position), QuaternionBox(rot), "hidden_spawn", nil, "horde_hidden", optional_data)
			end
		end
	end

	if blackboard.spawn_type == "terror_event" then
		blackboard.ignore_passive_on_patrol = true
	end


	local t = Managers.time:time("game")
	blackboard.plant_standard_astar_data = {
		astar_timer = t }

	local allowed_layers = { planks = 1, bot_ratling_gun_fire = 1, doors = 1, bot_poison_wind = 1, fire_grenade = 1 }








	local navtag_layer_cost_table = GwNavTagLayerCostTable.create()
	table.merge(allowed_layers, NAV_TAG_VOLUME_LAYER_COST_AI)
	AiUtils.initialize_cost_table(navtag_layer_cost_table, allowed_layers)

	local nav_cost_map_cost_table = GwNavCostMap.create_tag_cost_table()
	AiUtils.initialize_nav_cost_map_cost_table(nav_cost_map_cost_table)

	local plant_standard_traverse_logic = GwNavTraverseLogic.create(blackboard.nav_world, nav_cost_map_cost_table)
	GwNavTraverseLogic.set_navtag_layer_cost_table(plant_standard_traverse_logic, navtag_layer_cost_table)

	blackboard.plant_standard_nav_cost_map_cost_table = nav_cost_map_cost_table
	blackboard.plant_standard_traverse_logic = plant_standard_traverse_logic
	blackboard.plant_standard_layer_cost_table = navtag_layer_cost_table
end

function AiBreedSnippets.on_beastmen_standard_bearer_husk_spawn(unit)
	local world = Managers.world:world("level_world")
	WwiseUtils.trigger_unit_event(world, "Play_enemy_beastmen_standar_chanting_loop", unit, 0)
end

function AiBreedSnippets.on_beastmen_standard_bearer_update(unit, blackboard, t)
	if HEALTH_ALIVE [blackboard.standard_unit] then
		local self_position = POSITION_LOOKUP [unit]
		local standard_position = Unit.local_position(blackboard.standard_unit, 0)
		local distance_to_standard = Vector3.distance(self_position, standard_position)
		blackboard.distance_to_standard = distance_to_standard

		if HEALTH_ALIVE [blackboard.target_unit] then
			local target_position = POSITION_LOOKUP [blackboard.target_unit]
			blackboard.target_distance_to_standard = Vector3.distance(target_position, standard_position)
		end
	else
		blackboard.distance_to_standard = nil
		blackboard.target_distance_to_standard = nil
	end


	if blackboard.climb_state then
		blackboard.has_valid_astar_path = false
	end


	if blackboard.plant_standard_astar_data and Unit.alive(blackboard.target_unit) then
		local data = blackboard.plant_standard_astar_data
		local astar = data.astar
		if astar then
			local done = GwNavAStar.processing_finished(astar)
			if done then
				local traverse_logic = blackboard.plant_standard_traverse_logic

				if traverse_logic then
					local path_found = GwNavAStar.path_found(astar)

					if path_found then
						blackboard.has_valid_astar_path = true
					else
						blackboard.has_valid_astar_path = false
					end

					GwNavAStar.destroy(astar)
					data.astar = nil
					data.astar_timer = t + 1
				end
			end
		elseif data.astar_timer < t then
			local nav_world = blackboard.nav_world
			local target_position = POSITION_LOOKUP [blackboard.target_unit]
			local success, z = GwNavQueries.triangle_from_position(nav_world, target_position, 1, 1)
			if success then

				local traverse_logic = blackboard.plant_standard_traverse_logic

				if traverse_logic then
					local wanted_position = Vector3(target_position [1], target_position [2], z)
					local new_astar = GwNavAStar.create(nav_world)
					GwNavAStar.start(new_astar, nav_world, POSITION_LOOKUP [unit], wanted_position, traverse_logic)
					data.astar = new_astar
				end
				data.astar_timer = t + 1
			else
				data.astar_timer = t + 0.1
			end
		end
	end
end

function AiBreedSnippets.on_beastmen_standard_bearer_death(unit, blackboard)
	if blackboard.triggered_standard_chanting_sound then
		local audio_system = Managers.state.entity:system("audio_system")
		audio_system:play_audio_unit_event("Stop_enemy_beastmen_standar_chanting_loop", unit)
	end

	local astar_data = blackboard.plant_standard_astar_data
	if astar_data and astar_data.astar then
		local astar = astar_data.astar
		if not GwNavAStar.processing_finished(astar) then
			GwNavAStar.cancel(astar)
			GwNavAStar.destroy(astar)
		else
			GwNavAStar.destroy(astar)
		end
	end
	blackboard.plant_standard_astar_data = nil

	if blackboard.plant_standard_layer_cost_table then
		GwNavTagLayerCostTable.destroy(blackboard.plant_standard_layer_cost_table)
		blackboard.plant_standard_layer_cost_table = nil
	end

	if blackboard.plant_standard_nav_cost_map_cost_table then
		GwNavCostMap.destroy_tag_cost_table(blackboard.plant_standard_nav_cost_map_cost_table)
		blackboard.plant_standard_nav_cost_map_cost_table = nil
	end

	if blackboard.plant_standard_traverse_logic then
		GwNavTraverseLogic.destroy(blackboard.plant_standard_traverse_logic)
		blackboard.plant_standard_traverse_logic = nil
	end
end

function AiBreedSnippets.on_beastmen_ungor_archer_spawn(unit, blackboard)
	blackboard.archer_broadphase_results = { }
	local physics_world = World.get_data(blackboard.world, "physics_world")
	blackboard.physics_world = physics_world


	local t = Managers.time:time("game")
	blackboard.pause_line_of_sight_t = t + Math.random_range(4, 8)
end

function AiBreedSnippets.on_beastmen_ungor_archer_death(unit, blackboard)
	if blackboard.is_volley_leader then
		local nearby_archers = blackboard.nearby_archers
		local num_nearby_archers = #nearby_archers
		for i = 1, num_nearby_archers do
			local nearby_unit_blackboard = nearby_archers [i]
			if nearby_unit_blackboard then
				nearby_unit_blackboard.volley_target_unit = nil
				nearby_unit_blackboard.has_volley_target = nil
				nearby_unit_blackboard.fire_volley_at_t = nil
			end
		end
		blackboard.is_volley_leader = nil
	end
end