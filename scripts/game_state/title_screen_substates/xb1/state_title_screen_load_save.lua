StateTitleScreenLoadSave = class(StateTitleScreenLoadSave)
StateTitleScreenLoadSave.NAME = "StateTitleScreenLoadSave"

function StateTitleScreenLoadSave:on_enter(params)

	print("[Gamestate] Enter Substate StateTitleScreenLoadSave")

	self._params = params
	self._world = params.world
	self._viewport = params.viewport
	self._title_start_ui = params.ui

	self._state = "get_user_profile"

	self._network_event_meta_table = {
		__index = function (event_table, event_key)
			return function ()
				Application.warning("Got RPC %s during forced network update when exiting StateTitleScreenMain", event_key)
			end
		end }

	Managers.transition:show_loading_icon(false)

	if not Managers.account:user_id() then
		self:_close_menu()
	end

	self:_setup_input()
end

function StateTitleScreenLoadSave:_setup_input()
	local input_manager = Managers.input
	self.input_manager = input_manager
end

function StateTitleScreenLoadSave:update(dt, t)
	local title_start_ui = self._title_start_ui
	title_start_ui:update(dt, t)
	self:_update_network(dt, t)

	if not Managers.account:user_detached() then
		if self._state == "get_user_profile" then
			self:_get_user_profile()
			title_start_ui:set_information_text(Localize("loading_acquiring_user_profile"))
		elseif self._state == "check_guest" then
			self:_check_guest()
		elseif self._state == "enumerate_dlc" then
			title_start_ui:set_information_text(Localize("loading_checking_downloadable_content"))
			self:_enumerate_dlc()
		elseif self._state == "acquire_storage" then
			self:_get_storage_space()
			title_start_ui:set_information_text(Localize("loading_acquiring_storage"))
		elseif self._state == "query_storage_spaces" then
			self:_query_storage_spaces()
			title_start_ui:set_information_text(Localize("loading_checking_save_data"))
		elseif self._state == "load_save" then
			self:_load_save()
			title_start_ui:set_information_text(Localize("loading_loading_settings"))
		elseif self._state == "check_popup" then
			self:_check_popup()
		elseif self._state == "create_save" then
			self:_create_save()
		elseif self._state == "delete_save" then
			self:_delete_save()
			title_start_ui:set_information_text(Localize("loading_deleting_settings"))
		end
	elseif self._popup_id then
		self:_check_popup()
	end

	return self:_next_state()
end

function StateTitleScreenLoadSave:_update_network(dt, t)
	if rawget(_G, "LobbyInternal") and LobbyInternal.network_initialized() then
		Network.update(dt, setmetatable({ }, self._network_event_meta_table))
	end
end



function StateTitleScreenLoadSave:_check_guest()
	if Managers.account:is_guest() then
		self._popup_id = Managers.popup:queue_popup(Localize("popup_is_guest"), Localize("popup_is_guest_header"), "verified_guest", Localize("menu_ok"))
		self._state = "check_popup"
	else
		self._state = "enumerate_dlc"
	end
end

function StateTitleScreenLoadSave:_get_user_profile()
	self._state = "waiting_for_profile"
	local user_id = Managers.account:user_id()
	local xuid = Managers.account:xbox_user_id()
	Managers.account:get_user_profiles(user_id, { xuid }, callback(self, "cb_profile_acquired"))
end

function StateTitleScreenLoadSave:cb_profile_acquired(data)
	if data.error then
		self._popup_id = Managers.popup:queue_popup(Localize("popup_xboxlive_profile_acquire_error"), Localize("popup_xboxlive_profile_acquire_error_header"), "profile_error", Localize("menu_ok"))
		self._state = "check_popup"
	else
		self._title_start_ui:set_user_name(Managers.account:my_gamertag())
		self._state = "check_guest"
	end
end

function StateTitleScreenLoadSave:_enumerate_dlc()
	XboxDLC.initialize()
	XboxDLC.enumerate_dlc()
	self._state = "acquire_storage"
end

function StateTitleScreenLoadSave:_get_storage_space()
	self._state = "waiting_for_storage"
	Managers.account:get_storage_space(callback(self, "cb_storage_acquired"))
end

function StateTitleScreenLoadSave:cb_storage_acquired(data)
	if data.error then
		self._popup_id = Managers.popup:queue_popup(Localize("popup_storage_could_not_be_acquired"), Localize("popup_storage_could_not_be_acquired_header"), "storage_error", Localize("menu_ok"))
		self._state = "check_popup"
	else
		self._state = "query_storage_spaces"
	end
end

function StateTitleScreenLoadSave:_query_storage_spaces()
	self._state = "waiting_for_query"
	Managers.save:query_storage_spaces(callback(self, "cb_query_done"))
end

function StateTitleScreenLoadSave:cb_query_done(data)
	print("######################## QUERY ########################")
	if data.error then
		self._popup_id = Managers.popup:queue_popup(Localize("popup_query_storage_error"), Localize("popup_query_storage_error_header"), "query_storage_error", Localize("menu_ok"))
		self._state = "check_popup"
	elseif self:_save_data_contains(data, "save_container") then
		if StateTitleScreenLoadSave.DELETE_SAVE then
			self._state = "delete_save"
			StateTitleScreenLoadSave.DELETE_SAVE = false
		else
			self._state = "load_save"
		end
	else
		self._state = "create_save"
	end

	if not GameSettingsDevelopment.disable_intro_trailer and not script_data.skip_intro_trailer then
		self.parent.parent.loading_context.first_time = true
	end
end

function StateTitleScreenLoadSave:_save_data_contains(containers, name)
	for _, container in ipairs(containers) do
		if container.name == name and container.total_size > 0 then
			return true
		end
	end
end

function StateTitleScreenLoadSave:_load_save()
	self._state = "waiting_for_load"
	Managers.save:auto_load(SaveFileName, callback(self, "cb_load_done"))
end

function StateTitleScreenLoadSave:cb_load_done(data)
	print("######################## DATA LOADED ########################")
	if data.error then
		self._state = "check_popup"
		self._popup_id = Managers.popup:queue_popup(Localize("popup_load_error_consoles"), Localize("popup_load_error_header"), "retry_load", Localize("menu_reload"), "reset_save", Localize("menu_reset"))
	elseif Managers.account:is_guest() then
		SaveData = table.clone(DefaultSaveData)
		populate_save_data(SaveData)

		self._new_state = StateTitleScreenMainMenu
		self._state = "none"
	else
		populate_save_data(data)


		if data.machine_id == nil then
			self:_do_save()
		else
			self._new_state = StateTitleScreenMainMenu
			self._state = "none"
		end
	end
end

function StateTitleScreenLoadSave:_check_popup()
	local result = Managers.popup:query_result(self._popup_id)
	if result == "retry_load" then
		self._state = "load_save"
	elseif result == "reset_save" then
		self._state = "delete_save"
	elseif result == "profile_error" then
		self:_close_menu()
		self._state = "none"
	elseif result == "storage_error" then
		self:_close_menu()
		self._state = "none"
	elseif result == "query_storage_error" then
		self:_close_menu()
		Managers.account:close_storage()
		self._state = "none"
	elseif result == "save_error" then
		self:_close_menu()
		Managers.account:close_storage()
		self._state = "none"
	elseif result == "delete_save_error" then
		self:_close_menu()
		Managers.account:close_storage()
		self._state = "none"
	elseif result == "verified_guest" then
		self._state = "enumerate_dlc"
	elseif result then
		fassert(false, "[StateTitleScreenLoadSave] The popup result doesn't exist (%s)", result)
	end

	if result then
		self._popup_id = nil
	end
end

function StateTitleScreenLoadSave:_create_save()
	SaveData = table.clone(DefaultSaveData)
	self:_do_save()
end

function StateTitleScreenLoadSave:_do_save()

	ensure_user_id_in_save_data(SaveData)

	Managers.save:auto_save(SaveFileName, SaveData, callback(self, "cb_save_done"))

	self._state = "waiting_for_save"
end

function StateTitleScreenLoadSave:cb_save_done(data)
	print("######################## DATA SAVED ########################")
	if data.error then
		self._popup_id = Managers.popup:queue_popup(Localize("popup_save_failed"), Localize("popup_save_failed_header"), "save_error", Localize("menu_ok"))
		self._state = "check_popup"
	elseif Managers.account:is_guest() then
		SaveData = table.clone(DefaultSaveData)
		populate_save_data(SaveData)

		self._new_state = StateTitleScreenMainMenu
		self._state = "none"
	else
		populate_save_data(SaveData)

		self._new_state = StateTitleScreenMainMenu
		self._state = "none"
	end
end

function StateTitleScreenLoadSave:_delete_save()
	self._state = "waiting_for_delete"
	Managers.save:delete_save(SaveFileName, callback(self, "cb_delete_done"))
end

function StateTitleScreenLoadSave:cb_delete_done(data)
	print("######################## SAVE DELETED ########################")
	if data.error then
		self._popup_id = Managers.popup:queue_popup(Localize("popup_delete_save_failed"), Localize("popup_delete_save_failed_header"), "delete_save_error", Localize("menu_ok"))
		self._state = "check_popup"
	else
		self._state = "create_save"
	end
end

function StateTitleScreenLoadSave:_close_menu()
	self.parent:show_menu(false)
	self._title_start_ui:set_start_pressed(false)
	self._new_state = StateTitleScreenMain
	self._state = "none"
	self._closing_menu = true
	Managers.transition:hide_loading_icon()
end

function StateTitleScreenLoadSave:_next_state()
	if not Managers.popup:has_popup() and not self._popup_id then
		if script_data.honduras_demo and
		not self._title_start_ui:is_ready() then
			return
		end


		return self._new_state
	end
end

function StateTitleScreenLoadSave:on_exit()
	self._title_start_ui:set_information_text("")
	self._popup_id = nil
end