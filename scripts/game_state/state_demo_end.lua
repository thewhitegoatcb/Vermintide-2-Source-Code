require("scripts/ui/views/demo_end_ui")

StateDemoEnd = class(StateDemoEnd)
StateDemoEnd.NAME = "StateDemoEnd"

function StateDemoEnd:on_enter()
	self:_setup_world()
	self:_setup_input()
	self:_setup_ui()
	self:_handle_fade()
	self:_handle_video_playback()
end

function StateDemoEnd:_handle_video_playback()
	Framerate.set_low_power()
	Managers.music:stop_all_sounds()
end

function StateDemoEnd:on_exit()
	if self._demo_end_ui then
		self._demo_end_ui:destroy()
		self._demo_end_ui = nil
	end

	self._input_manager:destroy()
	self._input_manager = nil
	Managers.input = nil
	Managers.state:destroy()

	Framerate.set_playing()

	ScriptWorld.destroy_viewport(self._world, self._viewport_name)
	Managers.world:destroy_world(self._world)
end

function StateDemoEnd:_setup_world()
	self._world_name = "demo_end_world"
	self._viewport_name = "demo_end_world_viewport"

	self._world = Managers.world:create_world(self._world_name, GameSettingsDevelopment.default_environment, nil, nil, Application.DISABLE_PHYSICS, Application.DISABLE_APEX_CLOTH)
	self._viewport = ScriptWorld.create_viewport(self._world, self._viewport_name, "overlay", 1)
end

function StateDemoEnd:_setup_input()
	self._input_manager = InputManager:new()
	local input_manager = self._input_manager
	Managers.input = input_manager
	input_manager:initialize_device("keyboard", 1)
	input_manager:initialize_device("mouse", 1)
	input_manager:initialize_device("gamepad")
end

function StateDemoEnd:_setup_ui()
	self._demo_end_ui = DemoEndUI:new(self._world)
end

function StateDemoEnd:_handle_fade()
	Managers.transition:hide_loading_icon()
	Managers.transition:fade_out(GameSettings.transition_fade_in_speed)
end

function StateDemoEnd:update(dt, t)
	self._demo_end_ui:update(dt, t)

	return self:_try_exit()
end

function StateDemoEnd:cb_fade_in_done(state)
	self._new_state = state
end

function StateDemoEnd:_try_exit()
	local skip_outro = false
	if BUILD == "dev" and Keyboard.pressed(Keyboard.ENTER) then
		skip_outro = true
	end

	if not self._fade_started and (self._demo_end_ui:completed() or skip_outro) then
		Managers.transition:fade_in(GameSettings.transition_fade_out_speed, callback(self, "cb_fade_in_done", StateTitleScreen))
		self._fade_started = true
	end

	return self._new_state
end