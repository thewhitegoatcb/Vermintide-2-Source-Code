require("scripts/managers/account/presence/script_presence_xb1")
require("scripts/managers/account/leaderboards/script_leaderboards_xb1")
require("scripts/managers/account/script_connected_storage_token")
require("scripts/managers/account/script_user_profile_token")
require("scripts/managers/account/smartmatch_cleaner")
require("scripts/network/xbox_user_privileges")
require("scripts/managers/account/qos/script_qos_token")
require("scripts/managers/account/xbox_marketplace/script_xbox_marketplace")

AccountManager = class(AccountManager)

AccountManager.VERSION = "xb1"

AccountManager.SIGNED_OUT = 4294967295.0
AccountManager.QUERY_BANDWIDTH_TIMER = 60
AccountManager.QUERY_BANDWIDTH_FAIL_TIMER = 10
AccountManager.QUERY_FAIL_AMOUNT = 5

local function dprint(...)
	print("[AccountManager] ", ...)
end

local CONSOLE_TYPE_SETTINGS = {
	[XboxOne.CONSOLE_TYPE_UNKNOWN] = { allow_dismemberment = false, console_type_name = "Unknown", should_throttle = true },




	[XboxOne.CONSOLE_TYPE_XBOX_ONE] = { allow_dismemberment = false, console_type_name = "Xbox One", should_throttle = true },




	[XboxOne.CONSOLE_TYPE_XBOX_ONE_S] = { allow_dismemberment = false, console_type_name = "Xbox One S", should_throttle = true },




	[XboxOne.CONSOLE_TYPE_XBOX_ONE_X] = { allow_dismemberment = false, console_type_name = "Xbox One X", should_throttle = true },




	[XboxOne.CONSOLE_TYPE_XBOX_ONE_X_DEVKIT] = { allow_dismemberment = false, console_type_name = "Xbox One X Devkit", should_throttle = true },




	[XboxOne.CONSOLE_TYPE_XBOX_LOCKHART] = { allow_dismemberment = true, console_type_name = "Xbox Series S", should_throttle = false },




	[XboxOne.CONSOLE_TYPE_XBOX_ANACONDA] = { allow_dismemberment = true, console_type_name = "Xbox Series X", should_throttle = false },




	[XboxOne.CONSOLE_TYPE_XBOX_SERIES_X_DEVKIT] = { allow_dismemberment = true, console_type_name = "Xbox Series X Devkit", should_throttle = false } }






function AccountManager:init()
	self._user_id = nil
	self._controller_id = nil
	self._achievements = nil
	self._initiated = false
	self._offline_mode = nil
	self._xsts_token = nil
	self._lobbies_to_free = { }
	self._gamertags = { }
	self._smartmatch_cleaner = SmartMatchCleaner:new()
	self._xbox_privileges = XboxUserPrivileges:new()
	self._xbox_marketplace = ScriptXboxMarketplace:new()
	self._presence = ScriptPresence:new()
	self._leaderboards = ScriptLeaderboards:new()
	self._query_bandwidth_timer = AccountManager.QUERY_BANDWIDTH_TIMER
	self._bandwidth_query_fails = 0
	self._unlocked_achievements = { }
	self._offline_achievement_progress = { }
	self._social_graph_callbacks = { }

	local region_info = XboxLive.region_info()
	self._country_code = string.lower(region_info.GEO_ISO2)
end

function AccountManager:set_achievement_unlocked(template_id)
	self._unlocked_achievements [template_id] = true
end

function AccountManager:get_unlocked_achievement_list()
	return self._unlocked_achievements
end

function AccountManager:set_offline_achievement_progress(template_id, progress)
	self._offline_achievement_progress [template_id] = progress
end

function AccountManager:offline_achievement_progress(template_id)
	return self._offline_achievement_progress [template_id]
end

function AccountManager:_set_user_id(id, controller)
	self._user_id = id
	self._user_info = XboxLive.user_info(id)
	self._player_session_id = Application.guid()
	self._active_controller = controller
	self._controller_id = controller.controller_id()
	self._backend_user_id = Application.make_hash(self:xbox_user_id())
	Application.warning(string.format("[AccountManager] Console Backend User id: %s", self._backend_user_id))

	self._suspend_callback_id = XboxCallbacks.register_suspending_callback(callback(self, "cb_is_suspending"))
end

function AccountManager:cb_is_suspending(...)
	print("############################ SUSPENDING")
	self._has_suspended = true
	if Managers.state.event then
		Managers.state.event:trigger("trigger_xbox_round_end")
	end

	if Managers.xbox_events then
		Managers.xbox_events:flush()
	end

	if Managers.xbox_stats then
		Managers.xbox_stats:flush()
	end
end

function AccountManager:set_presence(presence)
	self._presence:set_presence(presence)
end

function AccountManager:set_leaderboard(level_id, time_in_seconds)
	if self._user_id then
		self._leaderboards:set_leaderboard(self._user_info.xbox_user_id, self._player_session_id, level_id, time_in_seconds)
	end
end

function AccountManager:get_leaderboard(level_id, leaderboard_type, in_callback, max_items, skip_to_rank)
	if self._user_id then
		self._leaderboards:get_leaderboard(self._user_id, level_id, leaderboard_type, in_callback, max_items, skip_to_rank)
	end
end

function AccountManager:set_round_id(round_id)
	self._current_round_id = round_id or Application.guid()
end

function AccountManager:round_id()
	return self._current_round_id
end

function AccountManager:my_gamertag()
	local xuid = self._user_info.xbox_user_id
	return self._gamertags [xuid]
end

function AccountManager:gamertag_from_xuid(xuid)
	return self._gamertags [xuid]
end

function AccountManager:has_privilege(privilege)
	if self._user_id then
		return self._xbox_privileges:has_privilege(self._user_id, privilege)
	else
		return false
	end
end

function AccountManager:is_privileges_initialized()
	return self._xbox_privileges:is_initialized()
end

function AccountManager:has_privilege_error()
	self._xbox_privileges:has_error()
end

function AccountManager:get_privilege_async(privilege, attempt_resolution, external_cb)
	self._xbox_privileges:get_privilege_async(self._user_id, privilege, attempt_resolution, external_cb)
end

function AccountManager:active_controller(user_id)
	return self._active_controller
end

function AccountManager:is_controller_disconnected()
	return self._popup_id
end

function AccountManager:user_detached()
	return self._user_detached
end

function AccountManager:xbox_user_id()
	return self._user_info.xbox_user_id
end

function AccountManager:account_id()
	return self._user_info.xbox_user_id
end

function AccountManager:backend_user_id()
	return self._backend_user_id
end

function AccountManager:player_session_id()
	return self._player_session_id
end

function AccountManager:user_id()
	return self._user_id
end

function AccountManager:storage_id()
	return self._storage_id
end

function AccountManager:is_guest()
	return self._user_info and self._user_info.guest
end

function AccountManager:is_online()
	return not self._offline_mode and XboxLive.online_state() == XboxOne.ONLINE
end

function AccountManager:offline_mode()
	return self._offline_mode
end

function AccountManager:set_offline_mode(offline_mode)
	self._offline_mode = offline_mode
end

function AccountManager:update(dt)
	if self._initiated then
		local user_id = self._user_id

		if self._storage_token then
			self:_handle_storage_token()

		elseif
		user_id and not self:leaving_game() then
			self:_check_session()
			self:_verify_user_integrity()
			self:_verify_user_profile(dt)
			self:_verify_privileges()
			self:_verify_user_in_cache()
			self:_update_bandwidth_query(dt)
			self:_update_social_manager(dt)


			self._presence:update(dt)



			self._xbox_marketplace:update(dt)
		end
	end




	self:_check_trigger_popups()

	self:_process_popup_handle("_popup_id")
	self:_process_popup_handle("_signout_popup_id")
	self:_process_popup_handle("_privilege_popup_id")
	self:_process_popup_handle("_xbox_live_connection_lost_popup_id")
	self:_process_popup_handle("_not_connected_to_xbox_live_popup_id")

	self:_update_sessions(dt)

	self._user_cache_changed = XboxLive.user_cache_changed()
end

function AccountManager:has_popup()
	return self._popup_id or self._signout_popup_id or self._privilege_popup_id or self._xbox_live_connection_lost_popup_id or self._not_connected_to_xbox_live_popup_id
end

function AccountManager:cancel_all_popups()
	self._popup_id = nil
	self._signout_popup_id = nil
	self._privilege_popup_id = nil
	self._xbox_live_connection_lost_popup_id = nil
	self._not_connected_to_xbox_live_popup_id = nil
end

function AccountManager:_check_trigger_popups()
	if not self._retrigger_popups_check then
		return
	end

	if self._popup_id and not Managers.popup:has_popup_with_id(self._popup_id) then
		self._popup_id = nil
		local wanted_profile_id = self._user_info.xbox_user_id
		local wanted_profile = self._gamertags [wanted_profile_id]
		local cropped_profile = wanted_profile and Managers.popup:fit_text_width_to_popup(wanted_profile) or "?"
		local wrong_profile_str = string.format(Localize("controller_pairing"), cropped_profile)

		self:_create_popup(wrong_profile_str, "controller_pairing_header", "verify_profile", "menu_retry", "restart_network", "menu_return_to_title_screen", "show_profile_picker", "menu_select_profile", true)
	end

	if self._privilege_popup_id and not Managers.popup:has_popup_with_id(self._privilege_popup_id) then
		self._privilege_popup_id = Managers.popup:queue_popup(Localize("popup_xbox_live_gold_error"), Localize("popup_xbox_live_gold_error_header"), "restart_network", Localize("menu_ok"))
	end

	if self._xbox_live_connection_lost_popup_id and not Managers.popup:has_popup_with_id(self._xbox_live_connection_lost_popup_id) then
		self._xbox_live_connection_lost_popup_id = Managers.popup:queue_popup(Localize("xboxlive_connection_lost"), Localize("xboxlive_connection_lost_header"), "restart_network", Localize("menu_restart"))
	end

	if self._not_connected_to_xbox_live_popup_id and not Managers.popup:has_popup_with_id(self._not_connected_to_xbox_live_popup_id) then
		self._not_connected_to_xbox_live_popup_id = Managers.popup:queue_popup(Localize("failure_start_xbox_lobby_create"), Localize("xboxlive_connection_lost_header"), "acknowledged", Localize("menu_ok"))
	end

	self._retrigger_popups_check = false
end

function AccountManager:check_popup_retrigger()
	self._retrigger_popups_check = true
end

function AccountManager:_process_popup_handle(popup_id_handle)
	local popup_id = self [popup_id_handle]
	if not popup_id then
		return
	end

	local result = Managers.popup:query_result(popup_id)
	if result then
		self [popup_id_handle] = nil
		self:_handle_popup_result(result)
	end
end

function AccountManager:setup_friendslist()
	if rawget(_G, "LobbyInternal") and LobbyInternal.client then

		local events = { Social.last_social_events() }
		table.dump(events, nil, 2)
		if ( table.contains(events, SocialEventType.RTA_DISCONNECT_ERR) or not self._added_local_user_to_graph ) and not self._user_detached then

			local user_id = self._user_id
			if Social.add_local_user_to_graph(user_id) then
				self.title_online_friends_group_id = Social.create_filtered_social_group(user_id, SocialPresenceFilter.TITLE_ONLINE, SocialRelationshipFilter.FRIENDS)
				self.online_friends_group_id = Social.create_filtered_social_group(user_id, SocialPresenceFilter.ALL_ONLINE, SocialRelationshipFilter.FRIENDS)
				self.offline_friends_group_id = Social.create_filtered_social_group(user_id, SocialPresenceFilter.ALL_OFFLINE, SocialRelationshipFilter.FRIENDS)

				self._added_local_user_to_graph = true
			end


			return true
		end
	end
end

function AccountManager:_update_social_manager(dt, t)
	if self._added_local_user_to_graph then
		local events = { Social.last_social_events() }
		if table.contains(events, SocialEventType.GRAPH_LOADED) then
			self._social_graph_loaded = true
			for _, social_callback in pairs(self._social_graph_callbacks) do
				self:get_friends(1000, social_callback)
			end
		end

		if table.contains(events, SocialEventType.PRESENCE_CHANGED) then --[[ Nothing --]]
		end
	end

end

function AccountManager:friends_list_initiated()
	return self._added_local_user_to_graph
end

function AccountManager:user_cache_changed()
	return self._user_cache_changed
end

function AccountManager:_update_sessions(dt)
	if Network.xboxlive_client_exists() then
		if #self._lobbies_to_free > 0 then
			self:_update_lobbies_to_free()
		end

		self._smartmatch_cleaner:update(dt)
	else
		self._smartmatch_cleaner:reset()
	end

	if self:all_lobbies_freed() and self._teardown_xboxlive then
		Application.warning("SHUTTING DOWN XBOX LIVE CLIENT")
		if Managers.voice_chat then
			Managers.voice_chat:destroy()
			Managers.voice_chat = nil
		end

		if Network.xboxlive_client_exists() then
			LobbyInternal.shutdown_xboxlive_client()
		end

		self._smartmatch_cleaner:reset()
		self:reset()
		self._added_local_user_to_graph = nil
	end
end

LOBBIES_TO_REMOVE = LOBBIES_TO_REMOVE or { }

function AccountManager:_update_lobbies_to_free()
	for i = #self._lobbies_to_free, 1, -1 do
		local lobby = self._lobbies_to_free [i]
		local state = lobby:state()
		if state == MultiplayerSession.SHUTDOWN then
			print("Freed a lobby")
			lobby:free()
			LOBBIES_TO_REMOVE [#LOBBIES_TO_REMOVE + 1] = i
		end
	end

	if #LOBBIES_TO_REMOVE > 0 then
		for _, index in ipairs(LOBBIES_TO_REMOVE) do
			print("Removed a lobby")
			table.remove(self._lobbies_to_free, index)
		end

		LOBBIES_TO_REMOVE = { }
	end
end

function AccountManager:_verify_user_integrity()
	if self._offline_mode == nil or self._offline_mode or self._signout_popup_id then
		return
	end

	if not self:user_exists(self._user_id) then
		self._signout_popup_id = Managers.popup:queue_popup(Localize("profile_signed_out_header"), Localize("popup_xboxlive_profile_acquire_error_header"), "restart_network", Localize("menu_return_to_title_screen"))
	end
end

local KEYBOARD_DEVICES = { xb1_mouse = true, xb1_keyboard = true }




function AccountManager:_verify_user_profile()






	if self._popup_id or self._signout_popup_id then
		return
	end

	local most_recent_device = Managers.input:get_most_recent_device()
	local current_device_type = most_recent_device.type()
	local using_keyboard = KEYBOARD_DEVICES [current_device_type] or false

	local active_controller = self._active_controller
	local controller_changed = false
	if active_controller and not using_keyboard then
		local controller_id = active_controller.controller_id()
		controller_changed = controller_id ~= self._controller_id
	end

	local user_id = active_controller and (not using_keyboard and active_controller.user_id() or self._user_id)
	local user_info = user_id and self:_user_id_in_cache(user_id) and XboxLive.user_info(user_id)
	local controller_disconnected = not using_keyboard and active_controller.disconnected() or false
	local controller_user_id = not using_keyboard and active_controller.user_id() or self._user_id
	if not active_controller or not controller_user_id or controller_disconnected or not user_info or self._user_info.xbox_user_id ~= user_info.xbox_user_id or not user_info.signed_in or controller_changed then
		local wanted_profile_id = self._user_info.xbox_user_id
		local wanted_profile = self._gamertags [wanted_profile_id]
		local cropped_profile = wanted_profile and Managers.popup:fit_text_width_to_popup(wanted_profile) or "?"
		local wrong_profile_str = string.format(Localize("controller_pairing"), cropped_profile)

		if Managers.matchmaking then --[[ Nothing --]]
		end


		self:_verify_user_in_cache()
		self:_create_popup(wrong_profile_str, "controller_pairing_header", "verify_profile", "menu_retry", "restart_network", "menu_return_to_title_screen", "show_profile_picker", "menu_select_profile", true)
	end
end

function AccountManager:_verify_privileges()
	if not XboxLive.user_info_changed() or self._privilege_popup_id or self:offline_mode() then
		return
	end

	if self:has_privilege(UserPrivilege.MULTIPLAYER_SESSIONS) then
		self._xbox_privileges:update_privilege("MULTIPLAYER_SESSIONS", callback(self, "cb_privileges_updated"))
	end
end

function AccountManager:_user_id_in_cache(user_id)
	local users = { XboxLive.users() }
	for _, user in pairs(users) do
		if user.id == user_id then
			return true
		end
	end

	return false
end

function AccountManager:_verify_user_in_cache()
	local users = { XboxLive.users() }
	for _, user in pairs(users) do
		if user.id == self._user_id then
			self._user_detached = false
			return
		end
	end

	self._user_detached = true
end

function AccountManager:user_exists(user_id)
	local users = { XboxLive.users() }
	for _, user in pairs(users) do
		if user.id == user_id then
			return true
		end
	end

	return false
end

function AccountManager:_update_bandwidth_query(dt)
	if GameSettingsDevelopment.bandwidth_queries_enabled then
		if self._query_bandwidth_timer <= 0 then
			self:query_bandwidth()
		end

		self._query_bandwidth_timer = self._query_bandwidth_timer - dt
	end
end

function AccountManager:cb_privileges_updated(privilege)
	if not self:has_privilege(UserPrivilege.MULTIPLAYER_SESSIONS) then
		self._privilege_popup_id = Managers.popup:queue_popup(Localize("popup_xbox_live_gold_error"), Localize("popup_xbox_live_gold_error_header"), "restart_network", Localize("menu_ok"))
	end
end

function AccountManager:_check_session()
	if Network.fatal_error() and not self._fatal_error and (not Managers.invite or not Managers.invite:has_invitation()) and (not Managers.matchmaking or not Managers.matchmaking:is_joining_friend()) and not self:leaving_game() then
		self._xbox_live_connection_lost_popup_id = Managers.popup:queue_popup(Localize("xboxlive_connection_lost"), Localize("xboxlive_connection_lost_header"), "restart_network", Localize("menu_restart"))
		self._fatal_error = true
	end
end

function AccountManager:has_fatal_error()
	return self._fatal_error or Network.fatal_error()
end

function AccountManager:_create_popup(error, header, right_action, right_button, left_action, left_button, extra_action, extra_button, disable_localize_error)
	Managers.input:set_all_gamepads_available()

	assert(error, "[AccountManager] No error was passed to popup handler")
	local header = header or "popup_error_topic"
	local right_action = right_action
	local left_action = left_action
	local extra_action = extra_action
	local right_button = right_button and Localize(right_button)
	local left_button = left_button and Localize(left_button)
	local extra_button = extra_button and Localize(extra_button)
	local localized_error = disable_localize_error and error or Localize(error)
	assert(self._popup_id == nil, "Tried to show popup even though we already had one.")

	print(error, header, right_action, right_button, left_action, left_button, extra_action, extra_button, disable_localize_error)
	if extra_action and extra_button then
		self._popup_id = Managers.popup:queue_popup(localized_error, Localize(header), right_action, right_button, left_action, left_button, extra_action, extra_button)
	elseif left_action and left_button then
		self._popup_id = Managers.popup:queue_popup(localized_error, Localize(header), right_action, right_button, left_action, left_button)
	else
		self._popup_id = Managers.popup:queue_popup(localized_error, Localize(header), right_action, right_button)
	end
end

local function show_wrong_profile_popup(account_manager)
	local wanted_profile_id = account_manager._user_info.xbox_user_id
	local wanted_profile = account_manager._gamertags [wanted_profile_id]
	local cropped_profile = Managers.popup:fit_text_width_to_popup(wanted_profile)
	local wrong_profile_str = string.format(Localize("wrong_profile"), cropped_profile)
	account_manager:_create_popup(wrong_profile_str, "wrong_profile_header", "verify_profile", "menu_retry", "restart_network", "menu_return_to_title_screen", "show_profile_picker", "menu_select_profile", true)
end

function AccountManager:force_exit_to_title_screen()
	self._should_teardown_xboxlive = true
	self:initiate_leave_game()
end

function AccountManager:_handle_popup_result(result)
	if result == "verify_profile" then
		self:verify_profile()
	elseif result == "acknowledged" then --[[ Nothing --]]

	elseif result == "restart_network" then
		self._should_teardown_xboxlive = true
		self:initiate_leave_game()
	elseif result == "show_profile_picker" then
		local controller = Managers.input:get_most_recent_device()
		local index = tonumber(string.gsub(controller._name, "Pad", ""), 10)
		XboxLive.show_account_picker(index)
		local error, device_id, user_id_old, user_id_new = XboxLive.show_account_picker_result()
		local invalid_profile_id = 4294967295.0
		if error or user_id_new == invalid_profile_id then
			show_wrong_profile_popup(self)
			return
		end

		self._active_controller = controller
		self._controller_id = self._active_controller.controller_id()
		Managers.input:set_exclusive_gamepad(self._active_controller)
		if Managers.voice_chat then
			Managers.voice_chat:add_local_user()
		end
		self:_verify_user_in_cache()
	else
		fassert(false, "[AccountManager] The popup result doesn't exist (%s)", result)
	end
end

function AccountManager:restarting()
	return self._restarting
end

function AccountManager:should_teardown_xboxlive()
	return self._should_teardown_xboxlive
end

function AccountManager:set_should_teardown_xboxlive()
	self._should_teardown_xboxlive = true
end

function AccountManager:teardown_xboxlive()
	self._teardown_xboxlive = true
end

function AccountManager:update_popup_status()
	if not self._popup_id then
		return
	end

	if not Managers.popup:has_popup_with_id(self._popup_id) then
		self._popup_id = nil
	end
end

function AccountManager:verify_profile()
	if not self._initiated then
		return
	end

	local most_recent_device = Managers.input:get_most_recent_device()
	local user_id = most_recent_device.user_id and most_recent_device.user_id()
	if not user_id then
		show_wrong_profile_popup(self)
		return
	end

	local user_info = XboxLive.user_info(most_recent_device.user_id())
	if user_info.xbox_user_id == self._user_info.xbox_user_id then
		self._active_controller = most_recent_device
		self._controller_id = self._active_controller.controller_id()
		Managers.input:set_exclusive_gamepad(self._active_controller)
		if Managers.voice_chat then
			Managers.voice_chat:add_local_user()
		end
		self:_verify_user_in_cache()

		if Managers.matchmaking then --[[ Nothing --]]


		end else
		show_wrong_profile_popup(self)
	end
end

function AccountManager:cb_profile_signed_out()
	local most_recent_device = Managers.input:get_most_recent_device()
	local user_info = XboxLive.user_info(most_recent_device.user_id())
	if user_info.xbox_user_id == self._user_info.xbox_user_id then
		self._active_controller = most_recent_device
		self._controller_id = self._active_controller.controller_id()
		Managers.input:set_exclusive_gamepad(self._active_controller)
		if Managers.voice_chat then
			Managers.voice_chat:add_local_user()
		end
	else
		print(string.format("Wrong profile: Had user_id %s - wanted user_id %s", user_info.xbox_user_id, self._user_info.xbox_user_id))
	end
end

function AccountManager:sign_in(user_id, controller, auto_sign_in)
	if not user_id then
		local controller_index = self:_controller_index(controller)
		if controller_index then
			XboxLive.show_account_picker(controller_index)
			do return false end
		end
	else
		self:_hard_sign_in(user_id, controller, auto_sign_in)
	end

	return true
end

function AccountManager:_controller_index(controller)
	if controller then
		local name = controller.name()
		if string.find(name, "Xbox Controller ") then
			return tonumber(string.gsub(controller.name(), "Xbox Controller ", ""), 10) + 1
		end
	end
end

function AccountManager:_hard_sign_in(user_id, controller, auto_sign_in)
	dprint("Hard-sign in", user_id)
	Crashify.print_property("xb1_user_id", user_id)
	self:_set_user_id(user_id, controller)
	self:_unmap_other_controllers()
	self:_on_user_signed_in()


end

function AccountManager:set_xsts_token(xsts_token)
	self._xsts_token = xsts_token
end

function AccountManager:get_xsts_token()
	return self._xsts_token
end

function AccountManager:_unmap_other_controllers()
	Managers.input:set_exclusive_gamepad(self._active_controller)
end

function AccountManager:_on_user_signed_in()
	local user_id = self._user_id

	self._xbox_privileges:reset()
	self._xbox_privileges:add_user(user_id)

	self._initiated = true
end

function AccountManager:get_user_profiles(user_id, xbox_user_ids, cb)
	if XboxLive.online_state() == XboxOne.ONLINE then
		local token = Xbone.get_user_profiles(user_id, xbox_user_ids, #xbox_user_ids)
		local user_profile_token = ScriptUserProfileToken:new(token)
		Managers.token:register_token(user_profile_token, callback(self, "cb_user_profiles"))

		self._my_user_profile_cb = cb
	else
		local user_info = self._user_info
		local xuid = user_info.xbox_user_id
		self._gamertags [xuid] = user_info.gamertag
		cb({ })
	end
end

function AccountManager:cb_user_profiles(data)
	if not data.error then
		for xuid, gamertag in pairs(data.user_profiles) do
			self._gamertags [xuid] = gamertag
			Crashify.print_property("xb1_xuid", xuid)
			Crashify.print_property("xb1_gamertag", gamertag)
		end
	end
	self._my_user_profile_cb(data)
	self._my_user_profile_cb = nil
end

function AccountManager:_handle_storage_token()
	self._storage_token:update()
	if self._storage_token:done() then
		local info = self._storage_token:info()
		self:_storage_acquired(info)
		self._storage_token = nil
	end
end

function AccountManager:get_storage_space(done_callback)
	if not self._storage_id then
		local token = XboxConnectedStorage.get_storage_space(self._user_id)
		self._storage_token = ScriptConnectedStorageToken:new(XboxConnectedStorage, token)
		self._get_storage_done_callback = done_callback
	else
		done_callback({ })
	end
end

function AccountManager:_storage_acquired(data)
	if data.error then
		Application.error("[AccountManager] There was an error in the get_storage_space operation: " .. data.error)
		self:close_storage()
	else
		self._storage_id = data.storage_id
	end
	self._get_storage_done_callback(data)
	self._get_storage_done_callback = nil
end

function AccountManager:add_session_to_cleanup(session_data)





	self._smartmatch_cleaner:add_session(session_data)
end

function AccountManager:add_lobby_to_free(lobby)
	self._lobbies_to_free [#self._lobbies_to_free + 1] = lobby
end

function AccountManager:all_lobbies_freed()
	return #self._lobbies_to_free == 0 and self._smartmatch_cleaner:ready()
end

function AccountManager:initiate_leave_game()
	self._leave_game = true
	if self:is_online() then
		Presence.set(self._user_id, "")
	end
end

function AccountManager:leaving_game()
	return self._leave_game
end

function AccountManager:reset()
	if Network.xboxlive_client_exists() and self._user_id and self._added_local_user_to_graph then
		Social.remove_local_user_from_graph(self._user_id)
	end

	self._added_local_user_to_graph = nil
	self._social_graph_loaded = nil
	self._user_id = nil
	self._presence = ScriptPresence:new()
	self._user_info = nil
	self._offline_mode = nil
	self._player_session_id = nil
	self._active_controller = nil
	self._leave_game = nil
	self._initiated = false
	self._storage_id = nil
	self._fatal_error = nil
	self._teardown_xboxlive = nil
	self._should_teardown_xboxlive = nil
	self._backend_user_id = nil
	self._user_detached = nil
	self._signout_popup_id = nil
	self._popup_id = nil
	self._xbox_live_connection_lost_popup_id = nil
	self._not_connected_to_xbox_live_popup_id = nil
	self._privilege_popup_id = nil
	self._controller_id = nil
	self._xsts_token = nil
	self._bandwidth_query_fails = 0
	self._query_bandwidth_timer = AccountManager.QUERY_BANDWIDTH_TIMER
	self._unlocked_achievements = { }
	self._offline_achievement_progress = { }
	self._social_graph_callbacks = { }

	if Managers.popup then
		Managers.popup:cancel_all_popups()
	end

	if self._suspend_callback_id then
		XboxCallbacks.unregister_callback(self._suspend_callback_id)
		self._suspend_callback_id = nil
	end
end

function AccountManager:destroy()
	self:close_storage()
	self._presence:destroy()
	self._xbox_marketplace:destroy()

	if Network.xboxlive_client_exists() then
		Network.clean_sessions()
	end
end

function AccountManager:close_storage()
	print("closing storage")
	if self._storage_id then
		XboxConnectedStorage.finish(self._storage_id)
		print("Storage Closed")
	else
		print("Storage Not Open")
	end

	self._storage_id = nil
	self._storage_token = nil
end

function AccountManager:set_controller_disconnected(disconnected)
	self._controller_disconnected = disconnected
end

function AccountManager:controller_disconnected()
	return self._controller_disconnected
end

local friend_data = { }

function AccountManager:get_friends(friends_list_limit, callback)
	table.clear(friend_data)

	if self._added_local_user_to_graph and self._social_graph_loaded then
		local title_online_friends = { Social.social_group(self.title_online_friends_group_id) }
		local num_title_online_friends = #title_online_friends
		local online_friends = { Social.social_group(self.online_friends_group_id) }
		local num_online_friends = #online_friends
		local offline_friends = { Social.social_group(self.offline_friends_group_id) }
		local num_offline_friends = #offline_friends

		for i = 1, num_title_online_friends do
			local data = title_online_friends [i]
			local id = data.xbox_user_id


			data.name = data.display_name
			data.status = "online"
			data.playing_this_game = true

			friend_data [id] = data
		end

		for i = 1, num_online_friends do
			local data = online_friends [i]
			local id = data.xbox_user_id

			if not friend_data [id] then
				data.name = data.display_name
				data.status = "online"
				data.playing_this_game = false

				friend_data [id] = data
			end
		end

		for i = 1, num_offline_friends do
			local data = offline_friends [i]
			local id = data.xbox_user_id

			data.name = data.display_name
			data.status = "offline"
			data.playing_this_game = false

			friend_data [id] = data
		end
	else
		self._social_graph_callbacks [#self._social_graph_callbacks + 1] = callback
	end

	callback(friend_data)
end

function AccountManager:send_session_invitation(id, lobby)
	local friends_to_invite = { id }
	lobby:invite_friends_list(friends_to_invite)
end

function AccountManager:set_current_lobby(lobby) return end


function AccountManager:reset_bandwidth_query()
	self._bandwidth_query_fails = 0
	self._query_bandwidth_timer = AccountManager.QUERY_BANDWIDTH_TIMER
end

function AccountManager:query_bandwidth(down_kbps, up_kbps, timeout_in_ms)
	if self._querying_bandwidth or not Network.xboxlive_client_exists() or Managers.voice_chat and Managers.voice_chat:bandwidth_disabled() or not GameSettingsDevelopment.bandwidth_queries_enabled then
		return
	end

	local token = QoS.query_bandwidth(down_kbps or 192, up_kbps or 192, timeout_in_ms or 5000)
	if token then
		local script_token = ScriptQoSToken:new(token)
		Managers.token:register_token(script_token, callback(self, "cb_bandwidth_query"))
		self._querying_bandwidth = true
	else
		Application.warning("[AccountManager:query_bandwidth] QUERY FAILED TO INITIALIZE")
		self._querying_bandwidth = nil
		self._bandwidth_query_fails = 0
		self._query_bandwidth_timer = AccountManager.QUERY_BANDWIDTH_TIMER
	end
end

function AccountManager:cb_bandwidth_query(data)
	if data.error then
		Application.warning("[AccountManager:query_bandwidth] FAILED! reason: " .. data.error)
		self._bandwidth_query_fails = self._bandwidth_query_fails + 1
		self._query_bandwidth_timer = AccountManager.QUERY_BANDWIDTH_FAIL_TIMER

		if AccountManager.QUERY_FAIL_AMOUNT <= self._bandwidth_query_fails then
			if Managers.voice_chat and not Managers.voice_chat:bandwidth_disabled() then
				Managers.voice_chat:bandwitdth_disable_voip()
			end

			self._bandwidth_query_fails = 0
			self._query_bandwidth_timer = AccountManager.QUERY_BANDWIDTH_TIMER
		end
	else
		Application.warning("[AccountManager:query_bandwidth] : SUCCESS!")
		self._bandwidth_query_fails = 0
		self._query_bandwidth_timer = AccountManager.QUERY_BANDWIDTH_TIMER
	end

	self._querying_bandwidth = nil
end

function AccountManager:show_player_profile(id)
	if not self._user_detached then
		XboxLive.show_gamercard(self._user_id, id)
	end
end

function AccountManager:get_product_details(product_ids, response_callback)
	if not self._user_id or self._offline_mode or self._user_detached then
		response_callback({ error = "Can't fetch marketplace information while being offline" })
		return
	end

	self._xbox_marketplace:get_product_details(self._user_id, product_ids, response_callback)
end

function AccountManager:console_type()
	local console_type = XboxOne.console_type()
	local console_settings = CONSOLE_TYPE_SETTINGS [console_type] or CONSOLE_TYPE_SETTINGS [XboxOne.CONSOLE_TYPE_UNKNOWN]

	return console_settings.console_type_name
end

function AccountManager:should_throttle()
	local console_type = XboxOne.console_type()
	local console_settings = CONSOLE_TYPE_SETTINGS [console_type] or CONSOLE_TYPE_SETTINGS [XboxOne.CONSOLE_TYPE_UNKNOWN]

	return console_settings.should_throttle
end

function AccountManager:console_type_setting(setting)
	local console_type = XboxOne.console_type()
	local console_settings = CONSOLE_TYPE_SETTINGS [console_type] or CONSOLE_TYPE_SETTINGS [XboxOne.CONSOLE_TYPE_UNKNOWN]
	return console_settings [setting]
end

function AccountManager:has_session() return true end

function AccountManager:region()
	return self._country_code
end

function AccountManager:update_presence() return end