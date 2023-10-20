require("scripts/managers/account/presence/presence_helper")

AccountManager = class(AccountManager)

AccountManager.VERSION = "win32"

local debug_friends_list = Development.parameter("debug_friends_list")

local function dprint(...)
	print("[AccountManager] ", ...)
end

function AccountManager:init()
	if HAS_STEAM then
		self._initial_user_id = Steam.user_id()
	end

	if DEDICATED_SERVER then
		self._country_code = string.lower(SteamGameServer.country_code())
	elseif HAS_STEAM then
		self._country_code = string.lower(Steam.user_country_code())
	end
end

function AccountManager:user_id()
	return self._initial_user_id
end

function AccountManager:update(dt)
	return end

function AccountManager:sign_in(user_id)
	Managers.state.event:trigger("account_user_signed_in")
end

function AccountManager:num_signed_in_users()
	return 1
end

function AccountManager:user_detached()
	return false
end

function AccountManager:acitve_controller() return end

function AccountManager:leaving_game() return end

function AccountManager:reset() return end

function AccountManager:update_presence()
	if DEDICATED_SERVER or not rawget(_G, "Presence") then return end
	local is_in_hub_level = Managers.level_transition_handler:in_hub_level()

	local state = Managers.state
	local network = state and state.network
	local lobby = network and network:lobby()
	if not lobby then return
	end
	local is_server = Managers.player.is_server
	local lobby_data = is_server and lobby:get_stored_lobby_data() or LobbyInternal.get_lobby_data_from_id(lobby:id())
	if not lobby_data then return end
	if is_in_hub_level then
		Presence.set_presence("steam_display", to_boolean(script_data ["eac-untrusted"]) and "#presence_modded_hub" or "#presence_official_hub")
		Presence.set_presence("steam_player_group_size", PresenceHelper.lobby_num_players())
		Presence.set_presence("hub_string", PresenceHelper.get_hub_presence())
		Presence.set_presence("level", PresenceHelper.lobby_level())
	else
		Presence.set_presence("steam_display", to_boolean(script_data ["eac-untrusted"]) and "#presence_modded" or "#presence_official")
		Presence.set_presence("steam_player_group", lobby:id())
		Presence.set_presence("steam_player_group_size", PresenceHelper.lobby_num_players())
		Presence.set_presence("gamemode", PresenceHelper.lobby_gamemode(lobby_data))
		Presence.set_presence("difficulty", PresenceHelper.lobby_difficulty())
		Presence.set_presence("level", PresenceHelper.lobby_level())
	end
end

function AccountManager:set_controller_disconnected(disconnected) return end

function AccountManager:controller_disconnected() return end

function AccountManager:get_friends(friends_list_limit, callback)
	if debug_friends_list then
		callback(SteamHelper.debug_friends())

	elseif rawget(_G, "Steam") and rawget(_G, "Friends") then
		callback(SteamHelper.friends())
	else
		callback(nil)
	end

end

function AccountManager:set_current_lobby(lobby) return end

function AccountManager:all_lobbies_freed() return end

function AccountManager:send_session_invitation(id, invite_target)
	if rawget(_G, "Steam") and rawget(_G, "Friends") then
		Friends.invite(id, invite_target)
	end
end

function AccountManager:show_player_profile(id)
	if rawget(_G, "Steam") then
		local dec_id = Steam.id_hex_to_dec(id)
		local url = "http://steamcommunity.com/profiles/" .. dec_id
		Steam.open_url(url)
	end
end

function AccountManager:account_id()
	return Network.peer_id()
end

function AccountManager:active_controller()
	local input_manager = Managers.input
	if input_manager:is_device_active("gamepad") then
		return input_manager:get_most_recent_device()
	end
	return nil
end

function AccountManager:region()
	return self._country_code
end

function AccountManager:friends_list_initiated() return end
function AccountManager:check_popup_retrigger() return end
function AccountManager:set_offline_mode(offline) return end
function AccountManager:is_online() return not GameSettingsDevelopment.use_offline_backend end
function AccountManager:offline_mode() return GameSettingsDevelopment.use_offline_backend == true end
function AccountManager:has_fatal_error() return false end
function AccountManager:has_popup() return false end
function AccountManager:cancel_all_popups() return end
function AccountManager:has_session() return true end
function AccountManager:has_access() return false end
function AccountManager:should_throttle() return false end
function AccountManager:console_type_setting() return true end