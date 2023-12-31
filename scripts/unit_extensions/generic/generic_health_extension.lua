local data_fields = { "DAMAGE_AMOUNT", "DAMAGE_TYPE", "ATTACKER", "HIT_ZONE", "POSITION", "DIRECTION", "DAMAGE_SOURCE_NAME", "HIT_RAGDOLL_ACTOR_NAME", "SOURCE_ATTACKER_UNIT", "HIT_REACT_TYPE", "CRITICAL_HIT", "FIRST_HIT", "TOTAL_HITS", "ATTACK_TYPE", "BACKSTAB_MULTIPLIER" }

















DamageDataIndex = { }
local DamageDataIndex = DamageDataIndex
for index, field_name in ipairs(data_fields) do
	DamageDataIndex [field_name] = index
end
DamageDataIndex.STRIDE = #data_fields
data_fields = nil

GenericHealthExtension = class(GenericHealthExtension)

function GenericHealthExtension:init(extension_init_context, unit, extension_init_data)
	self.unit = unit
	self.is_server = Managers.player.is_server
	self.system_data = extension_init_context.system_data
	self.statistics_db = extension_init_context.statistics_db
	self.damage_buffers = { pdArray.new(), pdArray.new() }
	self.network_transmit = extension_init_context.network_transmit

	local health = extension_init_data.health or Unit.get_data(unit, "health")
	if health == -1 then
		self.is_invincible = true
		health = math.huge
	else





		self.is_invincible = false
	end

	self.dead = false
	self.predicted_dead = false
	self.state = "alive"
	self.damage = extension_init_data.damage or 0
	self.predicted_damage = 0
	self.last_damage_data = { }

	self:set_max_health(health)
	self.unmodified_max_health = self.health

	self._min_health_percentage = nil
	self._recent_damage_type = nil
	self._recent_hit_react_type = nil
	self._recent_attackers = { }
	self._last_damage_t = nil
	self._damage_cap = extension_init_data.damage_cap_per_hit or Unit.get_data(unit, "damage_cap_per_hit")
	self._damage_cap_per_hit = self._damage_cap or self.health
end

function GenericHealthExtension:destroy()
	return end

function GenericHealthExtension:freeze()
	self:set_dead()
end

function GenericHealthExtension:unfreeze()
	self:reset()
end

function GenericHealthExtension:reset()
	self.state = "alive"
	self.dead = false
	self.predicted_dead = false
	self.damage = 0
	self.predicted_damage = 0
	self._recent_damage_type = nil
	self._recent_hit_react_type = nil
	pdArray.set_empty(self.damage_buffers [1])
	pdArray.set_empty(self.damage_buffers [2])
	self:set_max_health(self.unmodified_max_health)
	table.clear(self.last_damage_data)
	HEALTH_ALIVE [self.unit] = true
end

function GenericHealthExtension:hot_join_sync(peer_id)
	local unit = self.unit
	local network_manager = Managers.state.network
	local go_id, is_level_unit = network_manager:game_object_or_level_id(unit)
	if go_id then
		local state_id = NetworkLookup.health_statuses [self.state]
		local damage_taken = self:get_damage_taken()
		local damage = NetworkUtils.get_network_safe_damage_hotjoin_sync(damage_taken)
		local network_transmit = self.network_transmit
		network_transmit:send_rpc("rpc_sync_damage_taken", peer_id, go_id, is_level_unit, false, damage, state_id)


		if self.dead then
			local damage_amount = 0
			local hit_zone_id = NetworkLookup.hit_zones.full
			local damage_type_id = NetworkLookup.damage_types.sync_health
			local hit_position = Unit.world_position(unit, 0)
			local damage_direction = Vector3.up()
			local source_attacker_unit_id = NetworkConstants.invalid_game_object_id
			local damage_source_id = NetworkLookup.damage_sources ["n/a"]
			local hit_ragdoll_actor_id = NetworkLookup.hit_ragdoll_actors ["n/a"]
			local hit_react_type_id = NetworkLookup.hit_react_types.light
			local attack_type_id = NetworkLookup.buff_attack_types ["n/a"]
			local is_dead = true
			local is_critical_strike = false
			local added_dot = false
			local first_hit = false
			local total_hits = 0
			local backstab_multiplier = 1
			network_transmit:send_rpc("rpc_add_damage", peer_id, go_id, is_level_unit, go_id, is_level_unit, source_attacker_unit_id, damage_amount, hit_zone_id, damage_type_id, hit_position, damage_direction, damage_source_id, hit_ragdoll_actor_id, hit_react_type_id, is_dead, is_critical_strike, added_dot, first_hit, total_hits, attack_type_id, backstab_multiplier)
		end
	end
end

function GenericHealthExtension:set_server_damage_taken(damage_taken)
	fassert(self.is_server, "[GenericHealthExtension] Only server is allowed to call this function")
	local unit = self.unit
	local network_manager = Managers.state.network
	local go_id, is_level_unit = network_manager:game_object_or_level_id(unit)
	if go_id then
		local state_id = NetworkLookup.health_statuses [self.state]
		local network_transmit = self.network_transmit
		network_transmit:send_rpc_clients("rpc_sync_damage_taken", go_id, is_level_unit, false, damage_taken, state_id)
	end

	self.damage = damage_taken
end

function GenericHealthExtension:is_alive()
	return not self.dead
end


function GenericHealthExtension:client_predicted_is_alive()
	return not self.dead and not self.predicted_dead
end

function GenericHealthExtension:current_health_percent()
	return 1 - self.damage / self.health
end

function GenericHealthExtension:current_health()
	return self.health - self.damage
end

function GenericHealthExtension:get_damage_taken()
	return self.damage
end

function GenericHealthExtension:set_current_damage(damage)
	self.damage = damage
end

function GenericHealthExtension:set_min_health_percentage(min_health_percentage)
	self._min_health_percentage = min_health_percentage
end

function GenericHealthExtension:get_max_health()
	return self.health
end

function GenericHealthExtension:is_dead()
	return self.dead
end

function GenericHealthExtension:current_max_health_percent()
	return 1
end

function GenericHealthExtension:set_max_health(health)

	local health_constant = NetworkConstants.health
	local network_health = math.clamp(health, health_constant.min, health_constant.max)
	local decimal = network_health % 1
	local rounded_decimal = math.round(decimal * 4) * 0.25
	network_health = math.floor(network_health) + rounded_decimal






	if network_health <= 0 then network_health = 1
	end
	self.health = network_health
	self._damage_cap_per_hit = self._damage_cap or self.health


	local network_manager = Managers.state.network
	local go_id, is_level_unit = network_manager:game_object_or_level_id(self.unit)
	if self.is_server and go_id then
		local state = NetworkLookup.health_statuses [self.state]
		self.network_transmit:send_rpc_clients("rpc_sync_damage_taken", go_id, is_level_unit, true, network_health, state)
	end
end

function GenericHealthExtension:_add_to_damage_history_buffer(unit, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, source_attacker_unit, hit_react_type, is_critical_strike, first_hit, total_hits, attack_type, backstab_multiplier)

	local hit_position_table = hit_position and { hit_position.x, hit_position.y, hit_position.z } or nil
	local damage_direction_table = damage_direction and { damage_direction.x, damage_direction.y, damage_direction.z } or nil
	local damage_buffers = self.damage_buffers
	local system_data = self.system_data
	local active_damage_buffer_index = system_data.active_damage_buffer_index
	local damage_queue = damage_buffers [active_damage_buffer_index]


	local temp_table = FrameTable.alloc_table()



	temp_table [DamageDataIndex.DAMAGE_AMOUNT] = damage_amount
	temp_table [DamageDataIndex.DAMAGE_TYPE] = damage_type
	temp_table [DamageDataIndex.ATTACKER] = attacker_unit
	temp_table [DamageDataIndex.HIT_ZONE] = hit_zone_name
	temp_table [DamageDataIndex.POSITION] = hit_position_table
	temp_table [DamageDataIndex.DIRECTION] = damage_direction_table
	temp_table [DamageDataIndex.DAMAGE_SOURCE_NAME] = damage_source_name or "n/a"
	temp_table [DamageDataIndex.HIT_RAGDOLL_ACTOR_NAME] = hit_ragdoll_actor or "n/a"
	temp_table [DamageDataIndex.SOURCE_ATTACKER_UNIT] = source_attacker_unit
	temp_table [DamageDataIndex.HIT_REACT_TYPE] = hit_react_type or "light"
	temp_table [DamageDataIndex.CRITICAL_HIT] = is_critical_strike or false
	temp_table [DamageDataIndex.FIRST_HIT] = first_hit or false
	temp_table [DamageDataIndex.TOTAL_HITS] = total_hits or 0
	temp_table [DamageDataIndex.ATTACK_TYPE] = attack_type or "n/a"
	temp_table [DamageDataIndex.BACKSTAB_MULTIPLIER] = backstab_multiplier or false



	pdArray.push_back15(damage_queue, unpack(temp_table))













	return temp_table
end


function GenericHealthExtension:_should_die()
	return self.health <= self.damage
end

function GenericHealthExtension:apply_client_predicted_damage(predicted_damage)
	fassert(not self.is_server, "This should only be used for the clients!")
	if not self:get_is_invincible() then
		local damage_mod = math.min(predicted_damage, self._damage_cap_per_hit)
		self.predicted_damage = self.predicted_damage + damage_mod
		self.predicted_dead = self.health <= self.damage + self.predicted_damage
	else
		self.predicted_dead = false
	end
end

function GenericHealthExtension:add_damage(attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, source_attacker_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type, backstab_multiplier)


	local unit = self.unit
	local network_manager = Managers.state.network
	local unit_id, is_level_unit = network_manager:game_object_or_level_id(unit)

	if self._min_health_percentage then
		local health = self:current_health()
		local min_health = math.max(self._min_health_percentage * self.health, 0.25)
		local predicted_health = health - damage_amount
		local clamped_health = math.max(predicted_health, min_health)
		local raw_damage = math.max(health - clamped_health, 0)
		damage_amount = DamageUtils.networkify_damage(raw_damage)
	end


	if not source_attacker_unit then
		local last_attacker_id = self.last_damage_data.attacker_unit_id
		source_attacker_unit = last_attacker_id and Managers.state.unit_storage:unit(last_attacker_id)
	end

	local damage_table = self:_add_to_damage_history_buffer(unit, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, source_attacker_unit, hit_react_type, is_critical_strike, first_hit, total_hits, attack_type, backstab_multiplier)
	fassert(damage_type, "No damage_type!")
	self._recent_damage_type = damage_type
	self._recent_hit_react_type = hit_react_type
	self._recent_damage_source_name = damage_source_name
	local damage_t = Managers.time:time("game")
	self._last_damage_t = damage_t

	if damage_amount > 0 then
		self:_register_attacker(attacker_unit, source_attacker_unit, damage_t)
	end

	StatisticsUtil.register_damage(unit, damage_table, self.statistics_db)

	self:save_kill_feed_data(attacker_unit, damage_table, hit_zone_name, damage_type, damage_source_name, source_attacker_unit)


	DamageUtils.handle_hit_indication(attacker_unit, unit, damage_amount, hit_zone_name, added_dot)

	local min_health = 0
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	if buff_extension then
		if buff_extension:has_buff_perk("ignore_death") then min_health = 1 else min_health = 0
		end
	end

	if not self:get_is_invincible() and not self.dead then
		local damage_mod = math.min(damage_amount, self._damage_cap_per_hit)







		if min_health > 0 then
			local current_health = self:current_health()
			if current_health <= damage_mod then damage_mod = current_health - min_health
			end
		end
		self.damage = self.damage + damage_mod
		self.predicted_damage = math.max(self.predicted_damage - damage_mod, 0)
		if self:_should_die() and (self.is_server or not unit_id) then

			local breed = Unit.get_data(unit, "breed")
			if breed and breed.name == "skaven_poison_wind_globadier" then
				printf("[HON-43348] Globadier (%s) died. damage_table:\n\t%s", Unit.get_data(unit, "globadier_43348"), table.tostring(damage_table))
			end

			local death_system = Managers.state.entity:system("death_system")
			death_system:kill_unit(unit, damage_table)
		end
	end

	local attacker_buff_extension = ScriptUnit.has_extension(source_attacker_unit, "buff_system")
	if attacker_buff_extension and damage_source_name == "dot_debuff" then
		attacker_buff_extension:trigger_procs("on_dot_damage_dealt", unit, source_attacker_unit, damage_type, damage_source_name)
	end

	if buff_extension and damage_amount > 0 and damage_source_name ~= "temporary_health_degen" then
		buff_extension:trigger_procs("on_damage_taken", attacker_unit, damage_amount, damage_type, attack_type)
	end

	self:_sync_out_damage(attacker_unit, unit_id, is_level_unit, source_attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type, backstab_multiplier)

























end

function GenericHealthExtension:_sync_out_damage(attacker_unit, unit_id, is_level_unit, source_attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type, backstab_multiplier)


	if self.is_server and unit_id then

		local network_manager = Managers.state.network
		local attacker_unit_id, attacker_is_level_unit = network_manager:game_object_or_level_id(attacker_unit)
		local source_attacker_unit_id = network_manager:unit_game_object_id(source_attacker_unit) or NetworkConstants.invalid_game_object_id
		local hit_zone_id = NetworkLookup.hit_zones [hit_zone_name]
		local damage_type_id = NetworkLookup.damage_types [damage_type]
		local damage_source_id = NetworkLookup.damage_sources [damage_source_name or "n/a"]
		local hit_ragdoll_actor_id = NetworkLookup.hit_ragdoll_actors [hit_ragdoll_actor or "n/a"]
		local hit_react_type_id = NetworkLookup.hit_react_types [hit_react_type or "light"]
		local attack_type_id = NetworkLookup.buff_attack_types [attack_type or "n/a"]
		local network_transmit = self.network_transmit
		local is_dead = self.dead or false
		is_critical_strike = is_critical_strike or false
		added_dot = added_dot or false
		first_hit = first_hit or false
		total_hits = total_hits or 0
		backstab_multiplier = backstab_multiplier or 1
		network_transmit:send_rpc_clients("rpc_add_damage", unit_id, is_level_unit, attacker_unit_id, attacker_is_level_unit, source_attacker_unit_id, damage_amount, hit_zone_id, damage_type_id, hit_position, damage_direction, damage_source_id, hit_ragdoll_actor_id, hit_react_type_id, is_dead, is_critical_strike, added_dot, first_hit, total_hits, attack_type_id, backstab_multiplier)
	end


end

function GenericHealthExtension:add_heal(healer_unit, heal_amount, heal_source_name, heal_type)
	local unit = self.unit
	self:_add_to_damage_history_buffer(unit, healer_unit, -heal_amount, nil, "heal", nil, nil, heal_source_name, nil, nil, nil, nil)

	if not self.dead then
		self.damage = math.max(0, self.damage - heal_amount)

		local unit_id, is_level_unit = Managers.state.network:game_object_or_level_id(unit)
		if unit_id and self.is_server then
			local network_manager = Managers.state.network
			local healer_unit_id, healer_is_level_unit = network_manager:game_object_or_level_id(healer_unit)
			local heal_type_id = NetworkLookup.heal_types [heal_type]
			local network_transmit = self.network_transmit
			network_transmit:send_rpc_clients("rpc_heal", unit_id, is_level_unit, healer_unit_id, healer_is_level_unit, heal_amount, heal_type_id)
		end
	end
end

function GenericHealthExtension:die(damage_type)
	if self.is_server then
		local unit = self.unit
		if ScriptUnit.has_extension(unit, "ai_system") then
			damage_type = damage_type or "undefined"
			AiUtils.kill_unit(unit, nil, nil, damage_type, nil)
		end
	end
end

function GenericHealthExtension:entered_kill_volume(t)
	self:die("volume_insta_kill")
end

function GenericHealthExtension:set_dead()








	self.damage = self.health
	self.dead = true
	HEALTH_ALIVE [self.unit] = nil
end

function GenericHealthExtension:has_assist_shield()
	return false
end


function GenericHealthExtension:recent_damages()

	local previous_buffer_index = 3 - self.system_data.active_damage_buffer_index
	local damage_queue = self.damage_buffers [previous_buffer_index]
	return pdArray.data(damage_queue)
end

function GenericHealthExtension:recent_damage_source()
	return self._recent_damage_source_name
end

function GenericHealthExtension:recently_damaged()
	return self._recent_damage_type, self._recent_hit_react_type
end

function GenericHealthExtension:last_damage_t()
	return self._last_damage_t
end

function GenericHealthExtension:get_is_invincible()
	local unit = self.unit
	local has_invincibility_buff = false
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	if buff_extension then
		has_invincibility_buff = buff_extension:has_buff_perk("invulnerable")
	end
	local dlc_is_invincible = false

	local ghost_mode_extension = ScriptUnit.has_extension(unit, "ghost_mode_system")
	if ghost_mode_extension then
		dlc_is_invincible = ghost_mode_extension:is_in_ghost_mode()
	end

	return self.is_invincible or has_invincibility_buff or dlc_is_invincible
end

function GenericHealthExtension:save_kill_feed_data(attacker_unit, damage_table, hit_zone_name, damage_type, damage_source_name, source_attacker_unit)
	local unit = self.unit
	local last_damage_data = self.last_damage_data
	local registered_damage = false
	local current_health = self:current_health()
	if damage_type ~= "temporary_health_degen" and damage_type ~= "knockdown_bleed" and current_health > 0 then
		local attacker_unit = source_attacker_unit or AiUtils.get_actual_attacker_unit(attacker_unit)
		if HEALTH_ALIVE [attacker_unit] then
			local breed = Unit.get_data(attacker_unit, "breed")
			local ai_suicide = attacker_unit == unit and breed and not breed.is_player
			if not ai_suicide and (attacker_unit ~= unit or damage_type ~= "cutting") and breed then
				last_damage_data.breed = breed
				last_damage_data.damage_type = damage_type

				local network_manager = Managers.state.network
				last_damage_data.attacker_unit_id = network_manager:unit_game_object_id(attacker_unit)
				registered_damage = true
				local player = Managers.player:owner(attacker_unit)
				if player then
					last_damage_data.attacker_unique_id = player:unique_id()
					last_damage_data.attacker_side = Managers.state.side.side_by_unit [attacker_unit]
				else
					last_damage_data.attacker_unique_id = nil
					last_damage_data.attacker_side = nil
				end
			end
		end
	end

	if not registered_damage then
		local area_damage_extension = ScriptUnit.has_extension(attacker_unit, "area_damage_system")
		if area_damage_extension then
			local source_attacker_unit_data = area_damage_extension.source_attacker_unit_data
			if source_attacker_unit_data then
				last_damage_data.breed = source_attacker_unit_data.breed
				last_damage_data.attacker_unique_id = source_attacker_unit_data.attacker_unique_id
				last_damage_data.attacker_side = source_attacker_unit_data.attacker_side
			end
		end
	end
end

function GenericHealthExtension:_register_attacker(attacker_unit, source_attacker_unit, t)
	local unit = source_attacker_unit or AiUtils.get_actual_attacker_unit(attacker_unit)
	if unit then
		self._recent_attackers [unit] = t
	end
end

function GenericHealthExtension:was_attacked_by(unit)
	return self._recent_attackers [unit]
end