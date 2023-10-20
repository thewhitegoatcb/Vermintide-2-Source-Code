
require("scripts/settings/razer_chroma_settings")

RazerChromaManager = class(RazerChromaManager)

RAZER_ADD_ANIMATION_TYPE = { REPLACE = 2, QUEUE = 3, DO_NOTHING = 1 }





function RazerChromaManager:init()
	self._initialized = false
	self._current_animations = { }
	self._is_playing = false
	self._default_keys = { }
	self.current_animation = ""
	self._progress = 0
end

function RazerChromaManager:destroy()
	self:unload_packages()
end

function RazerChromaManager:load_packages()
	if not rawget(_G, "RazerChroma") or
	not GameSettingsDevelopment.use_razer_chroma or
	self._initialized then
		return
	end

	Managers.package:load("resource_packages/razer_chroma", "RazerChroma",
	callback(self, "cb_load_chroma_files"), true,
	false)
end

function RazerChromaManager:unload_packages()
	if not self._initialized then
		return
	end

	self:stop_animation()
	self.reset_keyboard()

	RazerChroma.close_all_chroma_files()
	Managers.package:unload("resource_packages/razer_chroma", "RazerChroma")
	self._initialized = false
end

function RazerChromaManager:cb_load_chroma_files()
	for name, settings in pairs(RazerChromaSettings) do
		local file_path = settings.file_path
		local animation_id = RazerChroma.load_chroma_file(file_path)
		fassert(animation_id >= 0, "Failed to load chroma animation: " .. file_path)
	end
	self._initialized = true

	self:lit_keybindings(true)
end

function RazerChromaManager:update(dt)
	if not self._initialized or not GameSettingsDevelopment.use_razer_chroma then
		return
	end

	self:_check_should_play_conditions()
	self:_update_current_animations(dt)
end

function RazerChromaManager:_check_should_play_conditions()


	local should_play, loop, action = nil
	for name, chroma_setting in pairs(RazerChromaSettings) do
		if chroma_setting.condition_play_func then
			should_play, loop, action = chroma_setting.condition_play_func(self)
			if should_play then
				self:play_animation(name, loop, action)
			end
		end
	end
end

function RazerChromaManager._get_button_name(keybind, keymap)
	local key_id = keymap [keybind] [2]
	return key_id ~= "unassigned_keymap" and Keyboard.button_name(key_id) or nil
end

function RazerChromaManager:lit_keybindings(should_update)


	if not self._initialized then
		return
	end

	if should_update then

		local keymaps_table = Managers.input:keymaps_data("PlayerControllerKeymaps")
		local keymap = keymaps_table.win32.keymaps
		local basic_keys = {
			self._get_button_name("move_forward", keymap),
			self._get_button_name("move_left", keymap),
			self._get_button_name("move_back", keymap),
			self._get_button_name("move_right", keymap),
			self._get_button_name("action_career", keymap),
			self._get_button_name("weapon_reload", keymap),
			self._get_button_name("interact", keymap),
			self._get_button_name("jump_1", keymap),
			self._get_button_name("jump_only", keymap),
			self._get_button_name("crouch", keymap),
			self._get_button_name("dodge_hold", keymap),
			self._get_button_name("dodge", keymap),
			self._get_button_name("wield_1", keymap),
			self._get_button_name("wield_2", keymap),
			self._get_button_name("wield_3", keymap),
			self._get_button_name("wield_4", keymap),
			self._get_button_name("wield_5", keymap) }


		self._default_keys = { }
		for _, key in pairs(basic_keys) do

			local razer_key = self:_string_to_key_mapping(key)
			self._default_keys [#self._default_keys + 1] = razer_key
		end
	end


	self.reset_keyboard()
	self:set_keys_color(self._default_keys, 255, 0, 0)
end

function RazerChromaManager:_update_current_animations(dt)

	local current_animation = self._current_animations [1]

	if not current_animation then
		do return end
	elseif not self._is_playing then

		self:_start_animation(current_animation)
	end


	self._progress = self._progress + dt


	local animation_done = current_animation.length <= self._progress
	local should_stop = current_animation.condition_stop_func and current_animation.condition_stop_func(self)

	if animation_done or should_stop then

		if not should_stop and current_animation.loop and #self._current_animations <= 1 then



			self._progress = 0
			return
		end


		current_animation = nil
		table.remove(self._current_animations, 1)
		self._is_playing = false
		if #self._current_animations == 0 then

			self:lit_keybindings()
			self.current_animation = ""
		end
	end

end

function RazerChromaManager.set_keyboard_color(red, green, blue)
	RazerChroma.set_keyboard_color(red, green, blue)
end

function RazerChromaManager.set_mouse_color(red, green, blue)
	RazerChroma.set_mouse_color(red, green, blue)
end

function RazerChromaManager.reset_keyboard()
	RazerChroma.set_keyboard_color(0, 0, 0)
end

function RazerChromaManager.reset_mouse()
	RazerChroma.set_mouse_color(0, 0, 0)
end

function RazerChromaManager:play_animation(chroma, loop, action)
	if not self._initialized then
		return
	end

	fassert(chroma ~= nil, "chroma can not be nil")

	local chroma_settings = RazerChromaSettings [chroma]
	if not chroma_settings then
		Application.warning("[RazerChromaManager] No chroma '" .. chroma .. "' exists")
		return
	end

	loop = loop or false
	action = action or RAZER_ADD_ANIMATION_TYPE.QUEUE

	local is_playing = self._is_playing
	local current_animations = self._current_animations

	local data = {
		name = chroma,
		file_path = chroma_settings.file_path,
		length = chroma_settings.length,
		loop = loop,
		on_play_func = chroma_settings.on_play_func,
		condition_stop_func = chroma_settings.condition_stop_func }


	if not is_playing then

		current_animations [#current_animations + 1] = data
	elseif action == RAZER_ADD_ANIMATION_TYPE.DO_NOTHING then

		do return end
	elseif action == RAZER_ADD_ANIMATION_TYPE.QUEUE then

		current_animations [#current_animations + 1] = data
		do return end
	elseif action == RAZER_ADD_ANIMATION_TYPE.REPLACE then

		self:stop_animation()
		current_animations [1] = data
	else
		fassert(false, "Invalid action value: " .. action)
	end

	self:_start_animation(data)
end

function RazerChromaManager:_start_animation(chroma_settings)
	if chroma_settings.on_play_func then

		chroma_settings.on_play_func(self)
	else

		RazerChroma.play_animation(chroma_settings.file_path, chroma_settings.loop)
	end
	self.current_animation = chroma_settings.name
	self._is_playing = true
	self._progress = 0
end

function RazerChromaManager:stop_animation()


	local current_animation = self._current_animations [1]
	if not current_animation then
		return
	end

	RazerChroma.stop_animation(current_animation.file_path)
	table.remove(self._current_animations, 1)
	self._is_playing = false
end

function RazerChromaManager:_string_to_key_mapping(key)


	local key_string = key

	if tonumber(key_string) then

		key_string = "KEY" .. key_string
	else

		local blankspace_index = string.find(key_string, " ")
		if blankspace_index then
			key_string = string.sub(key, 0, 1) .. string.sub(key, blankspace_index + 1)
		end
	end

	return RazerChroma [string.upper(key_string)]
end

function RazerChromaManager:set_keys_color(keys, red, green, blue)

	assert(type(keys) == "table")

	for _, key in pairs(keys) do
		if type(key) ~= "number" then
			key = self:_string_to_key_mapping(key)
		end
		RazerChroma.set_key_color(key, red, green, blue)
	end
end