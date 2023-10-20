require("scripts/unit_extensions/generic/generic_state_machine")

PlayerInputExtension = class(PlayerInputExtension)

function PlayerInputExtension:init(extension_init_context, unit, extension_init_data)
	self.unit = unit

	self.player = extension_init_data.player
	self.input_service = self.player.input_source

	self.enabled = true
	self.has_released_input = { }

	self.input_buffer_timer = nil
	self.buffer_key = nil
	self.input_buffer = nil

	self.new_input_buffer_timer = 0
	self.new_input_buffer = nil
	self.new_buffer_key = nil
	self.last_added_buffer_time = 0
	self.new_buffer_key_doubleclick_window = nil
	self.input_buffer_reset = false
	self.added_stun_buffer = false

	self.wield_cooldown = false
	self.wield_cooldown_timer = 0
	self.wield_cooldown_timer_clock = 0
	self.wield_scroll_value = nil

	self.double_tap_timers = { }
	self.input_key_scale = { }

	self._t = 0

	self.minimum_dodge_input = 0.3
	self._game_options_dirty = true


	self.priority_input = { wield_2 = 1, wield_next = 1, wield_5 = 1, wield_prev = 1, wield_scroll = 1, wield_3 = 1, wield_1 = 2, wield_4 = 1, wield_switch = 3 }











	Managers.state.event:register(self, "on_game_options_changed", "_set_game_options_dirty")
	self:_update_game_options()
end

function PlayerInputExtension:destroy()
	Managers.state.event:unregister("on_game_options_changed", self)
end

function PlayerInputExtension:reset()
	return end

function PlayerInputExtension:_set_game_options_dirty()
	self._game_options_dirty = true
end

function PlayerInputExtension:_update_game_options()
	if not self._game_options_dirty then
		return
	end

	self.double_tap_dodge = Application.user_setting("double_tap_dodge")
	self.toggle_crouch = Application.user_setting("toggle_crouch")
	self.toggle_alternate_attack = Application.user_setting("toggle_alternate_attack")
	self.input_buffer_user_setting = Application.user_setting("input_buffer")
	self.priority_input_buffer_user_setting = Application.user_setting("priority_input_buffer")

	self._game_options_dirty = false
end

function PlayerInputExtension:update(unit, input, dt, context, t)
	self._t = t








	self:_update_game_options()

	if self.input_buffer_reset then
		self.last_added_buffer_time = t
		self.input_buffer_reset = false
	end
	if self.new_input_buffer then
		if t > self.last_added_buffer_time + self.new_buffer_key_doubleclick_window then
			self.input_buffer_timer = self.new_input_buffer_timer
			self.input_buffer = self.new_input_buffer
			self.buffer_key = self.new_buffer_key
			self.last_added_buffer_time = t
		end
		self.new_input_buffer_timer = 0
		self.new_input_buffer = nil
		self.new_buffer_key = nil
	end
	if self.input_buffer and self.input_buffer_timer then
		self.input_buffer_timer = self.input_buffer_timer - dt
		if self.input_buffer_timer <= 0 then
			self.input_buffer_timer = 0
			self.input_buffer = nil
			self.buffer_key = nil
		end
	end
	if self.wield_cooldown then
		if self.wield_cooldown_timer < t then
			self.wield_cooldown = false
			self.wield_cooldown_timer_clock = 0
		else
			self.wield_cooldown_timer_clock = self.wield_cooldown_timer_clock + dt
		end
	end
	if self._release_input_delay then
		self._release_input_delay = self._release_input_delay - dt
		if self._release_input_delay <= 0 then
			self._release_input_delay = nil
			self:reset_release_input()
		end
	end
end

function PlayerInputExtension:start_double_tap(input_key, t)
	self.double_tap_timers [input_key] = t
end

function PlayerInputExtension:clear_double_tap(input_key)
	self.double_tap_timers [input_key] = nil
end

function PlayerInputExtension:was_double_tap(input_key, t, max_duration)
	local last_double_tap = self.double_tap_timers [input_key]

	return last_double_tap and t < last_double_tap + max_duration
end


local is_windows_platform = IS_WINDOWS
function PlayerInputExtension:is_input_blocked()






	return ( self.input_service:is_blocked() or
	is_windows_platform and not Window.has_focus() or
	HAS_STEAM and Managers.steam:is_overlay_active() ) and

	not DamageUtils.is_in_inn and
	not Managers.state.entity:system("cutscene_system"):is_active()
end

function PlayerInputExtension:get(input_key, consume)
	local value = self.input_service:get(input_key, consume)
	if not self.enabled or self:is_input_blocked() then
		local value_type = type(value)
		if value_type == "userdata" then
			return Vector3.zero()
		end
		return nil
	end

	local input_key_scale_data = self.input_key_scale [input_key]
	if value and input_key_scale_data then
		local t = self._t
		local scale = nil
		if input_key_scale_data.lerp_end_t == nil or input_key_scale_data.lerp_end_t <= t then
			scale = input_key_scale_data.end_scale
		else
			local p = ( t - input_key_scale_data.lerp_start_t ) / (input_key_scale_data.lerp_end_t - input_key_scale_data.lerp_start_t)
			scale = math.lerp(input_key_scale_data.start_scale, input_key_scale_data.end_scale, p)
		end
		return value * scale
	end

	return value
end

function PlayerInputExtension:set_enabled(enabled)
	self.enabled = enabled
end

function PlayerInputExtension:set_input_key_scale(input_key, scale, lerp_time)
	fassert(lerp_time == nil or lerp_time > 0, "PlayerInputExtension:set_input_key_scale: Must enter a lerp_time larger than zero if lerp is to be used!")

	local start_scale = 1
	local t = self._t
	local lerp_end_t = lerp_time and t + lerp_time or nil

	local input_key_scale_data = self.input_key_scale [input_key]
	if input_key_scale_data then
		if input_key_scale_data.lerp_end_t == nil or input_key_scale_data.lerp_end_t <= t then
			start_scale = input_key_scale_data.end_scale
		else
			local p = ( t - input_key_scale_data.lerp_start_t ) / (input_key_scale_data.lerp_end_t - input_key_scale_data.lerp_start_t)
			start_scale = math.lerp(input_key_scale_data.start_scale, input_key_scale_data.end_scale, p)
		end
	else
		input_key_scale_data = { }
		self.input_key_scale [input_key] = input_key_scale_data
	end
	input_key_scale_data.lerp_start_t = t
	input_key_scale_data.lerp_end_t = lerp_end_t
	input_key_scale_data.start_scale = start_scale
	input_key_scale_data.end_scale = scale
end

function PlayerInputExtension:get_last_scroll_value()
	return self.wield_scroll_value
end

function PlayerInputExtension:set_last_scroll_value(scroll_value)
	self.wield_scroll_value = scroll_value
end

function PlayerInputExtension:released_input(input)
	if self.has_released_input [input] then
		return true
	end

	local get_input_release = self.input_service:get(input)
	if not get_input_release then
		self.has_released_input [input] = true
	end
	return self.has_released_input [input]
end

function PlayerInputExtension:reset_release_input()
	for input, key in pairs(self.has_released_input) do
		self.has_released_input [input] = false
	end
	return true
end



function PlayerInputExtension:force_release_input(input)
	self.has_released_input [input] = true
	return true
end

function PlayerInputExtension:reset_release_input_with_delay(delay)
	self._release_input_delay = self._release_input_delay and self._release_input_delay + delay or delay
end

function PlayerInputExtension:get_wield_cooldown(override_cooldown_time)

	if override_cooldown_time then
		if override_cooldown_time < self.wield_cooldown_timer_clock then

			do return true end
		else
			self.wield_cooldown = false
			do return false end
		end
	elseif self.wield_cooldown then

		return true
	end

	return false
end

function PlayerInputExtension:add_wield_cooldown(cooldown_time)
	self.wield_cooldown = true
	self.wield_cooldown_timer = cooldown_time

end

function PlayerInputExtension:get_buffer(input_key)
	if self.input_buffer_timer and self.buffer_key == input_key then
		return self.input_buffer
	end
	return nil
end

local action_one_variants = { action_one_release = true, action_one = true, action_one_hold = true }


function PlayerInputExtension:reset_input_buffer()



	if self.priority_input [self.buffer_key] then
		return
	end

	if self.buffer_key == "action_one" and not self.input_service:get("action_one_hold") then
		self.buffer_key = "action_one_release"
		self.input_buffer_timer = self.input_buffer_user_setting
		return
	end

	if self.added_stun_buffer then
		self.added_stun_buffer = false
		do return end
	else
		self.input_buffer_timer = 0
		self.input_buffer = nil
		self.buffer_key = nil
	end

end

function PlayerInputExtension:clear_input_buffer(clear_from_wield)
	if not clear_from_wield and self.priority_input [self.buffer_key] then
		return
	end
	self.input_buffer_reset = true
	self.input_buffer_timer = 0
	self.input_buffer = nil
	self.buffer_key = nil

	self.new_input_buffer_timer = 0
	self.new_input_buffer = nil
	self.new_buffer_key = nil

end

function PlayerInputExtension:add_buffer(input_key, doubleclick_window)
	if input_key == "action_one_hold" or input_key ~= "action_two_hold" and self.priority_input [self.buffer_key] and not self.priority_input [input_key] then



		do return end

	elseif input_key == "action_two_hold" then




		return
	end
	local value = self.input_service:get(input_key)
	if value then
		local priority_lookup = self.priority_input
		local priority = priority_lookup [input_key]
		if priority then
			local last_priority = priority_lookup [self.buffer_key] or -1
			if priority >= last_priority then
				self.input_buffer_timer = self.priority_input_buffer_user_setting
				self.input_buffer = value
				self.buffer_key = input_key
			end
		else
			self.new_input_buffer_timer = self.input_buffer_user_setting
			self.new_input_buffer = value
			if self.buffer_key and self.buffer_key ~= input_key and (not action_one_variants [self.buffer_key] or not action_one_variants [input_key]) then
				self.new_buffer_key_doubleclick_window = 0
			else
				self.new_buffer_key_doubleclick_window = doubleclick_window or 0.1
			end
			self.new_buffer_key = input_key
		end
	end
end

function PlayerInputExtension:add_stun_buffer(input_key)
	self.added_stun_buffer = true

	self.input_buffer_timer = self.input_buffer_user_setting
	self.input_buffer = self.input_buffer_user_setting
	self.buffer_key = input_key

end