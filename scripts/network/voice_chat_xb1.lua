
local debug_xbox_voice = true

local function debug_print(...)
	print("[VoiceChatXboxOneManager]", string.format(...))
end

local dprintf = nil
if debug_xbox_voice then
	dprintf = debug_print
else
	function dprintf() return end
end



VoiceChatXboxOneManager = class(VoiceChatXboxOneManager)

function VoiceChatXboxOneManager:init()
	self._muted_users = { }
	self._remote_users = { }
	self._bandwidth_disabled = false
	self._has_local_user = false

	VoiceChat.init()
end

function VoiceChatXboxOneManager:reset()
	VoiceChat.clear_remote_users()
	VoiceChat.clear_local_users()

	table.clear(self._muted_users)
	table.clear(self._remote_users)

	self._bandwidth_disabled = false
	self._has_local_user = false
end

function VoiceChatXboxOneManager:clear_dangling_remote_users()
	VoiceChat.clear_dangling_remote_users()
end

function VoiceChatXboxOneManager:initiated()
	return self._has_local_user
end

function VoiceChatXboxOneManager:add_local_user()
	if not self._bandwidth_disabled and
	not self._has_local_user and Managers.account:has_privilege(UserPrivilege.COMMUNICATION_VOICE_INGAME) then
		local user_id = Managers.account:user_id()
		self._has_local_user = true

		VoiceChat.add_local_user(user_id)
	end

end

function VoiceChatXboxOneManager:remove_local_user()
	if Managers.account:user_detached() then
		return
	end

	if self._has_local_user then
		local user_id = Managers.account:user_id()
		VoiceChat.remove_user(user_id)

		self._has_local_user = false
	end
end

function VoiceChatXboxOneManager:_remove_all_users()
	self:remove_local_user()

	for xuid, _ in pairs(self._remote_users) do
		self:remove_remote_user(xuid)
	end

	table.clear(self._remote_users)
end

function VoiceChatXboxOneManager:add_remote_user(xuid, peer_id)
	if not self._bandwidth_disabled then
		self._remote_users [xuid] = peer_id
		VoiceChat.add_remote_user(xuid, peer_id)
		Application.warning(string.format("[VoiceChatXboxOneManager] Adding remote user - Xuid: %q Peer_id: %q", xuid, peer_id))
	end
end

function VoiceChatXboxOneManager:remove_remote_user(xuid)
	VoiceChat.remove_user_from_channel_with_xuid(xuid)

	local peer_id = self._remote_users [xuid]
	Application.warning(string.format("[VoiceChatXboxOneManager] Removing remote user - Xuid: %q Peer_id: %q", xuid, peer_id))

	self._remote_users [xuid] = nil
end

function VoiceChatXboxOneManager:set_enabled(enabled)

	print("[VoiceChatXboxOneManager] Temporarily turned off ability to turn voice chat ON/OFF")
	do return end

	if enabled then
		self:add_local_user()
	else
		self:_remove_all_users()
	end
end

function VoiceChatXboxOneManager:bandwitdth_disable_voip()
	self._popup_id = Managers.popup:queue_popup(Localize("popup_voice_chat_disabled_low_bandwidth"), Localize("popup_voice_chat_disabled_low_bandwidth_header"), "ok", Localize("menu_ok"))

	self:_remove_all_users()

	self._bandwidth_disabled = true
end

function VoiceChatXboxOneManager:bandwidth_disabled()
	return self._bandwidth_disabled
end

function VoiceChatXboxOneManager:is_peer_muted(peer_id)
	if not self._has_local_user then
		return true
	end

	return self._muted_users [peer_id] ~= nil
end

function VoiceChatXboxOneManager:mute_peer(peer_id)
	local xuid = Managers.state.network:lobby():xuid(peer_id)
	if xuid and self._remote_users [xuid] then
		VoiceChat.mute_user(xuid)
		self._muted_users [peer_id] = xuid
		return true
	end
end

function VoiceChatXboxOneManager:unmute_peer(peer_id)
	local xuid = self._muted_users [peer_id]
	if xuid and self._remote_users [xuid] then
		VoiceChat.unmute_user(xuid)
		return true
	end
	self._muted_users [peer_id] = nil
end

function VoiceChatXboxOneManager:set_chat_volume(volume)
	VoiceChat.set_chat_volume(volume)
end

function VoiceChatXboxOneManager:set_user_chat_volume(xuid, volume)
	local xuid = Managers.state.network:lobby():xuid(peer_id)
	if xuid and self._remote_users [xuid] then
		VoiceChat.set_user_chat_volume(xuid, volume)
	end
end

function VoiceChatXboxOneManager:mute_all_users()
	VoiceChat.mute_all_users()

	table.clear(self._muted_users)
	for xuid, _ in pairs(self._remote_users) do
		self._muted_users [xuid] = true
	end
end

function VoiceChatXboxOneManager:unmute_all_users()
	VoiceChat.unmute_all_users()
	table.clear(self._muted_users)
end

function VoiceChatXboxOneManager:update(dt, t)
	self:_handle_popups()
	self:_update_members()
end

function VoiceChatXboxOneManager:_handle_popups()
	if self._popup_id then
		local result = Managers.popup:query_result(self._popup_id)
		if result then

			self._popup_id = nil
		end
	end
end

function VoiceChatXboxOneManager:_update_members()
	if not self._has_local_user then
		return
	end

	local network_manager = Managers.state.network
	if network_manager then
		local lobby = Managers.state.network:lobby()
		if lobby then
			self:_update_members_changed(lobby)
		end
	end
end

XUIDS_TO_REMOVE = { }
REMOTE_XUIDS = { }
function VoiceChatXboxOneManager:_update_members_changed(lobby)
	if Managers.account:user_detached() then
		return
	end

	local lobby_state = lobby:get_state()
	if lobby_state ~= LobbyState.JOINED then
		return
	end

	if not lobby:is_joined() then
		return
	end

	table.clear(REMOTE_XUIDS)
	table.clear(XUIDS_TO_REMOVE)

	local my_xuid = Managers.account:xbox_user_id()

	for peer_id, channel_id in pairs(PEER_ID_TO_CHANNEL) do
		local xuid = lobby:xuid(peer_id)
		if xuid then
			if
			xuid ~= my_xuid and not self._remote_users [xuid] then
				self:add_remote_user(xuid, peer_id)
			end

			REMOTE_XUIDS [xuid] = true
		end
	end


	local lobby_host = lobby:lobby_host()
	local lobby_members = lobby:members()
	local members = lobby_members:get_members()
	if lobby_host ~= Network.peer_id() then
		for _, peer_id in pairs(members) do
			if peer_id ~= lobby_host then
				local xuid = lobby:xuid(peer_id)
				if
				xuid ~= my_xuid and not self._remote_users [xuid] then
					self:add_remote_user(xuid, peer_id)
				end

				REMOTE_XUIDS [xuid] = true
			end
		end
	end

	for xuid, peer_id in pairs(self._remote_users) do
		if not REMOTE_XUIDS [xuid] then
			XUIDS_TO_REMOVE [xuid] = true
		end
	end

	for xuid, _ in pairs(XUIDS_TO_REMOVE) do
		self:remove_remote_user(xuid)
	end
end

function VoiceChatXboxOneManager:destroy()
	VoiceChat.clear_remote_users()
	VoiceChat.clear_local_users()

	if self._popup_id then
		Managers.popup:cancel_popup(self._popup_id)
		self._popup_id = nil
	end

	VoiceChat.shutdown()
end