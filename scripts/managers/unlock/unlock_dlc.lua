UnlockDlc = class(UnlockDlc)

function UnlockDlc:init(name, app_id, backend_reward_id, always_unlocked_game_app_ids, cosmetic, fallback_id, requires_restart)
	self._name = name
	self._id = app_id
	self._backend_reward_id = backend_reward_id
	self._installed = false
	self._owned = false
	self._cosmetic = cosmetic
	self._requires_restart = requires_restart
	self._status_changed = false

	if HAS_STEAM and always_unlocked_game_app_ids then
		local steam_app_id = Steam.app_id()
		if steam_app_id and table.contains(always_unlocked_game_app_ids, steam_app_id) then
			self._always_unlocked_for_app_id = true
			self._installed = true
		end
	end

	self:update_is_installed()
end

function UnlockDlc:is_legacy_console_dlc()
	return false
end

function UnlockDlc:ready()
	return true
end

function UnlockDlc:has_error()
	return false
end

function UnlockDlc:id()
	return self._id
end

function UnlockDlc:backend_reward_id()
	return self._backend_reward_id
end

function UnlockDlc:remove_backend_reward_id()
	self._backend_reward_id = nil
end

function UnlockDlc:unlocked()







	return self._installed and self._owned
end

function UnlockDlc:installed()






	return self._installed
end

function UnlockDlc:set_owned(value, set_status_change)
	if set_status_change == nil or set_status_change then
		self._status_changed = self._status_changed or value ~= self._owned
	end

	self._owned = value
end

function UnlockDlc:set_status_changed(value)
	self._status_changed = value
end

function UnlockDlc:update_is_installed()
	if not HAS_STEAM then
		return self._installed
	end

	if self._always_unlocked_for_app_id then
		return self._installed
	end










	local installed = Steam.is_installed(self._id)
	if self._installed ~= installed then
		self._installed = installed
		return installed, true
	end

	return installed
end

function UnlockDlc:is_cosmetic()
	return self._cosmetic
end

function UnlockDlc:requires_restart()
	return self._status_changed and self._requires_restart
end