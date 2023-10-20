require("scripts/unit_extensions/generic/generic_state_machine")

local is_windows_platform = IS_WINDOWS

PlayerInputTutorialExtension = class(PlayerInputTutorialExtension)

function PlayerInputTutorialExtension.get_window_is_in_focus()
	local is_in_focus = false
	if is_windows_platform then
		if Window.has_focus() then
			is_in_focus = true
		end
	else
		is_in_focus = true
	end
	return is_in_focus
end

function PlayerInputTutorialExtension:init(extension_init_context, unit, extension_init_data)
	self.unit = unit

	self.player = extension_init_data.player
	self.input_service = self.player.input_source

	self.enabled = true
	self.has_released_input = false

	self.input_buffer_timer = nil
	self.buffer_key = nil
	self.input_buffer = nil
	self.name = "PlayerInputTutorialExtension"

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
	self.allowed_table = { }
	self.disallowed_table = { }
	self.input_key_scale = { }

	self._t = 0

	self.minimum_dodge_input = 0.3
	self.double_tap_dodge = Application.user_setting("double_tap_dodge")
	self.toggle_crouch = Application.user_setting("toggle_crouch")
	self.toggle_alternate_attack = Application.user_setting("toggle_alternate_attack")

	self.priority_input = { wield_2 = true, wield_next = true, wield_5 = true, wield_prev = true, wield_scroll = true, wield_3 = true, wield_1 = true, wield_4 = true, wield_switch = true }











end

function PlayerInputTutorialExtension:destroy()
	return end

function PlayerInputTutorialExtension:reset()
	return end

function PlayerInputTutorialExtension:update(unit, input, dt, context, t)
	self._t = t

	if self.input_buffer_reset then
		self.last_added_buffer_time = t
		self.input_buffer_reset = false
	end
	if self.new_input_buffer then
		if t > self.last_added_buffer_time + (self.new_buffer_key_doubleclick_window or 0.2) then
			self.input_buffer_timer = self.new_input_buffer_timer
			self.input_buffer = self.new_input_buffer
			self.buffer_key = self.new_buffer_key
			self.last_added_buffer_time = t
		end
		self.new_input_buffer_timer = 0
		self.new_input_buffer = nil
		self.new_buffer_key = nil
	end
	if self.input_buffer then
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
end

function PlayerInputTutorialExtension:start_double_tap(input_key, t)
	self.double_tap_timers [input_key] = t
end

function PlayerInputTutorialExtension:clear_double_tap(input_key)
	self.double_tap_timers [input_key] = nil
end

function PlayerInputTutorialExtension:was_double_tap(input_key, t, max_duration)
	local last_double_tap = self.double_tap_timers [input_key]

	return last_double_tap and t < last_double_tap + max_duration
end

function PlayerInputTutorialExtension:is_input_blocked()
	return false
end

function PlayerInputTutorialExtension:get(input_key, consume)
	local value = self.input_service:get(input_key, consume)
	if not self.enabled or not PlayerInputTutorialExtension.get_window_is_in_focus() then
		if PlayerInputTutorialExtension.get_window_is_in_focus() and self.allowed_table [input_key] then
			do return value end
		else
			local value_type = type(value)
			if value_type == "userdata" then
				return Vector3.zero()
			end
			do return nil end
		end
	elseif self.disallowed_table [input_key] then
		local value_type = type(value)
		if value_type == "userdata" then
			return Vector3.zero()
		end
		return nil
	end
	return value
end

function PlayerInputTutorialExtension:set_enabled(enabled)
	self.enabled = enabled
end

function PlayerInputTutorialExtension:set_input_key_scale(input_key, scale, lerp_time)
	fassert(lerp_time == nil or lerp_time > 0, "PlayerInputTutorialExtension:set_input_key_scale: Must enter a lerp_time larger than zero if lerp is to be used!")

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

function PlayerInputTutorialExtension:set_allowed_inputs(allowed_table)
	self.allowed_table = allowed_table or { }
end

function PlayerInputTutorialExtension:set_disallowed_inputs(disallowed_table)
	self.disallowed_table = disallowed_table or { }
end

function PlayerInputTutorialExtension:allowed_input_table()
	return self.allowed_table
end

function PlayerInputTutorialExtension:disallowed_input_table()
	return self.disallowed_table
end

function PlayerInputTutorialExtension:get_last_scroll_value()
	return self.wield_scroll_value
end

function PlayerInputTutorialExtension:set_last_scroll_value(scroll_value)
	self.wield_scroll_value = scroll_value
end

function PlayerInputTutorialExtension:force_release_input(input)
	self.has_released_input = true

	return true
end

function PlayerInputTutorialExtension:released_input(input)
	if self.has_released_input then
		return true
	end

	local get_input_release = self.input_service:get(input)
	if not get_input_release then
		self.has_released_input = true
	end
	return self.has_released_input
end

function PlayerInputTutorialExtension:reset_release_input()
	self.has_released_input = false
	return true
end

function PlayerInputTutorialExtension:reset_release_input_with_delay(delay)
	self.has_released_input = false
	return true
end

function PlayerInputTutorialExtension:get_wield_cooldown(override_cooldown_time)

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

function PlayerInputTutorialExtension:add_wield_cooldown(cooldown_time)
	self.wield_cooldown = true
	self.wield_cooldown_timer = cooldown_time

end

function PlayerInputTutorialExtension:get_buffer(input_key)
	if self.input_buffer_timer and self.buffer_key == input_key then
		return self.input_buffer
	end
	return nil
end

function PlayerInputTutorialExtension:add_buffer(input_key, doubleclick_window)
	if input_key == "action_one_hold" or self.priority_input [self.buffer_key] and not self.priority_input [input_key] then



		do return end

	elseif input_key == "action_two_hold" then
		return
	end
	local value = self.input_service:get(input_key)
	if value then
		if self.priority_input [input_key] then
			self.input_buffer_timer = 1
			self.input_buffer = value
			self.buffer_key = input_key
		else
			self.new_input_buffer_timer = 0.6
			self.new_input_buffer = value
			self.new_buffer_key = input_key
			self.new_buffer_key_doubleclick_window = doubleclick_window
		end
	end

end

function PlayerInputTutorialExtension:add_stun_buffer(input_key)
	self.added_stun_buffer = true

	self.input_buffer_timer = 10
	self.input_buffer = 1
	self.buffer_key = input_key

end

function PlayerInputTutorialExtension:reset_input_buffer()



	if self.buffer_key == "action_one" and not self.input_service:get("action_one_hold") then
		self.buffer_key = "action_one_release"
		self.input_buffer_timer = 0.5
		return
	end
	if self.added_stun_buffer then
		self.added_stun_buffer = false
		if self.priority_input [self.buffer_key] then
			self.input_buffer_timer = 0
			self.input_buffer = nil
			self.buffer_key = nil
		end
		do return end
	else
		self.input_buffer_timer = 0
		self.input_buffer = nil
		self.buffer_key = nil
	end

end

function PlayerInputTutorialExtension:clear_input_buffer()
	self.input_buffer_reset = true
	self.input_buffer_timer = 0
	self.input_buffer = nil
	self.buffer_key = nil

	self.new_input_buffer_timer = 0
	self.new_input_buffer = nil
	self.new_buffer_key = nil

end