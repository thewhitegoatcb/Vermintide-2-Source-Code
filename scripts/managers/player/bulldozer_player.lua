BulldozerPlayer = class(BulldozerPlayer, Player)

EnergyData = EnergyData or { }

function BulldozerPlayer:init(network_manager, input_source, viewport_name, viewport_world_name, is_server, local_player_id, unique_id, ui_id, backend_id)
	BulldozerPlayer.super.init(self, network_manager, input_source, viewport_name, viewport_world_name, is_server, local_player_id)

	self.local_player = true
	self.game_object_id = nil
	self.camera_follow_unit = nil
	self.player_unit = nil
	local peer_id = Network.peer_id()
	self.peer_id = peer_id
	self._debug_name = "Local #" .. peer_id:sub(-3, -1)
	self._local_player_id = local_player_id
	self._unique_id = unique_id
	self._ui_id = ui_id
	self._backend_id = backend_id

	self.is_server = is_server

	Managers.music:register_active_player(local_player_id)
	Managers.free_flight:register_player(local_player_id)

	self._cached_name = nil
end

function BulldozerPlayer:profile_index()
	if self._profile_index then
		return self._profile_index
	end

	local profile_synchronizer = self.network_manager.profile_synchronizer
	local profile_index = profile_synchronizer:profile_by_peer(self.peer_id, self._local_player_id)

	return profile_index
end

function BulldozerPlayer:set_profile_index(index)
	self._profile_index = index
end

function BulldozerPlayer:set_player_unit(unit)
	self.player_unit = unit
end

function BulldozerPlayer:type()
	return "BulldozerPlayer"
end

function BulldozerPlayer:profile_display_name()
	local profile_index = self:profile_index()
	local profile = SPProfiles [profile_index]
	local display_name = profile and profile.display_name
	return display_name
end



function BulldozerPlayer:despawn()
	if self._spawn_state == "despawned" then
		return
	end

	self:_set_spawn_state("despawned")


	for mood, _ in pairs(MoodSettings) do
		MOOD_BLACKBOARD [mood] = false
	end


	Managers.state.camera:set_additional_fov_multiplier(1)


	local first_person_extension = ScriptUnit.has_extension(self.player_unit, "first_person_system")
	if first_person_extension then
		first_person_extension:play_hud_sound_event("Stop_ability_loop_turn_off")
	end


	local player_unit = self.player_unit
	if Unit.alive(player_unit) then
		Managers.state.unit_spawner:mark_for_deletion(player_unit)
		Managers.telemetry_events:player_despawned(self)
	elseif not Boot.is_controlled_exit then
		Application.warning("bulldozer_player unit was already despawned. Should not happen.")
	end
	Managers.state.event:trigger("delete_limited_owned_pickups", self.peer_id)
end

function BulldozerPlayer:career_index()
	if self._career_index then
		return self._career_index
	end

	local profile_synchronizer = self.network_manager.profile_synchronizer
	local profile_index, career_index = profile_synchronizer:profile_by_peer(self.peer_id, self._local_player_id)

	return career_index
end

function BulldozerPlayer:set_career_index(index)
	self._career_index = index
end

function BulldozerPlayer:career_name()
	local profile_index = self:profile_index()
	local profile = SPProfiles [profile_index]
	local display_name = profile and profile.display_name

	if display_name then
		local career_index = self:career_index()
		return profile.careers [career_index].name
	end
end


function BulldozerPlayer:set_spawn_position_rotation(position, rotation)
	self.spawn_position = Vector3Box(position)
	self.spawn_rotation = QuaternionBox(rotation)
end

function BulldozerPlayer:_spawn_unit_at_pos_rot(unit_name, extension_init_data, unit_template_name, pos, rot)
	local unit = nil
	local unit_spawner = Managers.state.unit_spawner
	if not LEVEL_EDITOR_TEST then
		unit = unit_spawner:spawn_network_unit(unit_name, unit_template_name, extension_init_data, pos, rot)
		if self.is_server then
			ScriptUnit.extension(unit, "health_system"):sync_health_state()
		end
	else
		unit = unit_spawner:spawn_local_unit_with_extensions(unit_name, unit_template_name, extension_init_data, pos, rot)
	end

	return unit
end

function BulldozerPlayer:spawn_unit(unit_name, extension_init_data, unit_template_name, optional_position, optional_rotation)
	if LEVEL_EDITOR_TEST then
		local pose = Application.get_data("camera")
		local pos = Matrix4x4.translation(pose)
		local rot = Matrix4x4.rotation(pose)
		return self:_spawn_unit_at_pos_rot(unit_name, extension_init_data, unit_template_name, pos, rot)
	else

		local camera_fwd_vector = Quaternion.forward(optional_rotation)
		local camera_flat_rot = Quaternion.look(Vector3.flat(camera_fwd_vector), Vector3.up())

		return self:_spawn_unit_at_pos_rot(unit_name, extension_init_data, unit_template_name, optional_position, camera_flat_rot)
	end
end

function BulldozerPlayer:spawn(optional_position, optional_rotation, is_initial_spawn, ammo_melee, ammo_ranged, healthkit, potion, grenade, ability_cooldown_percent_int, additional_items, initial_buff_names)
	local profile_index = self:profile_index()
	local profile = SPProfiles [profile_index]
	local careers = profile.careers
	local career_index = self:career_index()

	fassert(profile, "[SpawnManager] Trying to spawn with profile %q that doesn't exist in %q.", profile_index, "SPProfiles")

	local game_mode_manager = Managers.state.game_mode
	local player_wounds = game_mode_manager:get_player_wounds(profile)

	if self.spawn_position then
		optional_position = self.spawn_position:unbox()
		self.spawn_position = nil
	end

	if self.spawn_rotation then
		optional_rotation = self.spawn_rotation:unbox()
		self.spawn_rotation = nil
	end

	local aim_template = profile.aim_template or "player"

	local initial_inventory = game_mode_manager:get_initial_inventory(healthkit, potion, grenade, additional_items, profile)

	local hero_name = profile.display_name
	local career = profile.careers [career_index]

	local character_state_class_list = { }












	for _, character_state_name in ipairs(career.character_state_list) do
		character_state_class_list [#character_state_class_list + 1] = rawget(_G, character_state_name)
	end

	local base_skin = career.base_skin
	local base_frame = "default"
	local career_name = career.name
	local skin_item = BackendUtils.get_loadout_item(career_name, "slot_skin")
	skin_item =
	skin_item or BackendUtils.try_set_loadout_item(career_name, "slot_skin", base_skin)

	local skin_name = skin_item and skin_item.data.name or base_skin
	local skin_data = Cosmetics [skin_name]
	local frame_item = BackendUtils.get_loadout_item(career_name, "slot_frame")
	frame_item =
	frame_item or BackendUtils.try_set_loadout_item(career_name, "slot_frame", "frame_0000")

	local frame_name = frame_item and frame_item.data.name or base_frame
	local overcharge_data = OverchargeData [career_name] or { }
	local energy_data = EnergyData [career_name] or { }
	local faction = profile.dialogue_faction or "player"

	local status = Managers.party:get_status_from_unique_id(self._unique_id)
	local party = Managers.party:get_party(status.party_id)
	local side = Managers.state.side.side_by_party [party]

	local breed = career.breed or profile.breed

	local nav_world = Managers.state.entity:system("ai_system"):nav_world()
	local extension_init_data = {

		input_system = { player = self },
		character_state_machine_system = { start_state = "standing", character_state_class_list = character_state_class_list, player = self, nav_world = nav_world },
		health_system = { player = self, profile_index = profile_index, career_index = career_index },
		status_system = { wounds = player_wounds, profile_id = profile_index, player = self },
		hit_reaction_system = { is_husk = false, hit_reaction_template = "player" },
		death_system = { death_reaction_template = "player", is_husk = false },
		inventory_system = { profile = profile, initial_inventory = initial_inventory, player = self, ammo_percent = { slot_melee = ammo_melee, slot_ranged = ammo_ranged } },
		attachment_system = { profile = profile, player = self },
		cosmetic_system = { profile = profile, skin_name = skin_name, frame_name = frame_name, player = self },
		locomotion_system = { player = self },
		camera_system = { player = self },
		first_person_system = { profile = profile, skin_name = skin_name },
		dialogue_context_system = { profile = profile },
		dialogue_system = { local_player = true, wwise_career_switch_group = "player_career", wwise_voice_switch_group = "character", profile = profile, faction = faction, wwise_voice_switch_value = profile.character_vo, wwise_career_switch_value = career_name },
		whereabouts_system = { player = self },
		aim_system = { is_husk = false, template = aim_template },
		buff_system = { is_husk = false, initial_buff_names = initial_buff_names },
		statistics_system = { template = "player", statistics_id = self:telemetry_id() },
		ai_slot_system = { profile_index = profile_index },
		talent_system = { is_husk = false, player = self, profile_index = profile_index },
		career_system = { player = self, profile_index = profile_index, career_index = career_index, ability_cooldown_percent_int = ability_cooldown_percent_int },
		overcharge_system = { overcharge_data = overcharge_data },
		energy_system = { energy_data = energy_data },
		smart_targeting_system = { player = self, side = side },
		aggro_system = { side = side },
		proximity_system = { side = side, breed = breed },
		boon_system = { profile_index = profile_index },
		target_override_system = { side = side },
		ai_commander_system = { player = self } }



	local using_ghost_mode_system = Managers.mechanism:mechanism_setting("using_ghost_mode_system")
	if using_ghost_mode_system then
		extension_init_data.ghost_mode_system = { side_id = side.side_id }
	end


	local unit_name = skin_data.third_person

	local spawn_data = {
		unit_name = unit_name,
		extension_init_data = extension_init_data,
		unit_template_name = profile.unit_template_name }


	local spawn_manager = Managers.state.spawn
	local unit = self:spawn_unit(unit_name, extension_init_data, profile.unit_template_name, optional_position, optional_rotation)

	local player_manager = Managers.player
	local world = spawn_manager.world

	LevelHelper:set_flow_parameter(world, "local_player_profile_name", hero_name)



	Unit.set_data(unit, "sound_character", career.sound_character)


	if breed.starting_animation then
		local anim = breed.starting_animation
		local first_person_extension = ScriptUnit.extension(unit, "first_person_system")
		CharacterStateHelper.play_animation_event_first_person(first_person_extension, anim)
	end


	local career_voice_parameter = profile.career_voice_parameter
	if career_voice_parameter then
		local career_voice_parameter_value = profile.career_voice_parameter_values [career_index]
		if career_voice_parameter_value and GameSettingsDevelopment.use_career_voice_pitch then
			local wwise_world = Wwise.wwise_world(world)
			WwiseWorld.set_global_parameter(wwise_world, career_voice_parameter, career_voice_parameter_value)
		end
	end

	local is_player_unit = true
	player_manager:assign_unit_ownership(unit, self, is_player_unit)
	Managers.state.event:trigger("level_start_local_player_spawned", is_initial_spawn)
	Managers.telemetry_events:player_spawned(self)

	if not breed.is_hero then
		Unit.create_actor(unit, "enemy_collision", false)
	else
		Unit.create_actor(unit, "human_collision", false)
	end

	if self.is_server then
		local health_extension = ScriptUnit.extension(unit, "health_system")
		health_extension:create_health_game_object()
	end

	Managers.state.event:trigger("camera_teleported")

	self:_set_spawn_state("spawned")








	return unit
end

function BulldozerPlayer:create_game_object()
	local game_object_data_table = { ping = 0, player_controlled = true,
		go_type = NetworkLookup.go_types.player,
		network_id = self:network_id(),
		local_player_id = self:local_player_id(),


		clan_tag = Application.user_setting("clan_tag") or "0",
		account_id = Managers.account:account_id() or "0" }


	local callback = callback(self, "cb_game_session_disconnect")
	local game_object_id = self.network_manager:create_player_game_object("player", game_object_data_table, callback)
	self.game_object_id = game_object_id

	self:create_sync_data()
end

function BulldozerPlayer:create_sync_data()
	fassert(self._player_sync_data == nil)
	self._player_sync_data = PlayerSyncData:new(self, self.network_manager)
end

function BulldozerPlayer:cb_game_session_disconnect()
	self.game_object_id = nil
	self._player_sync_data = nil
end

function BulldozerPlayer:game_object_destroyed()
	printf("destroyed player game object with id %s callback", self.game_object_id)
	self.game_object_id = nil
end

function BulldozerPlayer:network_id()
	return self.peer_id
end

function BulldozerPlayer:local_player_id()
	return self._local_player_id
end

function BulldozerPlayer:platform_id()
	if IS_WINDOWS or IS_LINUX then
		do return self.peer_id end
	else
		return Managers.account:account_id()
	end
end

function BulldozerPlayer:profile_id()
	return self._unique_id
end

function BulldozerPlayer:ui_id()
	return self._ui_id
end

function BulldozerPlayer:unique_id()
	return self._unique_id
end

function BulldozerPlayer:stats_id()
	return self._unique_id
end

function BulldozerPlayer:telemetry_id()
	return self._backend_id or self._unique_id
end

function BulldozerPlayer:is_player_controlled()
	return true
end

function BulldozerPlayer:set_game_object_id(id)
	self.game_object_id = id
end

function BulldozerPlayer:sync_data_active()
	return self._player_sync_data and self._player_sync_data:active()
end

function BulldozerPlayer:set_data(key, value)
	self._player_sync_data:set_data(key, value)
end

function BulldozerPlayer:get_data(key)
	return self._player_sync_data:get_data(key)
end

function BulldozerPlayer:reevaluate_highest_difficulty()
	self._player_sync_data:reevaluate_highest_difficulty()
end

function BulldozerPlayer:name()

	if rawget(_G, "Steam") then
		if self._cached_name then
			do return self._cached_name end
		else
			local clan_tag = ""
			local clan_tag_id = Application.user_setting("clan_tag")
			if clan_tag_id and clan_tag_id ~= "0" then
				local clan_tag_string = tostring(Clans.clan_tag(clan_tag_id))
				if clan_tag_string ~= "" then
					clan_tag = clan_tag_string .. "|"
				end
			end
			local name = clan_tag .. Steam.user_name(self:network_id())

			self._cached_name = name
			do return name end
		end
	elseif IS_CONSOLE then
		if self._cached_name then
			return self._cached_name
		end

		local name = Managers.state.network:lobby():user_name(self:network_id()) or "Remote #" .. tostring(self.peer_id:sub(-3, -1))
		self._cached_name = name

		do return name end
	else
		return self._debug_name
	end
end

function BulldozerPlayer:cached_name()
	return self._cached_name or self._debug_name
end

function BulldozerPlayer:destroy()
	if self._player_sync_data then
		self._player_sync_data:destroy()
	end

	if self.is_server then
		if self.game_object_id then
			self.network_manager:destroy_game_object(self.game_object_id)
		end
		Managers.state.event:trigger("delete_limited_owned_pickups", self.peer_id)
	end

	Managers.free_flight:unregister_player(self:local_player_id())
	Managers.music:unregister_active_player(self._local_player_id)

	self._destroyed = true
end

function BulldozerPlayer:best_aquired_power_level()
	local sum = Managers.backend:get_interface("items"):sum_best_power_levels()
	local level = ExperienceSettings.get_highest_character_level()
	local character_power_level = PowerLevelFromLevelSettings.starting_power_level + PowerLevelFromLevelSettings.power_level_per_level * level

	local best_aquired_power_level = character_power_level + sum / 5

	return best_aquired_power_level
end

function BulldozerPlayer:get_party()
	local status = Managers.party:get_status_from_unique_id(self._unique_id)
	return Managers.party:get_party(status.party_id)
end

function BulldozerPlayer:observed_player_id()
	return self._observed_player_id
end

function BulldozerPlayer:set_observed_player_id(player_id)
	self._observed_player_id = player_id
end