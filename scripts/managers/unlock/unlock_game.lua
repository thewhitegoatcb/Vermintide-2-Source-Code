UnlockGame = class(UnlockGame)

function UnlockGame:init(name, app_id, backend_reward_id, always_unlocked_game_app_ids, cosmetic)
	return end

function UnlockGame:is_legacy_console_dlc()
	return false
end

function UnlockGame:cb_get_inventory_items_done(info)
	return end

function UnlockGame:ready()
	return true
end

function UnlockGame:has_error()
	return end

function UnlockGame:id()
	return end

function UnlockGame:backend_reward_id()
	return end

function UnlockGame:remove_backend_reward_id()
	return end

function UnlockGame:set_status_changed(value)
	return end

function UnlockGame:unlocked()
	return end

function UnlockGame:installed()
	return end

function UnlockGame:is_cosmetic()
	return false
end

function UnlockGame:requires_restart()
	return false
end