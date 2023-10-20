require("scripts/helpers/interaction_helper")
require("scripts/unit_extensions/generic/interactions")

GenericUnitInteractorExtension = class(GenericUnitInteractorExtension)

INTERACT_RAY_DISTANCE = 2.5

local chest_interactables = { }

function GenericUnitInteractorExtension:init(extension_init_context, unit, extension_init_data)
	local world = extension_init_context.world
	local dice_keeper = extension_init_context.dice_keeper
	local statistics_db = extension_init_context.statistics_db
	self.world = world
	self.unit = unit

	self.state = "waiting_to_interact"
	self.interaction_context = {
		data = {
			world = world,
			dice_keeper = dice_keeper,
			statistics_db = statistics_db,
			interactor_data = { } } }





	local player = Managers.player:owner(unit)
	self.is_bot = player and player.bot_player

	local physics_world = World.get_data(world, "physics_world")
	self.physics_world = physics_world

	self.is_server = Managers.player.is_server
	self._interactions_enabled = true

	self.exclusive_interaction_unit = nil




	self.units_in_range = { }
	self.units_in_range_back_buffer = { }


	function self.interactable_unit_destroy_callback(destroyed_interactable_unit)
		local t = Managers.time:time("game")
		self:_stop_interaction(destroyed_interactable_unit, t)
	end
end

function GenericUnitInteractorExtension:extensions_ready()
	self.status_extension = ScriptUnit.extension(self.unit, "status_system")
	self.health_extension = ScriptUnit.extension(self.unit, "health_system")
	self.buff_extension = ScriptUnit.extension(self.unit, "buff_system")
end

function GenericUnitInteractorExtension:set_exclusive_interaction_unit(unit)
	fassert(self.is_bot, "Trying to set exclusive interaction unit as player.")
	self.exclusive_interaction_unit = unit
end

function GenericUnitInteractorExtension:destroy()

	if Managers.state.network:game() and Managers.state.unit_storage:go_id(self.unit) then
		self:abort_interaction()
	end




	local interactable_unit = self.interaction_context.interactable_unit
	if Unit.alive(interactable_unit) then
		Managers.state.unit_spawner:remove_destroy_listener(interactable_unit, "interactable_unit")
	end
end

local IGNORED_DAMAGE_TYPES = { buff_shared_medpack = true, buff_shared_medpack_temp_health = true, buff = true, arrow_poison_dot = true, volume_generic_dot = true, warpfire_ground = true, damage_over_time = true, life_tap = true, aoe_poison_dot = true, plague_ground = true, temporary_health_degen = true, health_degen = true, poison = true, vomit_ground = true, wounded_dot = true, heal = true, burninating = true, life_drain = true }




















function GenericUnitInteractorExtension:update(unit, input, dt, context, t)
	local world = self.world
	table.clear(chest_interactables)

	if self.state ~= "waiting_to_interact" and not Unit.alive(self.interaction_context.interactable_unit) then
		InteractionHelper.printf("[GenericUnitInteractorExtension] not Unit.alive(self.interaction_context.interactable_unit)")
		self:abort_interaction()
	end

	if self.state ~= "waiting_to_interact" and (self.status_extension:is_disabled() or self.status_extension:is_catapulted()) then
		self:abort_interaction()
	end

	if self.state ~= "waiting_to_interact" then
		local damage_datas, num_damages = self.health_extension:recent_damages()
		local interrupted = false

		for i = 1, num_damages / DamageDataIndex.STRIDE do
			local zero_index = i - 1
			local damage_amount = damage_datas [zero_index * DamageDataIndex.STRIDE + DamageDataIndex.DAMAGE_AMOUNT]
			local damage_type = damage_datas [zero_index * DamageDataIndex.STRIDE + DamageDataIndex.DAMAGE_TYPE]
			if damage_amount > 0 and not IGNORED_DAMAGE_TYPES [damage_type] then
				interrupted = true
			end
		end

		if interrupted then
			local abort = true
			local interaction_type = self.interaction_context.interaction_type
			local buff_extension = self.buff_extension

			if interaction_type == "heal" then
				abort = not buff_extension:has_buff_type("no_interruption_bandage")
			end

			if abort and interaction_type == "revive" then
				abort = not buff_extension:has_buff_perk("uninterruptible_revive")
			end

			if abort then
				self:abort_interaction()
			end
		end
	end

	if self.state == "waiting_to_interact" and not self.status_extension:is_disabled() then
		local interaction_context = self.interaction_context

		if interaction_context.interactable_unit then
			interaction_context.interactable_unit = nil
			interaction_context.interaction_type = nil
		end

		if self.is_bot then
			local exl_unit = self.exclusive_interaction_unit
			if exl_unit then
				local target_extension = ScriptUnit.has_extension(exl_unit, "interactable_system")
				if target_extension then
					interaction_context.interactable_unit = exl_unit
					interaction_context.interaction_type = target_extension:interaction_type()
					do return end
				end
			end
		else
			local res_w = RESOLUTION_LOOKUP.res_w local res_h = RESOLUTION_LOOKUP.res_h
			local center_x = res_w * 0.5 local center_y = res_h * 0.5

			self.ray_casted = true

			local first_person_extension = ScriptUnit.extension(unit, "first_person_system")
			local camera_position = first_person_extension:current_position()
			local camera_rotation = first_person_extension:current_rotation()
			local camera_forward = Quaternion.forward(camera_rotation)
			local hits, hits_n = self.physics_world:immediate_raycast(camera_position, camera_forward, INTERACT_RAY_DISTANCE, "all", "collision_filter", "filter_ray_interaction")
			local hit_non_interaction_unit = false
			local camera = self:_get_player_camera()
			local distance_score = math.huge
			local selected_interaction_unit, selected_interaction_type = nil

			local new_units_in_range = self.units_in_range_back_buffer


			for i = 1, hits_n do
				local hit = hits [i]
				local actor = hit [4]
				if actor then
					local hit_unit = Actor.unit(actor)

					if hit_unit and hit_unit ~= self.unit then
						if ScriptUnit.has_extension(hit_unit, "interactable_system") then
							local interact_actor = Unit.get_data(hit_unit, "interaction_data", "interact_actor")

							if not interact_actor or Unit.actor(hit_unit, interact_actor) == actor then
								local target_extension = ScriptUnit.extension(hit_unit, "interactable_system")
								if target_extension:is_enabled() then
									local target_interaction_type = target_extension:interaction_type()
									local can_interact, fail_reason, interaction_type = self:can_interact(hit_unit, target_interaction_type)
									local is_in_chest = self:_check_if_interactable_in_chest(hit_unit, camera_position)

									if ( can_interact or fail_reason ) and not is_in_chest then
										local interaction_template = InteractionDefinitions [interaction_type]
										local config = interaction_template.config or interaction_template.get_config()
										local does_not_require_line_of_sight = config.does_not_require_line_of_sight
										local score = self:_claculate_interaction_distance_score(hit_unit, camera_position, center_x, center_y, camera)
										local block_other_interactions = config.block_other_interactions

										if does_not_require_line_of_sight or not hit_non_interaction_unit then
											if block_other_interactions then
												interaction_context.interactable_unit = hit_unit
												interaction_context.interaction_type = interaction_type
												do return end
											elseif score < distance_score then
												selected_interaction_unit = hit_unit
												selected_interaction_type = interaction_type

												distance_score = score
											end
										end
										if can_interact then
											new_units_in_range [hit_unit] = target_interaction_type
											if self.units_in_range [hit_unit] == nil then
												self:in_range(hit_unit, target_interaction_type, true)
											end
										end
									end
								else
									hit_non_interaction_unit = true
								end
							else
								hit_non_interaction_unit = true
							end
						else
							hit_non_interaction_unit = true
						end
					end
				end
			end
			for old_hit_unit, target_interaction_type in pairs(self.units_in_range) do
				if new_units_in_range [old_hit_unit] == nil then
					self:in_range(old_hit_unit, target_interaction_type, false)
				end
			end


			self.units_in_range_back_buffer = self.units_in_range self.units_in_range = new_units_in_range
			table.clear(self.units_in_range_back_buffer)

			if selected_interaction_unit then
				interaction_context.interactable_unit = selected_interaction_unit
				interaction_context.interaction_type = selected_interaction_type
				return
			end

			local self_pos = POSITION_LOOKUP [self.unit]
			local hits, num_hits = PhysicsWorld.immediate_overlap(self.physics_world, "position", self_pos, "shape", "sphere", "size", 0.3, "collision_filter", "filter_overlap_interaction")

			local best_unit = nil
			local best_dist = math.huge

			for i = 1, num_hits do
				local actor = hits [i]

				if actor then
					local hit_unit = Actor.unit(actor)
					if hit_unit and hit_unit ~= self.unit then

						local is_in_chest = self:_check_if_interactable_in_chest(hit_unit, camera_position)
						local target_extension = ScriptUnit.has_extension(hit_unit, "interactable_system")

						if target_extension and not is_in_chest and target_extension:is_enabled() then
							local pos = POSITION_LOOKUP [hit_unit] or Unit.local_position(hit_unit, 0)
							local dist = Vector3.distance_squared(self_pos, pos)
							if dist < best_dist then
								best_dist = dist
								best_unit = hit_unit
							end
						end
					end
				end
			end







			if best_unit then
				local target_extension = ScriptUnit.has_extension(best_unit, "interactable_system")
				if target_extension then
					local target_interaction_type = target_extension:interaction_type()
					local can_interact, fail_reason, interaction_type = self:can_interact(best_unit, target_interaction_type)

					if can_interact then
						interaction_context.interactable_unit = best_unit
						interaction_context.interaction_type = interaction_type
					end
				end
			end
		end
	end

	local interaction_context = self.interaction_context
	local interactable_unit = interaction_context.interactable_unit
	local interaction_data = interaction_context.data
	interaction_data.is_server = self.is_server
	local interaction_type = interaction_context.interaction_type
	local interaction_template = InteractionDefinitions [interaction_type]
	local interaction_config = interaction_template and (interaction_template.config or interaction_template.get_config()) or nil

	if self.state == "starting_interaction" then
		interaction_template.client.start(world, unit, interactable_unit, interaction_data, interaction_config, t)
		if self.is_server then
			interaction_template.server.start(world, unit, interactable_unit, interaction_data, interaction_config, t)
		end
		self.state = "doing_interaction"
	end

	if self.state == "doing_interaction" then
		interaction_template.client.update(world, unit, interactable_unit, interaction_data, interaction_config, dt, t)
		if self.is_server then
			local interaction_result = interaction_template.server.update(world, unit, interactable_unit, interaction_data, interaction_config, dt, t)
			interaction_context.result = interaction_result
			if interaction_result ~= InteractionResult.ONGOING then
				InteractionHelper:complete_interaction(unit, interactable_unit, interaction_result)
				self:stop_interaction(t)
			end
		end
	end





















end

function GenericUnitInteractorExtension:_check_if_interactable_in_chest(interactable_unit, camera_position)

	if chest_interactables [interactable_unit] then
		return true
	end

	local has_pickup_extension = ScriptUnit.has_extension(interactable_unit, "pickup_system")

	if not has_pickup_extension then
		return false
	end

	local unit_center_matrix, _ = Unit.box(interactable_unit)
	local unit_pos = Matrix4x4.translation(unit_center_matrix)
	local distance = Vector3.length(unit_pos - camera_position)
	if distance > 0 then
		local dir = unit_pos - camera_position
		local found_collision, collisionPos, distance, normal, hit_actor = PhysicsWorld.immediate_raycast(
		self.physics_world,
		unit_pos,
		dir,
		distance,
		"closest",
		"types", "both",
		"collision_filter", "filter_interactable_in_chest")

		if found_collision then
			chest_interactables [interactable_unit] = true
			return true
		end
	end

	return false
end

function GenericUnitInteractorExtension:_claculate_interaction_distance_score(interactable_unit, camera_position, half_width, half_height, camera)
	local unit_pos = Unit.world_position(interactable_unit, 0)
	local ray_distance = INTERACT_RAY_DISTANCE
	local world_score = Vector3.distance_squared(unit_pos, camera_position) / (ray_distance * ray_distance)

	local unit_screen_pos = Camera.world_to_screen(camera, unit_pos)
	local middle_offset = Vector3(half_width - unit_screen_pos.x, half_height - unit_screen_pos.z, 0)
	local screen_score = Vector3.length(middle_offset) / (half_width * 2)

	return world_score * screen_score
end

function GenericUnitInteractorExtension:_get_player_camera()
	local player = Managers.player:owner(self.unit)
	local viewport_name = player.viewport_name
	local viewport = ScriptWorld.viewport(self.world, viewport_name)
	local camera = ScriptViewport.camera(viewport)

	return camera
end

function GenericUnitInteractorExtension:_stop_interaction(interactable_unit, t)
	local world = self.world
	local unit = self.unit
	local interaction_context = self.interaction_context
	local interaction_data = interaction_context.data
	interaction_data.is_server = self.is_server
	local interaction_type = interaction_context.interaction_type
	local interaction_template = InteractionDefinitions [interaction_type]
	local interaction_config = interaction_template and (interaction_template.config or interaction_template.get_config()) or nil

	local go_id, is_level_unit = Managers.state.network:game_object_or_level_id(interactable_unit)
	if not is_level_unit and go_id == nil then
		InteractionHelper.printf("[GenericUnitInteractorExtension] game object doesnt exist, changing result from %s to %s", InteractionResult [interaction_context.result], InteractionResult [InteractionResult.FAILURE])
		interaction_context.result = InteractionResult.FAILURE
	end

	local interaction_result = interaction_context.result


	if interaction_result == InteractionResult.ONGOING or interaction_result == nil then
		interaction_result = InteractionResult.FAILURE
		interaction_context.result = interaction_result
	end

	InteractionHelper.printf("[GenericUnitInteractorExtension] Stopping interaction %s with result %s", interaction_type, InteractionResult [interaction_result])
	interaction_template.client.stop(world, unit, interactable_unit, interaction_data, interaction_config, t, interaction_result)

	if self.is_server then
		interaction_template.server.stop(world, unit, interactable_unit, interaction_data, interaction_config, t, interaction_result)
	end

	self.state = "waiting_to_interact"
end

function GenericUnitInteractorExtension:stop_interaction(t)
	local interaction_context = self.interaction_context
	local interactable_unit = interaction_context.interactable_unit
	self:_stop_interaction(interactable_unit, t)

	Managers.state.unit_spawner:remove_destroy_listener(interactable_unit, "interactable_unit")
end

function GenericUnitInteractorExtension:is_interacting()
	local interaction_context = self.interaction_context
	local interaction_type = interaction_context.interaction_type
	return self.state ~= "waiting_to_interact", interaction_type
end

function GenericUnitInteractorExtension:is_stopping()
	return self.state == "stopping_interaction"
end

function GenericUnitInteractorExtension:is_waiting_for_interaction_approval()
	return self.state == "waiting_for_confirmation"
end

function GenericUnitInteractorExtension:is_aborting_interaction()
	return self.state == "waiting_for_abort"
end

function GenericUnitInteractorExtension:is_looking_at_interactable()
	return self.interaction_context.interactable_unit ~= nil
end

function GenericUnitInteractorExtension:in_range(interactable_unit, interaction_type, is_in_range)
	local interaction_context = self.interaction_context
	local unit_to_interact_with = interactable_unit or interaction_context.interactable_unit

	interaction_type = interaction_type or interaction_context.interaction_type

	local interaction_data = interaction_context.data
	local interaction_template = InteractionDefinitions [interaction_type]
	local in_range_func = interaction_template.client.in_range

	if in_range_func then
		in_range_func(self.unit, unit_to_interact_with, interaction_data, interaction_template.config, self.world, is_in_range)
	end
end

function GenericUnitInteractorExtension:enable_interactions(enable)
	self._interactions_enabled = enable
end

function GenericUnitInteractorExtension:can_interact(interactable_unit, interaction_type)

	local interaction_context = self.interaction_context
	local unit_to_interact_with = interactable_unit or interaction_context.interactable_unit
	local buff_extension = self.buff_extension
	local disable_interactions = buff_extension:has_buff_perk("disable_interactions")

	if disable_interactions then return false end
	if self.state ~= "waiting_to_interact" then return false end
	if unit_to_interact_with == nil then return false end
	if not Unit.alive(unit_to_interact_with) then return false end
	if self.status_extension:is_disabled() then return false end
	if not self._interactions_enabled then return false
	end
	interaction_type = interaction_type or interaction_context.interaction_type

	local game_mode = Managers.state.game_mode:game_mode()
	if game_mode.allowed_interactions and not game_mode:allowed_interactions(self.unit, interaction_type) then
		return false
	end

	local interaction_data = interaction_context.data
	local interaction_template = InteractionDefinitions [interaction_type]
	if not interaction_template then
		return false
	end
	local can_interact_func = interaction_template.client.can_interact

	if can_interact_func then
		local can_interact, failure_reason, interact_type = can_interact_func(self.unit, unit_to_interact_with, interaction_data, interaction_template.config, self.world)
		interact_type = interact_type or interaction_type

		return can_interact, failure_reason, interact_type
	end

	return true, nil, interaction_type
end

function GenericUnitInteractorExtension:interaction_config()
	local interaction_type = self.interaction_context.interaction_type
	local interaction_template = InteractionDefinitions [interaction_type]
	local interaction_config = interaction_template and (interaction_template.config or interaction_template.get_config()) or nil
	return interaction_config
end

function GenericUnitInteractorExtension:interaction_description(fail_reason)
	local interaction_context = self.interaction_context
	local interactable_unit = interaction_context.interactable_unit
	local interaction_data = interaction_context.data
	local interaction_type = interaction_context.interaction_type

	local interaction_template = InteractionDefinitions [interaction_type]
	local template_config = interaction_template.config

	return interaction_template.client.hud_description(interactable_unit, interaction_data, template_config, fail_reason, self.unit)
end

function GenericUnitInteractorExtension:interaction_hold_input()
	return self.interaction_context.hold_input
end

function GenericUnitInteractorExtension:interaction_camera_node()
	local interaction_type = self.interaction_context.interaction_type
	local interaction_template = InteractionDefinitions [interaction_type]
	return interaction_template.client.camera_node(self.unit, self.interaction_context.interactable_unit)
end

function GenericUnitInteractorExtension:interactable_unit()


	return self.interaction_context.interactable_unit
end

function GenericUnitInteractorExtension:get_progress(t)
	fassert(self:is_interacting(), "Attempted to get interaction progress when interactor unit wasn't interacting.")
	local interaction_context = self.interaction_context
	local interaction_data = interaction_context.data
	local interaction_type = interaction_context.interaction_type
	local interaction_template = InteractionDefinitions [interaction_type]
	local interaction_config = interaction_template and interaction_template.config or nil

	return interaction_template.client.get_progress(interaction_data, interaction_config, t)
end

function GenericUnitInteractorExtension:start_interaction(hold_input, interactable_unit, interaction_type, forced)
	InteractionHelper.printf("[GenericUnitInteractorExtension] start_interaction(interactable_unit=%s, interaction_type=%s)", tostring(interactable_unit), tostring(interaction_type))
	local interaction_context = self.interaction_context

	interaction_context.hold_input = hold_input
	interaction_context.interactable_unit = interactable_unit or interaction_context.interactable_unit
	interaction_context.interaction_type = interaction_type or interaction_context.interaction_type
	fassert(forced or self:can_interact(interaction_context.interactable_unit, interaction_type), "Attempted to start interaction even though the interaction wasn't allowed.")
	interaction_context.interaction_type = InteractionHelper.player_modify_interaction_type(self.unit, interaction_context.interactable_unit, interaction_context.interaction_type)

	local unit = self.unit
	local interaction_type = interaction_context.interaction_type
	local network_manager = Managers.state.network
	local interactor_go_id = Managers.state.unit_storage:go_id(unit)
	local interactable_go_id, is_level_unit = network_manager:game_object_or_level_id(interaction_context.interactable_unit)

	if interactor_go_id == nil or interactable_go_id == nil then

		InteractionHelper.printf("[GenericUnitInteractorExtension] start_interaction failed due to no id for interactor=%s or interactable=%s", tostring(self.unit), tostring(self.interaction_context.interactable_unit))
		fassert(LEVEL_EDITOR_TEST)
		return
	end

	local interaction_data = interaction_context.data
	local interactor_data = interaction_data.interactor_data
	local interaction_template = InteractionDefinitions [interaction_type]
	local client_functions = interaction_template.client

	table.clear(interactor_data)

	if client_functions.set_interactor_data then
		client_functions.set_interactor_data(unit, interactable_unit, interactor_data)
	end

	self.state = "waiting_for_confirmation"
	InteractionHelper:request(interaction_type, interactor_go_id, interactable_go_id, is_level_unit, self.is_server)
end

function GenericUnitInteractorExtension:abort_interaction()
	if self:is_interacting() and self.state ~= "waiting_for_abort" then



		self.state = "waiting_for_abort"
		InteractionHelper.printf("[GenericUnitInteractorExtension] abort_interaction in state=%s", self.state)
		InteractionHelper:abort(Managers.state.unit_storage:go_id(self.unit), self.is_server)
	end
end

function GenericUnitInteractorExtension:interaction_approved(interaction_type, interactable_unit)
	InteractionHelper.printf("[GenericUnitInteractorExtension] interaction_approved during state %s type=%s on %s", self.state, interaction_type, tostring(interactable_unit))

	fassert(interaction_type == self.interaction_context.interaction_type, "Got wrong type of interaction approved")
	fassert(interactable_unit == self.interaction_context.interactable_unit, "Got wrong interactable approved")

	Managers.state.unit_spawner:add_destroy_listener(interactable_unit, "interactable_unit", self.interactable_unit_destroy_callback)



	local interaction_data = self.interaction_context.data
	local interaction_template = InteractionDefinitions [interaction_type]
	local interaction_config = interaction_template.config
	interaction_data.duration = interaction_config.duration
	interaction_data.start_time = Managers.time:time("game")



	self.state = "starting_interaction"
end

function GenericUnitInteractorExtension:interaction_denied()
	InteractionHelper.printf("[GenericUnitInteractorExtension] interaction_denied")
	local state = self.state
	fassert(state == "waiting_for_confirmation" or state == "waiting_for_abort", "Was in wrong state when getting interaction denied.")
	self.state = "waiting_to_interact"
end

function GenericUnitInteractorExtension:interaction_completed(interaction_result)
	local state = self.state
	InteractionHelper.printf("[GenericUnitInteractorExtension] interaction_completed during state %s with result %s", state, InteractionResult [interaction_result])
	fassert(state ~= "waiting_to_interact", "Was in wrong state when getting interaction completed.")
	self.interaction_context.result = interaction_result

	local t = Managers.time:time("game")
	self:stop_interaction(t)
end

function GenericUnitInteractorExtension:hot_join_sync(sender)
	if not self:is_interacting() then
		return
	end

	local network_manager = Managers.state.network
	local context = self.interaction_context
	local state_id = NetworkLookup.interaction_states [self.state]
	local interaction_type_id = NetworkLookup.interactions [context.interaction_type]
	local interactable_unit_id, is_level_unit = network_manager:game_object_or_level_id(context.interactable_unit)
	local data = context.data
	local start_time = data.start_time
	local duration = data.duration or 0
	local unit_id = network_manager:unit_game_object_id(self.unit)
	local channel_id = PEER_ID_TO_CHANNEL [sender]

	RPC.rpc_sync_interaction_state(channel_id, unit_id, state_id, interaction_type_id, interactable_unit_id, start_time, duration, is_level_unit)
end

function GenericUnitInteractorExtension:allow_movement_during_interaction()
	local interactable_unit = self.interaction_context.interactable_unit
	local allow_movement = Unit.alive(interactable_unit) and (Unit.get_data(interactable_unit, "interaction_data", "allow_movement") or self:interaction_config().allow_movement)

	return allow_movement
end