ActionCareerDREngineer = class(ActionCareerDREngineer, ActionRangedBase)
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

local BOT_THREAT_REFRESH_TIME = 1
local BOT_THREAT_DURATION = 1.2
local BOT_THREAT_AREA_W = 3 local BOT_THREAT_AREA_H = 2 local BOT_THREAT_AREA_D = 6
local MAX_SHOTS_PER_FRAME = 3
local FREE_ABILITY_AMMO_TIME = 10
local unit_set_flow_variable = Unit.set_flow_variable
local unit_flow_event = Unit.flow_event

function ActionCareerDREngineer:init(world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	ActionCareerDREngineer.super.init(self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	self.career_extension = ScriptUnit.extension(owner_unit, "career_system")
	self.talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	self.buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	self.weapon_extension = ScriptUnit.extension(weapon_unit, "weapon_system")
	self.ai_bot_group_system = Managers.state.entity:system("ai_bot_group_system")

	self._attack_speed_anim_var_3p = Unit.animation_find_variable(owner_unit, "attack_speed")
	self._time_to_shoot = 0
	self._last_avoidance_t = 0
	self._free_ammo_t = 0
	self._ranged_attack = true
	self._num_extra_shots = 0
end

function ActionCareerDREngineer:client_owner_start_action(new_action, t, chain_action_data, power_level, action_init_data)
	local old_time_to_shoot = self._time_to_shoot
	ActionCareerDREngineer.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level)

	self._visual_heat_generation = new_action.visual_heat_generation or 0
	self._base_anim_speed = new_action.base_anim_speed or 1
	self._shot_cost = new_action.ammo_usage
	self._calculated_attack_speed = false
	self._initial_rounds_per_second = new_action.initial_rounds_per_second
	self._max_rps = new_action.max_rps
	self._rps_loss_per_second = new_action.rps_loss_per_second
	self._rps_gain_per_shot = new_action.rps_gain_per_shot
	self._projectiles_per_shot = new_action.shot_count

	local windup = math.clamp(self.weapon_extension:get_custom_data("windup"), 0, 1)
	self._current_rps = math.lerp(self._initial_rounds_per_second, self._max_rps, windup)
	self._attack_speed_mod = 1


	if self.talent_extension:has_talent("bardin_engineer_reduced_ability_fire_slowdown") then
		self._max_rps = new_action.max_rps * 1.3
		self._current_rps = self._max_rps
	end


	Managers.state.achievement:trigger_event("crank_gun_fire_start", self.owner_unit)
	self._ammo_expended = 0
	self.extra_buff_shot = false


	self:_update_attack_speed(t)
	self._time_to_shoot = math.max(old_time_to_shoot, t - 1 / self._current_rps)
	self._first_shot = true

	local fire_loop_start = new_action.fire_loop_start
	if fire_loop_start then
		self.first_person_extension:play_hud_sound_event(fire_loop_start)
	end

	self:_play_vo()
end

function ActionCareerDREngineer:_update_attack_speed(t)
	if not self._calculated_attack_speed then
		self._attack_speed_mod = ActionUtils.get_action_time_scale(self.owner_unit, self.current_action)
		self:_update_animation_speed(self._current_rps * self._attack_speed_mod)
		self.first_person_extension:animation_set_variable("barrel_spin_speed", self._attack_speed_mod)
		self._calculated_attack_speed = true
	end
end

function ActionCareerDREngineer:_waiting_to_shoot(dt, t)
	self:_update_animation_speed(self._current_rps)

	if self._time_to_shoot <= t then
		local current_cooldown, max_cooldown = self.career_extension:current_ability_cooldown(1)
		local ability_charge = max_cooldown - current_cooldown
		self:_update_attack_speed(t)

		self:_update_bot_avoidance(t)

		local fire_rounds_per_second = self._current_rps * self._attack_speed_mod
		local max_shots = ability_charge / self._shot_cost
		local rounds_to_fire = math.min(fire_rounds_per_second * (t - self._time_to_shoot), max_shots)

		self:_handle_infinite_stacks(dt, t)

		local num_projectiles = math.floor(rounds_to_fire)
		if num_projectiles > 0 then

			local override_extra_shots = true

			local projectiles_per_shot = self._projectiles_per_shot
			local total_shots = projectiles_per_shot
			local buff_shots = self:_update_extra_shots(self.buff_extension, 0, override_extra_shots) or 0
			if buff_shots > 0 then
				self.extra_buff_shot = true
				self._num_extra_shots = buff_shots
				total_shots = total_shots + buff_shots
			end

			self._current_rps = math.clamp(self._current_rps + self._rps_gain_per_shot * num_projectiles, self._initial_rounds_per_second, self._max_rps)
			self._time_last_fired = t
			self._time_to_shoot = t - ( rounds_to_fire - num_projectiles ) / fire_rounds_per_second
			self._num_projectiles_per_shot = num_projectiles * total_shots
			self._state = "start_shooting"
			self._calculated_attack_speed = false
		end

		self._first_shot = false
	end
end

function ActionCareerDREngineer:_shooting(t, action_ended)
	local num_projectiles_per_shot = self._num_projectiles_per_shot
	local num_projectiles_spawned = self._num_projectiles_spawned
	local num_shots_this_frame = num_projectiles_per_shot - num_projectiles_spawned
	if not action_ended then
		num_shots_this_frame = math.min(num_shots_this_frame, MAX_SHOTS_PER_FRAME)
	end

	self._num_projectiles_spawned = self:shoot(num_shots_this_frame, num_projectiles_spawned, num_projectiles_per_shot)

	if num_projectiles_per_shot - self._num_projectiles_spawned <= 0 then
		local current_action = self.current_action
		local first_person_extension = self.first_person_extension
		first_person_extension:apply_recoil()
		first_person_extension:play_camera_recoil(current_action.recoil_settings, t)
		Managers.state.achievement:trigger_event("crank_gun_fire", self.owner_unit, 1)
		unit_flow_event(self.weapon_unit, "lua_finish_shooting")

		if self:_has_ammo() then
			self._state = "waiting_to_shoot"
		else
			self._state = "finished_shooting"
		end
	end
end

function ActionCareerDREngineer:_finished_shooting(t)
	self.weapon_extension:stop_action("action_complete")
end

function ActionCareerDREngineer:finish(reason)
	ActionCareerDREngineer.super.finish(self, reason)
	local initial_rps = self._initial_rounds_per_second
	local rps_range = self._max_rps - initial_rps
	local windup = math.clamp(( self._current_rps - initial_rps ) / rps_range, 0, 1)
	self.weapon_extension:set_custom_data("windup", windup)
	Managers.state.event:trigger("on_engineer_weapon_spin_up", windup)
end

function ActionCareerDREngineer:proc_extra_shot(t)
	return false
end

function ActionCareerDREngineer:gen_num_shots()
	return 1, 1
end

function ActionCareerDREngineer:apply_shot_cost(t)
	self:_fake_activate_ability(t)
	local should_consume_ammo = self._free_ammo_t < t
	local buff_extension = self.buff_extension
	if buff_extension and buff_extension:has_buff_perk(buff_perks.free_ability_engineer) then
		should_consume_ammo = false
	end

	if should_consume_ammo then
		local projectiles_per_shot = self._num_projectiles_per_shot
		if self.extra_buff_shot then
			projectiles_per_shot = math.max(projectiles_per_shot - self._num_extra_shots, 1)
		end
		self.career_extension:reduce_activated_ability_cooldown(-self._shot_cost * projectiles_per_shot)
		self.extra_buff_shot = false
		self._num_extra_shots = 0
	end
end

function ActionCareerDREngineer:_has_ammo()
	local ability_cooldown, max_cooldown = self.career_extension:current_ability_cooldown(1)
	return self._shot_cost <= max_cooldown - ability_cooldown
end

function ActionCareerDREngineer:_play_vo()
	local owner_unit = self.owner_unit
	local dialogue_input = ScriptUnit.extension_input(owner_unit, "dialogue_system")
	local event_data = FrameTable.alloc_table()
	dialogue_input:trigger_networked_dialogue_event("activate_ability", event_data)
end

function ActionCareerDREngineer:_play_vfx()
	return end

function ActionCareerDREngineer:_update_animation_speed(shots_per_second)
	local anim_time_scale = self._base_anim_speed * shots_per_second
	anim_time_scale = math.clamp(anim_time_scale, NetworkConstants.animation_variable_float.min, NetworkConstants.animation_variable_float.max)
	self.first_person_extension:animation_set_variable("attack_speed", anim_time_scale)
	Managers.state.network:anim_set_variable_float(self.owner_unit, "attack_speed", anim_time_scale)
end

local INDEX_POSITION = 1
local INDEX_DISTANCE = 2
function ActionCareerDREngineer:fire_hitscan(position, direction, range)
	local result = ActionCareerDREngineer.super.fire_hitscan(self, position, direction, range)
	local end_position = result and result [#result] [INDEX_POSITION] or position + direction * range
	local life_time = ( result and result [#result] [INDEX_DISTANCE] or range ) * 0.1
	self:_add_bullet_trail(end_position, life_time)

	Managers.state.event:trigger("on_engineer_weapon_fire", self._visual_heat_generation)

	return result
end

function ActionCareerDREngineer:_add_bullet_trail(end_position, lifetime)
	if not self.is_bot then
		local weapon_unit = self.weapon_unit




		unit_set_flow_variable(weapon_unit, "is_critical_strike", self._is_critical_strike)
		unit_set_flow_variable(weapon_unit, "hit_position", end_position)
		unit_set_flow_variable(weapon_unit, "trail_life", lifetime)
		unit_flow_event(weapon_unit, "lua_bullet_trail")
		unit_flow_event(weapon_unit, "lua_bullet_trail_set")
	end
end

function ActionCareerDREngineer:_update_bot_avoidance(t)
	if not self.is_bot and t > self._last_avoidance_t + BOT_THREAT_REFRESH_TIME then
		self._last_avoidance_t = t
		local current_position, current_rotation = self.first_person_extension:get_projectile_start_position_rotation()
		local threat_position, threat_rotation, threat_size = AiUtils.calculate_oobb(BOT_THREAT_AREA_D, current_position, current_rotation, BOT_THREAT_AREA_H, BOT_THREAT_AREA_W)
		if self.is_server then
			self.ai_bot_group_system:queue_aoe_threat(threat_position, "oobb", threat_size, threat_rotation, BOT_THREAT_DURATION)
		else
			local network_manager = Managers.state.network
			local network_transmit = network_manager.network_transmit
			network_transmit:send_rpc_server("rpc_bot_create_threat_oobb", threat_position, threat_rotation, threat_size, BOT_THREAT_DURATION)
		end
	end
end

function ActionCareerDREngineer:_fake_activate_ability(t)
	local buff_extension = self.buff_extension
	if buff_extension then
		self._ammo_expended = self._ammo_expended + self._shot_cost * self._num_projectiles_per_shot
		if buff_extension:has_buff_perk(buff_perks.free_ability) then
			buff_extension:trigger_procs("on_ability_activated", self.owner_unit, 1)
			buff_extension:trigger_procs("on_ability_cooldown_started")
			self._free_ammo_t = t + FREE_ABILITY_AMMO_TIME
		elseif self._ammo_expended > self.career_extension:get_max_ability_cooldown() / 2 then
			buff_extension:trigger_procs("on_ability_activated", self.owner_unit, 1)
			buff_extension:trigger_procs("on_ability_cooldown_started")
			self._ammo_expended = 0
		end
	end
end


function ActionCareerDREngineer:_handle_infinite_stacks(dt, t)
	if not self.talent_extension:has_talent("bardin_engineer_pump_buff_long") then
		return
	end


	local buff_extension = self.buff_extension
	local buffs = buff_extension:get_stacking_buff("bardin_engineer_pump_buff")
	if buffs then
		if self._first_shot then
			for i = 1, #buffs do
				if buffs [i].duration then
					return
				end
			end

			local first_buff = buffs [1]
			first_buff.duration = CareerConstants.dr_engineer.talent_4_3_stack_duration
			first_buff.start_time = t
		else
			local duration_buff = nil
			for i = 1, #buffs do
				local buff = buffs [i]
				if buff.duration then
					duration_buff = buff
					break
				end
			end

			if not duration_buff then
				duration_buff = buffs [1]
				duration_buff.duration = CareerConstants.dr_engineer.talent_4_3_stack_duration
				duration_buff.start_time = t
				return
			end
		end
	end
end