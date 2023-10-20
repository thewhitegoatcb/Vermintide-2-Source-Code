require("scripts/unit_extensions/default_player_unit/charge/overcharge_data")

PlayerHuskOverchargeExtension = class(PlayerHuskOverchargeExtension)

function PlayerHuskOverchargeExtension:init(extension_init_context, unit, extension_init_data)
	self.network_manager = Managers.state.network
	self.unit = unit

	local overcharge_data = extension_init_data.overcharge_data
	self.overcharge_value = 0
	self.overcharge_threshold = 0
	self.max_value = extension_init_data.overcharge_max_value
	self.original_max_value = overcharge_data.max_value or 40
	self.overcharge_limit = self.max_value * 0.65
	self.overcharge_critical_limit = self.max_value * 0.8
	self._lerped_overcharge_fraction = 0
end

function PlayerHuskOverchargeExtension:extensions_ready(world, unit)
	self.status_extension = ScriptUnit.extension(unit, "status_system")
end

function PlayerHuskOverchargeExtension:set_screen_particle_opacity_modifier()
	return end

function PlayerHuskOverchargeExtension:reset()
	return end

function PlayerHuskOverchargeExtension:destroy()
	return end

function PlayerHuskOverchargeExtension:set_animation_variable()
	return end

function PlayerHuskOverchargeExtension:_update_game_object()
	local network_manager = self.network_manager
	local unit = self.unit
	local game = network_manager:game()
	local go_id = Managers.state.unit_storage:go_id(unit)

	if game and go_id then
		local current_value_percentage = GameSession.game_object_field(game, go_id, "overcharge_percentage")
		local threshold_percentage = GameSession.game_object_field(game, go_id, "overcharge_threshold_percentage")
		local max_value = GameSession.game_object_field(game, go_id, "overcharge_max_value")

		local value = current_value_percentage * max_value
		local threshold = threshold_percentage * max_value

		self.overcharge_value = value
		self.overcharge_threshold = threshold
		self.max_value = max_value
		self.overcharge_limit = max_value * 0.65
		self.overcharge_critical_limit = max_value * 0.8
	end
end

function PlayerHuskOverchargeExtension:update(unit, input, dt, context, t)
	self:_update_lerped_overcharge(dt)
	self:_update_game_object()










end

function PlayerHuskOverchargeExtension:add_charge()
	return end

function PlayerHuskOverchargeExtension:remove_charge()
	return end

function PlayerHuskOverchargeExtension:hud_sound()
	return end

function PlayerHuskOverchargeExtension:get_overcharge_value()
	return self.overcharge_value
end

function PlayerHuskOverchargeExtension:is_above_critical_limit()
	return self.overcharge_critical_limit <= self.overcharge_value
end

function PlayerHuskOverchargeExtension:get_max_value()
	return self.max_value
end

function PlayerHuskOverchargeExtension:get_original_max_value()
	return self.original_max_value
end

function PlayerHuskOverchargeExtension:get_overcharge_threshold()
	return self.overcharge_threshold
end

function PlayerHuskOverchargeExtension:above_overcharge_threshold()
	return self.overcharge_threshold <= self.overcharge_value
end

function PlayerHuskOverchargeExtension:overcharge_fraction()
	return self.overcharge_value / self.max_value
end

function PlayerHuskOverchargeExtension:threshold_fraction()
	return self.overcharge_threshold / self.max_value
end

function PlayerHuskOverchargeExtension:current_overcharge_status()
	local value = self:get_overcharge_value()
	local threshold = self:get_overcharge_threshold()
	local max_value = self:get_max_value()

	return value, threshold, max_value
end

function PlayerHuskOverchargeExtension:vent_overcharge()
	return end

function PlayerHuskOverchargeExtension:vent_overcharge_done()
	return end

function PlayerHuskOverchargeExtension:get_anim_blend_overcharge()
	local overcharge_value = self._lerped_overcharge_fraction * self:get_max_value()
	local overcharge_threshold = self.overcharge_threshold
	local max_value = self.max_value

	local anim_blend_value = math.clamp(( overcharge_value - overcharge_threshold ) / (max_value - overcharge_threshold), 0, 1)

	return anim_blend_value
end

function PlayerHuskOverchargeExtension:_update_lerped_overcharge(dt)
	local target_fraction = self:overcharge_fraction()
	local lerped_fraction = self._lerped_overcharge_fraction
	if target_fraction == lerped_fraction then
		return
	end

	local slow_breakpoint = 0.1 local fast_breakpoint = 0.2
	local fast_multiplier = 10
	local lerp_speed = 0.3
	local diff = math.abs(lerped_fraction - target_fraction)
	if fast_breakpoint < diff then

		lerp_speed = lerp_speed * fast_multiplier
	elseif slow_breakpoint < diff then

		lerp_speed = lerp_speed * math.remap(slow_breakpoint, fast_breakpoint, 1, fast_multiplier, diff)
	end

	local min_fraction = math.min(lerped_fraction, target_fraction)
	local max_fraction = math.max(lerped_fraction, target_fraction)

	lerped_fraction = lerped_fraction + math.sign(target_fraction - lerped_fraction) * lerp_speed * dt
	lerped_fraction = math.clamp(lerped_fraction, min_fraction, max_fraction)

	self._lerped_overcharge_fraction = lerped_fraction
end