AlwaysUnlocked = class(AlwaysUnlocked)

function AlwaysUnlocked:init(name, app_id, backend_reward_id, cosmetic, fallback_id, requires_restart, is_legacy_console_dlc)
	self._name = name
	self._is_legacy_console_dlc = is_legacy_console_dlc
	self._id = app_id or "0"
end

function AlwaysUnlocked:ready()
	return true
end

function AlwaysUnlocked:is_legacy_console_dlc()
	return self._is_legacy_console_dlc
end

function AlwaysUnlocked:has_error()
	return false
end

function AlwaysUnlocked:id()
	return self._id
end

function AlwaysUnlocked:set_status_changed(value)
	return end

function AlwaysUnlocked:backend_reward_id()
	return end

function AlwaysUnlocked:remove_backend_reward_id()
	return end

function AlwaysUnlocked:unlocked()
	return true
end

function AlwaysUnlocked:installed()
	return true
end

function AlwaysUnlocked:is_cosmetic()
	return true
end

function AlwaysUnlocked:requires_restart()
	return false
end