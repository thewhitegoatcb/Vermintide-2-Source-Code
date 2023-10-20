






require("scripts/managers/ui/popup_settings")

UIManager = class(UIManager)


function UIManager:init()
	self._ui_enabled = true
end


function UIManager:destroy()
	if self._ingame_ui then
		print("[UIManager] Warning: destroy_ingame_ui was not called before destroy")
	end
end


function UIManager:create_ingame_ui(ingame_ui_context, loading_subtitle_gui)
	self._ingame_ui_context = ingame_ui_context
	self._loading_subtitle_gui = loading_subtitle_gui

	if self._ingame_ui then
		print("[UIManager] Warning: destroy_ingame_ui was not called before create_ingame_ui")
		self._ingame_ui:destroy()
	end


	self._ingame_ui = IngameUI:new(ingame_ui_context)
	self._ui_enabled = true
end


function UIManager:destroy_ingame_ui()
	local ingame_ui = self._ingame_ui
	if ingame_ui then
		ingame_ui:destroy()
		self._ingame_ui = nil
	end
end

function UIManager:reload_ingame_ui(reload_sources)
	local ingame_ui = self._ingame_ui
	if not ingame_ui then
		print("[UIManager] Warning: reloading the UI when it wasn't loaded.")
		return
	end


	local current_transition = ingame_ui.last_transition_name
	local current_params = ingame_ui.last_transition_params

	if reload_sources then
		for script_path in pairs(package.loaded) do
			if string.find(script_path, "^scripts/ui") then
				package.loaded [script_path] = nil
				require(script_path)
			end
		end
	end

	self:destroy_ingame_ui()
	self:create_ingame_ui(self._ingame_ui_context)

	if current_transition then

		self._ingame_ui:handle_transition(current_transition, current_params)
	end
end

function UIManager:temporary_get_ingame_ui_called_from_state_ingame_running()
	return self._ingame_ui
end

function UIManager:set_ingame_ui_enabled(bool)
	if self._ui_enabled ~= bool then
		self._ui_enabled = bool
		if not bool then
			local ingame_ui = self._ingame_ui
			if ingame_ui then
				ingame_ui:suspend_active_view()
			end
		end
	end
end

function UIManager:update()
	if not self._ui_enabled then
		return
	end





	if not self._ui_update_initialized then
		self._ui_update_initialized = true
		return
	end

	local ingame_ui = self._ingame_ui
	if not ingame_ui then
		return
	end

	local t, dt = Managers.time:time_and_delta("ui")

	local disable_ingame_ui = ( script_data.disable_ui or DebugScreen.active ) and Managers.state.network:game_session_host() ~= nil

	local level_end_view_wrapper = self._level_end_view_wrapper
	local level_end_view = level_end_view_wrapper and level_end_view_wrapper:level_end_view()

	ingame_ui:update(dt, t, disable_ingame_ui, level_end_view)

	local loading_subtitle_gui = self._loading_subtitle_gui
	if loading_subtitle_gui then
		ingame_ui:update_loading_subtitle_gui(loading_subtitle_gui, dt)

		if loading_subtitle_gui:is_complete() then
			self._loading_subtitle_gui = nil
		end
	end

	if ingame_ui:end_screen_active() and ingame_ui:end_screen_completed() then
		Managers.state.event:trigger("end_screen_ui_complete")
	end
end

function UIManager:end_screen_active()
	return self._ingame_ui:end_screen_active()
end

function UIManager:end_screen_completed()
	return self._ingame_ui:end_screen_completed()
end

function UIManager:post_update(dt, t, disable_ingame_ui)







	local ingame_ui = self._ingame_ui
	if ingame_ui then
		ingame_ui:post_update(dt, t, disable_ingame_ui)
	end

end

function UIManager:post_render()
	local ingame_ui = self._ingame_ui
	if ingame_ui then
		ingame_ui:post_render()
	end
end

function UIManager:get_transition()
	local ingame_ui = self._ingame_ui
	if ingame_ui then
		return ingame_ui:get_transition()
	end
end




function UIManager:restart_game()
	local ingame_ui = self._ingame_ui
	ingame_ui.restart_game = true
end

function UIManager:is_in_view_state(state_name)
	local ingame_ui = self._ingame_ui
	if ingame_ui then
		return ingame_ui:is_in_view_state(state_name)
	end
end

function UIManager:get_hud_component(component_name)
	local ingame_ui = self._ingame_ui
	return ingame_ui:get_hud_component(component_name)
end

function UIManager:open_popup(popup_name, ...)
	local ingame_ui = self._ingame_ui
	return ingame_ui:open_popup(popup_name, ...)
end

function UIManager:close_popup(popup_name)
	local ingame_ui = self._ingame_ui
	return ingame_ui:close_popup(popup_name)
end

function UIManager:get_active_popup(popup_name)
	local ingame_ui = self._ingame_ui
	if ingame_ui then
		return ingame_ui:get_active_popup(popup_name)
	end
end

function UIManager:handle_new_ui_disclaimer(disclaimer_states, state)
	local gamepad_active = Managers.input:is_device_active("gamepad")
	if gamepad_active or IS_CONSOLE then
		return
	end

	local use_gamepad_layout = Application.user_setting("use_gamepad_menu_layout")
	local use_pc_menu_layout = Application.user_setting("use_pc_menu_layout")
	if use_gamepad_layout == false and use_pc_menu_layout == false and (disclaimer_states [state] or disclaimer_states [state] == nil) then
		local ingame_ui = self._ingame_ui
		ingame_ui.weave_onboarding:try_show_tutorial(WeaveUITutorials.new_ui_disclaimer)

		Application.set_user_setting("use_gamepad_menu_layout", nil)
		Application.save_user_settings()
	end
end




function UIManager:handle_transition(new_transition, params)
	fassert(params, "params are a required argument")

	local ingame_ui = self._ingame_ui
	if ingame_ui then
		if params.use_fade then
			return ingame_ui:transition_with_fade(new_transition, params, params.fade_in_speed, params.fade_out_speed)
		else
			return ingame_ui:handle_transition(new_transition, params)
		end
	end



end