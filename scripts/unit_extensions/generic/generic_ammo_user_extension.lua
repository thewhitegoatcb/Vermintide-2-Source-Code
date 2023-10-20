script_data.infinite_ammo = script_data.infinite_ammo or Development.parameter("infinite_ammo")

GenericAmmoUserExtension = class(GenericAmmoUserExtension)

function GenericAmmoUserExtension:init(extension_init_context, unit, extension_init_data)

	self.unit = unit
	self.owner_unit = extension_init_data.owner_unit
	self.item_name = extension_init_data.item_name

	self._is_server = Managers.player.is_server

	local ammo_percent = extension_init_data.ammo_percent or 1
	local ammo_data = extension_init_data.ammo_data

	self._reload_time = ammo_data.reload_time
	self._override_reload_time = nil
	self._override_reload_anim = nil
	self._single_clip = ammo_data.single_clip
	self._infinite_ammo = ammo_data.infinite_ammo or script_data.infinite_ammo

	if ammo_data.infinite_ammo then
		ammo_percent = 1
	end

	self._max_ammo = ammo_data.max_ammo
	self._start_ammo = math.round(ammo_percent * self._max_ammo)
	self._ammo_per_clip = ammo_data.ammo_per_clip or self._max_ammo
	self._ammo_per_reload = ammo_data.ammo_per_reload

	self._starting_loaded_ammo = ammo_data.starting_loaded_ammo
	self._current_ammo = ammo_data.starting_loaded_ammo or 0
	self._starting_reserve_ammo = ammo_data.starting_reserve_ammo

	self._original_max_ammo = self._max_ammo
	self._original_ammo_percent = ammo_percent
	self._original_ammo_per_clip = self._ammo_per_clip

	self._ammo_immediately_available = ammo_data.ammo_immediately_available or false
	self._reload_on_ammo_pickup = ammo_data.reload_on_ammo_pickup or false
	self._play_reload_anim_on_wield_reload = ammo_data.play_reload_anim_on_wield_reload
	self._has_wield_reload_anim = ammo_data.has_wield_reload_anim
	self._destroy_when_out_of_ammo = ammo_data.destroy_when_out_of_ammo
	self._unwield_when_out_of_ammo = ammo_data.unwield_when_out_of_ammo

	if ammo_data.force_wield_previous_weapon_when_ammo_given ~= nil then
		self._force_wield_previous_weapon_when_ammo_given = ammo_data.force_wield_previous_weapon_when_ammo_given
	else
		self._force_wield_previous_weapon_when_ammo_given = false
	end

	if ammo_data.wield_previous_weapon_when_destroyed ~= nil then
		self._wield_previous_weapon_when_destroyed = ammo_data.wield_previous_weapon_when_destroyed
	else
		self._wield_previous_weapon_when_destroyed = true
	end

	self._ammo_type = ammo_data.ammo_type or "default"
	self._ammo_kind = ammo_data.ammo_kind or "default"
	self._block_ammo_pickup = ammo_data.block_ammo_pickup or false

	self._play_reload_animation = true

	self._reload_event = extension_init_data.reload_event
	self.pickup_reload_event_1p = extension_init_data.pickup_reload_event_1p
	self._last_reload_event = extension_init_data.last_reload_event or self._reload_event
	self._no_ammo_reload_event = extension_init_data.no_ammo_reload_event
	self.slot_name = extension_init_data.slot_name

	local first_person_extension = ScriptUnit.has_extension(self.owner_unit, "first_person_system")
	if first_person_extension then
		self.first_person_extension = first_person_extension
		self.first_person_unit = first_person_extension:get_first_person_unit()
		if ammo_data.should_update_anim_ammo then
			self._should_update_anim_ammo = true
			assert(self.first_person_unit)
		end
	end
end

function GenericAmmoUserExtension:extensions_ready(world, unit)

	self:apply_buffs()
	self:_update_anim_ammo()
end

function GenericAmmoUserExtension:apply_buffs()

	if self.slot_name == "slot_ranged" or self.slot_name == "slot_career_skill_weapon" then
		self:_apply_buffs()
	end

	self:reset()
end

function GenericAmmoUserExtension:_apply_buffs()

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	self.owner_buff_extension = buff_extension
	self._ammo_per_clip = math.ceil(buff_extension:apply_buffs_to_value(self._original_ammo_per_clip, "clip_size"))

	self._max_ammo = math.ceil(buff_extension:apply_buffs_to_value(self._original_max_ammo, "total_ammo"))

	self._start_ammo = math.round(self._original_ammo_percent * self._max_ammo)
end

function GenericAmmoUserExtension:refresh_buffs()


	local ammo_percent = self:total_ammo_fraction()

	self:_apply_buffs()
	local max_available_ammo = self._start_ammo - self._current_ammo
	local available_ammo = self._available_ammo or math.huge
	self._available_ammo = math.min(max_available_ammo, available_ammo)

	if ammo_percent == 1 then
		self:reset()
	end
end

function GenericAmmoUserExtension:destroy()
	return end

function GenericAmmoUserExtension:reset()
	local no_ammo = self._initialized and self:total_remaining_ammo() == 0
	local start_ammo = self._starting_loaded_ammo or self._start_ammo
	if self._ammo_immediately_available then
		self._current_ammo = start_ammo
	else
		self._current_ammo = math.min(self._ammo_per_clip, start_ammo)
	end
	self._available_ammo = self._starting_reserve_ammo or self._start_ammo - self._current_ammo
	self._shots_fired = 0
	self:_update_anim_ammo()

	if no_ammo then
		local inventory_extension = ScriptUnit.has_extension(self.owner_unit, "inventory_system")
		if inventory_extension and self.slot_name == inventory_extension:get_wielded_slot_name() then
			self:instant_reload(true, self._no_ammo_reload_event)
		end
	end
	self._initialized = true
end

function GenericAmmoUserExtension:update(unit, input, dt, context, t)
	local player_manager = Managers.player
	local owner_player = player_manager:owner(self.owner_unit)

	if self._queued_reload then
		if self:can_reload() then
			self:start_reload(true)
		end
		self._queued_reload = false
	end

	if self._shots_fired > 0 then
		self._current_ammo = self._current_ammo - self._shots_fired
		self._shots_fired = 0
		fassert(self._current_ammo >= 0)
		if self._current_ammo == 0 then
			if not owner_player or not owner_player.bot_player then
				Unit.flow_event(unit, "used_last_ammo_clip")
			end
			if self._available_ammo == 0 then
				if self._destroy_when_out_of_ammo then
					local inventory_extension = ScriptUnit.extension(self.owner_unit, "inventory_system")
					local status_extension = ScriptUnit.has_extension(self.owner_unit, "status_system")
					inventory_extension:destroy_slot(self.slot_name, false, true)
					if self._last_ammo_used_was_given and self._force_wield_previous_weapon_when_ammo_given or
					self._wield_previous_weapon_when_destroyed then
						local grabbed_by_packmaster = status_extension and CharacterStateHelper.pack_master_status(status_extension)
						if not grabbed_by_packmaster then
							inventory_extension:wield_previous_weapon()
						end
					end
				elseif self._unwield_when_out_of_ammo then
					local inventory_extension = ScriptUnit.extension(self.owner_unit, "inventory_system")
					inventory_extension:wield_previous_weapon()
				else
					local player = Managers.player:unit_owner(self.owner_unit)
					local item_name = self.item_name
					local position = POSITION_LOOKUP [self.owner_unit]
					Managers.telemetry_events:player_ammo_depleted(player, item_name, position)
				end

				Unit.flow_event(unit, "used_last_ammo")
			end
		end
	end

	if self._next_reload_time and
	self._next_reload_time < t then

		if not self._start_reloading then
			local buff_extension = self.owner_buff_extension
			local missing_in_clip = self._ammo_per_clip - self._current_ammo
			local reload_amount = self._ammo_per_reload and self._ammo_per_reload <= missing_in_clip and self._ammo_per_reload or missing_in_clip

			reload_amount = math.min(reload_amount, self._available_ammo)
			self._current_ammo = self._current_ammo + reload_amount

			if buff_extension then
				local no_ammo_consumed = buff_extension:has_buff_type("no_ammo_consumed")
				local markus_huntsman_ability = buff_extension:has_buff_type("markus_huntsman_activated_ability") or buff_extension:has_buff_type("markus_huntsman_activated_ability_duration")
				local twitch_no_ammo_reloads = buff_extension:has_buff_type("twitch_no_overcharge_no_ammo_reloads")

				if not no_ammo_consumed and not markus_huntsman_ability and not twitch_no_ammo_reloads then
					self._available_ammo = self._available_ammo - reload_amount
				end

				buff_extension:trigger_procs("on_reload")
				self:_update_anim_ammo()
			end

			if not LEVEL_EDITOR_TEST and
			not self._is_server then
				local peer_id = owner_player:network_id()
				local local_player_id = owner_player:local_player_id()
				local event_id = NetworkLookup.proc_events.on_reload

				Managers.state.network.network_transmit:send_rpc_server("rpc_proc_event", peer_id, local_player_id, event_id)
			end
		end


		self._start_reloading = nil

		local num_missing = self._ammo_per_clip - self._current_ammo
		if num_missing > 0 and self._available_ammo > 0 then
			local reload_time = self._override_reload_time or self._reload_time
			self._override_reload_time = nil

			local unmodded_reload_time = reload_time

			if self.owner_buff_extension then
				reload_time = self.owner_buff_extension:apply_buffs_to_value(reload_time, "reload_speed")
			end

			self._next_reload_time = t + reload_time

			if self._play_reload_animation then
				Unit.set_flow_variable(self.unit, "wwise_reload_speed", unmodded_reload_time / reload_time)
				self:start_reload_animation(reload_time)

				if not owner_player.bot_player then
					Managers.state.controller_features:add_effect("rumble", { rumble_effect = "reload_start" })
				end
			end
		else
			self._next_reload_time = nil
			if not owner_player.bot_player then
				Managers.state.controller_features:add_effect("rumble", { rumble_effect = "reload_over" })
			end
		end
	end

end

function GenericAmmoUserExtension:start_reload_animation(reload_time)

	if self.pickup_reload_event_1p then
		local pickup_reload_event_1p = self.pickup_reload_event_1p
		if self.first_person_extension then
			local first_person_extension = self.first_person_extension

			first_person_extension:animation_event(pickup_reload_event_1p)
		end
	end

	local reload_event = self._reload_event
	local num_missing = self._ammo_per_clip - self._current_ammo
	if self.reloaded_from_zero_ammo then
		self.reloaded_from_zero_ammo = nil
		if self._no_ammo_reload_event then
			reload_event = self._no_ammo_reload_event
		end
	elseif num_missing == 1 or self._available_ammo == 1 then
		reload_event = self._last_reload_event
	end

	reload_event = self._override_reload_anim or reload_event
	self._override_reload_anim = nil

	if reload_event then
		if self.first_person_extension then
			local first_person_extension = self.first_person_extension

			first_person_extension:animation_set_variable("reload_time", reload_time)
			first_person_extension:animation_event(reload_event)
		end

		local go_id = Managers.state.unit_storage:go_id(self.owner_unit)
		local event_id = NetworkLookup.anims [reload_event]

		if not LEVEL_EDITOR_TEST then
			if self._is_server then
				Managers.state.network.network_transmit:send_rpc_clients("rpc_anim_event", event_id, go_id)
			else
				Managers.state.network.network_transmit:send_rpc_server("rpc_anim_event", event_id, go_id)
			end
		end
	end
end

function GenericAmmoUserExtension:remove_ammo(amount)

	if self._available_ammo == 0 and self._current_ammo == 0 then
		return
	end
	local floored_ammo = math.floor(math.clamp(self._available_ammo - amount, 0, self._max_ammo))
	self._available_ammo = floored_ammo
end

function GenericAmmoUserExtension:add_ammo(amount)

	if self._destroy_when_out_of_ammo then
		return
	end

	if self._available_ammo == 0 and self._current_ammo == 0 then
		self.reloaded_from_zero_ammo = true

		local player = Managers.player:unit_owner(self.owner_unit)
		local item_name = self.item_name
		local position = POSITION_LOOKUP [self.owner_unit]
		Managers.telemetry_events:player_ammo_refilled(player, item_name, position)

		local buff_extension = self.owner_buff_extension
		if buff_extension then
			buff_extension:trigger_procs("on_gained_ammo_from_no_ammo")

			if not LEVEL_EDITOR_TEST and
			not self._is_server then
				local player_manager = Managers.player
				local owner_player = player_manager:owner(self.owner_unit)
				local peer_id = owner_player:network_id()
				local local_player_id = owner_player:local_player_id()
				local event_id = NetworkLookup.proc_events.on_gained_ammo_from_no_ammo

				Managers.state.network.network_transmit:send_rpc_server("rpc_proc_event", peer_id, local_player_id, event_id)
			end
		end
	end


	local floored_ammo = nil
	if amount and self._ammo_immediately_available then
		floored_ammo = math.floor(math.clamp(self._current_ammo + amount, 0, self._max_ammo))
		self._current_ammo = floored_ammo
	elseif amount then
		floored_ammo = math.floor(math.clamp(self._available_ammo + amount, 0, self._max_ammo - (self._current_ammo - self._shots_fired)))
		self._available_ammo = floored_ammo
	elseif self._ammo_immediately_available then
		self._current_ammo = self._max_ammo
	else
		self._available_ammo = self._max_ammo - (self._current_ammo - self._shots_fired)
	end

	self:_update_anim_ammo()
end

function GenericAmmoUserExtension:add_ammo_to_reserve(amount)

	local prev_available_ammo = self._available_ammo
	if self._ammo_immediately_available then
		self._current_ammo = math.min(self._max_ammo, self._current_ammo + amount)
	else
		local ammo_count = self:ammo_count()
		self._available_ammo = math.min(self._max_ammo - ammo_count, self._available_ammo + amount)
	end

	local buff_extension = self.owner_buff_extension
	buff_extension:trigger_procs("on_gained_ammo_from_no_ammo")
	if not LEVEL_EDITOR_TEST and
	not self._is_server then
		local player_manager = Managers.player
		local owner_player = player_manager:owner(self.owner_unit)
		local peer_id = owner_player:network_id()
		local local_player_id = owner_player:local_player_id()
		local event_id = NetworkLookup.proc_events.on_gained_ammo_from_no_ammo

		Managers.state.network.network_transmit:send_rpc_server("rpc_proc_event", peer_id, local_player_id, event_id)
	end


	if prev_available_ammo == 0 and self._current_ammo == 0 and self:can_reload() then
		self._queued_reload = true
	end

	self:_update_anim_ammo()
end

function GenericAmmoUserExtension:use_ammo(ammo_used, given)
	local buff_extension = self.owner_buff_extension

	local infinite_ammo = false
	if buff_extension then
		infinite_ammo = buff_extension:has_buff_perk("infinite_ammo")
	end

	if ( infinite_ammo or self._infinite_ammo ) and self.slot_name == "slot_ranged" then
		ammo_used = 0
	end

	self._shots_fired = self._shots_fired + ammo_used

	if buff_extension then
		buff_extension:trigger_procs("on_ammo_used", self, ammo_used)
		Managers.state.achievement:trigger_event("ammo_used", self.owner_unit)
		if self:total_remaining_ammo() == 0 then
			buff_extension:trigger_procs("on_last_ammo_used")
		end

		if not LEVEL_EDITOR_TEST and
		not self._is_server then
			local player_manager = Managers.player
			local owner_player = player_manager:owner(self.owner_unit)
			local peer_id = owner_player:network_id()
			local local_player_id = owner_player:local_player_id()
			local event_id = NetworkLookup.proc_events.on_ammo_used

			Managers.state.network.network_transmit:send_rpc_server("rpc_proc_event", peer_id, local_player_id, event_id)
			if self:total_remaining_ammo() == 0 then
				event_id = NetworkLookup.proc_events.on_last_ammo_used
				Managers.state.network.network_transmit:send_rpc_server("rpc_proc_event", peer_id, local_player_id, event_id)
			end
		end
	end


	self:_update_anim_ammo()

	self._last_ammo_used_was_given = given

	fassert(self:ammo_count() >= 0, "ammo went below 0")
end

function GenericAmmoUserExtension:start_reload(play_reload_animation, override_reload_time, override_reload_anim)

	fassert(self:can_reload(), "Tried to start reloading without being able to reload")
	fassert(self._next_reload_time == nil, "next_reload_time is nil")

	self._override_reload_time = override_reload_time
	self._start_reloading = true
	self._next_reload_time = 0
	self._play_reload_animation = play_reload_animation
	self._override_reload_anim = override_reload_anim

	local dialogue_input = ScriptUnit.extension_input(self.owner_unit, "dialogue_system")
	local event_data = FrameTable.alloc_table()

	event_data.item_name = self.item_name or "UNKNOWN ITEM"

	local event_name = "reload_started"
	dialogue_input:trigger_dialogue_event(event_name, event_data)
end

function GenericAmmoUserExtension:abort_reload()

	fassert(self:is_reloading(), "Tried to abort reload while reloading")
	self._start_reloading = nil
	self._next_reload_time = nil
	Unit.flow_event(self.unit, "stop_reload_sound")

	if self.first_person_extension then
		local first_person_extension = self.first_person_extension
		first_person_extension:show_first_person_ammo(false)
	end
end

function GenericAmmoUserExtension:ammo_count()

	return self._current_ammo - self._shots_fired
end

function GenericAmmoUserExtension:clip_size()

	return self._ammo_per_clip
end

function GenericAmmoUserExtension:clip_full()

	return self:ammo_count() == self._ammo_per_clip
end

function GenericAmmoUserExtension:remaining_ammo()

	return self._available_ammo
end

function GenericAmmoUserExtension:ammo_available_immediately()

	return self._ammo_immediately_available
end

function GenericAmmoUserExtension:can_reload()

	if self:is_reloading() then
		return false
	end

	if self:clip_full() then
		return false
	end

	if self._infinite_ammo then
		return true
	end

	return self._available_ammo > 0
end

function GenericAmmoUserExtension:total_remaining_ammo()

	return self:remaining_ammo() + self:ammo_count()
end

function GenericAmmoUserExtension:total_ammo_fraction()

	return ( self:remaining_ammo() + self:ammo_count() ) / self:max_ammo()
end

function GenericAmmoUserExtension:max_ammo()

	return self._max_ammo
end

function GenericAmmoUserExtension:current_ammo()

	return self._current_ammo
end

function GenericAmmoUserExtension:is_reloading()

	return self._next_reload_time ~= nil
end

function GenericAmmoUserExtension:full_ammo()

	return self:remaining_ammo() + self:ammo_count() == self:max_ammo()
end

function GenericAmmoUserExtension:using_single_clip()

	return self._single_clip
end

function GenericAmmoUserExtension:reload_on_ammo_pickup()

	return self._reload_on_ammo_pickup
end

function GenericAmmoUserExtension:play_reload_anim_on_wield_reload()

	return self._play_reload_anim_on_wield_reload
end

function GenericAmmoUserExtension:has_wield_reload_anim()

	return self._has_wield_reload_anim
end

function GenericAmmoUserExtension:ammo_type()

	return self._ammo_type
end

function GenericAmmoUserExtension:infinite_ammo()

	return self._infinite_ammo
end

function GenericAmmoUserExtension:ammo_kind()

	return self._ammo_kind
end

function GenericAmmoUserExtension:ammo_blocked()

	return self._block_ammo_pickup
end

function GenericAmmoUserExtension:add_ammo_to_clip(ammo)
	self._current_ammo = self._current_ammo + ammo
	self:_update_anim_ammo()
end

function GenericAmmoUserExtension:instant_reload(bonus_ammo, reload_anim_event)

	if not bonus_ammo then
		local reload_amount = self._ammo_per_clip - self._current_ammo
		reload_amount = math.min(reload_amount, self._available_ammo)
		self._current_ammo = self._current_ammo + reload_amount
		self._available_ammo = self._available_ammo - reload_amount
		self._shots_fired = 0
	else
		self._current_ammo = self._ammo_per_clip
		self._shots_fired = 0
	end

	if reload_anim_event then
		if self.first_person_extension then
			local first_person_extension = self.first_person_extension

			first_person_extension:animation_set_variable("reload_time", math.huge)
			first_person_extension:animation_event(reload_anim_event)
		end

		if not LEVEL_EDITOR_TEST then
			local go_id = Managers.state.unit_storage:go_id(self.owner_unit)
			local event_id = NetworkLookup.anims [reload_anim_event]

			if self.is_server then
				Managers.state.network.network_transmit:send_rpc_clients("rpc_anim_event", event_id, go_id)
			else
				Managers.state.network.network_transmit:send_rpc_server("rpc_anim_event", event_id, go_id)
			end
		end
	end

	self:_update_anim_ammo()
end

function GenericAmmoUserExtension:_update_anim_ammo()
	if not self._should_update_anim_ammo then
		return
	end

	local value = self._current_ammo - self._shots_fired
	self.first_person_extension:animation_set_variable("ammo_count", value, true)
end