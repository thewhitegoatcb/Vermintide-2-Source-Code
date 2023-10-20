require("scripts/helpers/steam_helper")

UnlockClan = class(UnlockClan)

function UnlockClan:init(name, clan_id, backend_reward_id, always_unlocked_game_app_ids)
	self._name = name
	self._id = clan_id
	self._backend_reward_id = backend_reward_id
	self._unlocked = false

	if rawget(_G, "Steam") then
		local clans = SteamHelper.clans()
		if clans [clan_id] then
			self._unlocked = true
		end
	end
end

function UnlockClan:ready()
	return true
end

function UnlockClan:has_error()
	return false
end

function UnlockClan:id()
	return self._id
end

function UnlockClan:backend_reward_id()
	return self._backend_reward_id
end

function UnlockClan:remove_backend_reward_id()
	self._backend_reward_id = nil
end

function UnlockClan:set_status_changed(value)
	return end

function UnlockClan:unlocked()
	return self._unlocked
end

function UnlockClan:installed()
	return self._unlocked
end

function UnlockClan:is_cosmetic()
	return true
end