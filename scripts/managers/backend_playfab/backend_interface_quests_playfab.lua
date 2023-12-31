
local PlayFabClientApi = require("PlayFab.PlayFabClientApi")

BackendInterfaceQuestsPlayfab = class(BackendInterfaceQuestsPlayfab)

function BackendInterfaceQuestsPlayfab:init(backend_mirror)
	self._backend_mirror = backend_mirror
	self._quests = { }
	self._last_id = 0
	self._refresh_requests = { }
	self._quest_reward_requests = { }
	self._quests_updating = false
	self._quest_timer = 0
	self._event_quest_update_times = { }

	self:_refresh()
end

function BackendInterfaceQuestsPlayfab:_refresh()
	local talents = self._talents
	local backend_mirror = self._backend_mirror
	local quest_data = backend_mirror:get_quest_data()

	self._quests.daily = quest_data.current_daily_quests
	self._quests.event = quest_data.current_event_quests

	local weekly_quests = { }
	for quest_id, quest in pairs(quest_data.current_weekly_quests) do
		local quest_copy = table.clone(quest)

		if quest.difficulty then
			quest_copy.name = quest.name .. "_" .. quest.difficulty
		else
			quest_copy.name = quest.name
		end

		weekly_quests [quest_id] = quest_copy
	end

	self._quests.weekly = weekly_quests

	self._refresh_available = quest_data.daily_quest_refresh_available
	self._daily_quest_update_time = math.ceil(quest_data.daily_quest_update_time / 1000)

	local weekly_quest_update_time = quest_data.weekly_quest_update_time
	if weekly_quest_update_time ~= nil then
		self._weekly_quest_update_time = math.ceil(weekly_quest_update_time / 1000)
	end

	for key, data in pairs(self._quests.event) do
		if data.end_time ~= nil then
			self._event_quest_update_times [key] = math.ceil(data.end_time / 1000)
		end
	end

	self._dirty = false
end

function BackendInterfaceQuestsPlayfab:ready()
	return true
end

function BackendInterfaceQuestsPlayfab:_new_id()
	self._last_id = self._last_id + 1

	return self._last_id
end

function BackendInterfaceQuestsPlayfab:make_dirty()
	self._dirty = true
end

function BackendInterfaceQuestsPlayfab:update_quests(quests_updated_cb)
	if self._quests_updating then
		return
	end

	local refresh_quests = false

	local daily_update_time = self:get_daily_quest_update_time()
	if daily_update_time <= 0 then
		refresh_quests = true
	end

	local weekly_update_time = self:get_weekly_quest_update_time()
	if weekly_update_time and weekly_update_time <= 0 then
		refresh_quests = true
	end

	for key, data in pairs(self._quests.event) do
		local event_update_time = self:get_time_left_on_event_quest(key)
		if event_update_time and event_update_time <= 0 then
			refresh_quests = true
			break
		end
	end

	if refresh_quests then
		local request = { FunctionName = "getQuests" }



		local success_callback = callback(self, "get_quests_cb")
		local request_queue = self._backend_mirror:request_queue()

		request_queue:enqueue(request, success_callback, false)
		self._quests_updated_cb = quests_updated_cb
		self._quests_updating = true
	end
end

function BackendInterfaceQuestsPlayfab:update(dt)
	self._quest_timer = self._quest_timer + dt
end

function BackendInterfaceQuestsPlayfab:get_quests_cb(result)
	local backend_mirror = self._backend_mirror
	local function_result = result.FunctionResult
	local current_daily_quests = function_result.current_daily_quests
	local daily_quest_refresh_available = function_result.daily_quest_refresh_available
	local daily_quest_update_time = function_result.daily_quest_update_time
	local current_weekly_quests = function_result.current_weekly_quests
	local weekly_quest_update_time = function_result.weekly_quest_update_time
	local current_event_quests = function_result.current_event_quests

	backend_mirror:set_quest_data("current_daily_quests", current_daily_quests)
	backend_mirror:set_quest_data("daily_quest_refresh_available", to_boolean(daily_quest_refresh_available))
	backend_mirror:set_quest_data("daily_quest_update_time", tonumber(daily_quest_update_time))
	backend_mirror:set_quest_data("current_weekly_quests", current_weekly_quests)
	backend_mirror:set_quest_data("weekly_quest_update_time", tonumber(weekly_quest_update_time))
	backend_mirror:set_quest_data("current_event_quests", current_event_quests)

	self._quests_updating = false
	self._dirty = true
	self._quest_timer = 0

	if self._quests_updated_cb then
		self._quests_updated_cb()
		self._quests_updated_cb = nil
	end
end

function BackendInterfaceQuestsPlayfab:delete()
	return end

function BackendInterfaceQuestsPlayfab:get_quests()
	if self._dirty then
		self:_refresh()
	end

	return self._quests
end

function BackendInterfaceQuestsPlayfab:get_daily_quest_update_time()
	if self._dirty then
		self:_refresh()
	end

	return self._daily_quest_update_time - self._quest_timer
end

function BackendInterfaceQuestsPlayfab:get_weekly_quest_update_time()
	if self._dirty then
		self:_refresh()
	end

	if not self._weekly_quest_update_time then return nil end
	return self._weekly_quest_update_time - self._quest_timer
end

function BackendInterfaceQuestsPlayfab:get_time_left_on_event_quest(key)
	if self._dirty then
		self:_refresh()
	end

	if not self._event_quest_update_times [key] then return nil end
	return self._event_quest_update_times [key] - self._quest_timer
end

function BackendInterfaceQuestsPlayfab:can_refresh_daily_quest()
	if self._dirty then
		self:_refresh()
	end

	return self._refresh_available
end

function BackendInterfaceQuestsPlayfab:refresh_daily_quest(key)
	local id = self:_new_id()

	local request = { FunctionName = "refreshQuest",

		FunctionParameter = {
			quest_key = key } }



	local success_callback = callback(self, "refresh_quest_cb", id, key)
	local request_queue = self._backend_mirror:request_queue()

	request_queue:enqueue(request, success_callback, false)

	return id
end

function BackendInterfaceQuestsPlayfab:refresh_quest_cb(id, key, result)
	local backend_mirror = self._backend_mirror
	local function_result = result.FunctionResult

	if function_result == "refresh_unavailable" then
		Managers.backend:playfab_error(BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_QUEST_REFRESH_UNAVAILABLE)
		self._refresh_requests [id] = { }
		return
	end

	local current_daily_quests = function_result.current_daily_quests
	local daily_quest_refresh_available = function_result.daily_quest_refresh_available

	backend_mirror:set_quest_data("current_daily_quests", current_daily_quests)
	backend_mirror:set_quest_data("daily_quest_refresh_available", to_boolean(daily_quest_refresh_available))

	self._refresh_requests [id] = { quest_key = key }

	self._dirty = true
end

function BackendInterfaceQuestsPlayfab:is_quest_refreshed(id)
	local refresh_request = self._refresh_requests [id]

	if refresh_request then
		return true, refresh_request.quest_key
	end

	return false
end

function BackendInterfaceQuestsPlayfab:can_claim_quest_rewards(key)
	local quests = self:get_quests()
	local daily_quests = self._quests.daily
	local weekly_quests = self._quests.weekly
	local event_quests = self._quests.event

	if daily_quests [key] or weekly_quests [key] or event_quests [key] then
		return true
	end

	return false
end

function BackendInterfaceQuestsPlayfab:can_claim_multiple_quest_rewards(keys)
	local daily_quests = self._quests.daily
	local weekly_quests = self._quests.weekly
	local event_quests = self._quests.event
	local claimable_keys = { }
	for i = 1, #keys do
		local key = keys [i]
		if daily_quests [key] or weekly_quests [key] or event_quests [key] then
			claimable_keys [#claimable_keys + 1] = key
		end
	end

	if not table.is_empty(claimable_keys) then
		return true, claimable_keys
	end
	return false, nil
end

function BackendInterfaceQuestsPlayfab:claim_quest_rewards(key)
	local id = self:_new_id()
	local data = {
		quest_key = key,
		id = id }


	local request = { FunctionName = "generateQuestRewards",

		FunctionParameter = data }


	local success_callback = callback(self, "quest_rewards_request_cb", data)
	local request_queue = self._backend_mirror:request_queue()

	request_queue:enqueue(request, success_callback, true)

	return id
end

function BackendInterfaceQuestsPlayfab:quest_rewards_request_cb(data, result)
	local function_result = result.FunctionResult

	if not function_result then
		Managers.backend:playfab_api_error(result)
		return
	end

	local id = data.id
	local items = function_result.items
	local chips = function_result.chips
	local currency_added = function_result.currency_added
	local backend_mirror = self._backend_mirror
	local rewards = {
		quest_key = data.quest_key,
		loot = { } }

	local loot = rewards.loot

	if items then
		for i = 1, #items do
			local item = items [i]
			local backend_id = item.ItemInstanceId
			local amount = item.UsesIncrementedBy or 1

			backend_mirror:add_item(backend_id, item)

			loot [i] = { type = "item", backend_id = backend_id, amount = amount }
		end
	end

	local new_keep_decorations = function_result.new_keep_decorations

	if new_keep_decorations then
		for i = 1, #new_keep_decorations do
			local keep_decoration_name = new_keep_decorations [i]

			backend_mirror:add_keep_decoration(keep_decoration_name)

			loot [#loot + 1] = { type = "keep_decoration_painting", keep_decoration_name = keep_decoration_name }
		end
	end

	local new_weapon_skins = function_result.new_weapon_skins

	if new_weapon_skins then
		for i = 1, #new_weapon_skins do
			local weapon_skin_name = new_weapon_skins [i]

			backend_mirror:add_unlocked_weapon_skin(weapon_skin_name)

			loot [#loot + 1] = { type = "weapon_skin", weapon_skin_name = weapon_skin_name }
		end
	end


	local new_cosmetics = function_result.new_cosmetics
	if new_cosmetics then
		local item_master_list = ItemMasterList
		for i = 1, #new_cosmetics do
			local cosmetic_name = new_cosmetics [i]

			local backend_id = backend_mirror:add_item(nil, { ItemId = cosmetic_name })
			if backend_id then
				local item = item_master_list [cosmetic_name]
				loot [#loot + 1] = { amount = 1, type = item.slot_type, backend_id = backend_id }
			end
		end
	end


	local rewarded_currency = { }
	if currency_added then
		for _, data in ipairs(currency_added) do
			local code = data.code
			local amount = data.amount
			local current_amount = rewarded_currency [code]
			rewarded_currency [code] = current_amount and current_amount or 0 + amount

			loot [#loot + 1] = { type = "currency", currency_code = code, amount = amount }
		end
	end

	if chips then
		local peddler_interface = Managers.backend:get_interface("peddler")
		if peddler_interface then
			for chip_type, amount in pairs(chips) do
				peddler_interface:set_chips(chip_type, amount)
			end
		end
	end

	local claimed_quest_name, claimed_quest_type = nil
	if function_result.quest_name then
		claimed_quest_name = function_result.quest_name
		claimed_quest_type = function_result.quest_type
	else

		local quest_types = { "current_daily_quests", "current_event_quests", "current_weekly_quests" }
		local quest_types_map = { current_event_quests = "event", current_weekly_quests = "weekly", current_daily_quests = "daily" }
		local quest_data = backend_mirror:get_quest_data()
		for i = 1, #quest_types do
			local key = quest_types [i]
			local current_quests = quest_data [key]
			local claimed_quest_data = current_quests [data.quest_key]
			if claimed_quest_data then
				claimed_quest_name = claimed_quest_data.name
				claimed_quest_type = quest_types_map [key]
				break
			end
		end
	end

	if claimed_quest_type == "event" then
		backend_mirror:add_claimed_event_quest(claimed_quest_name)
	end

	local current_daily_quests = function_result.current_daily_quests or { }
	local current_weekly_quests = function_result.current_weekly_quests or { }
	local current_event_quests = function_result.current_event_quests or { }

	backend_mirror:set_quest_data("current_daily_quests", current_daily_quests)
	backend_mirror:set_quest_data("current_weekly_quests", current_weekly_quests)
	backend_mirror:set_quest_data("current_event_quests", current_event_quests)

	local player = Managers.player and Managers.player:local_player()
	local statistics_db = Managers.player:statistics_db()

	if not player or not statistics_db then
		Application.warning("[BackendInterfaceQuestsPlayfab] Could not get statistics_db, skipping updating statistics...")
	else
		local player_stats_id = player:stats_id()
		local quests = self:get_quests()
		local daily_quests = quests.daily
		local weekly_quests = quests.weekly

		for quest_key, _ in pairs(daily_quests) do
			if quest_key == data.quest_key then
				statistics_db:increment_stat(player_stats_id, "completed_daily_quests")
				break
			end
		end

		for quest_key, _ in pairs(weekly_quests) do
			if quest_key == data.quest_key then
				statistics_db:increment_stat(player_stats_id, "completed_weekly_quests")
				break
			end
		end
	end

	self._quest_reward_requests [id] = rewards
	self._dirty = true
end

function BackendInterfaceQuestsPlayfab:claim_multiple_quest_rewards(keys)
	local quest_data = { }
	local id = self:_new_id()
	for i = 1, #keys do
		local key = keys [i]
		local data = {
			quest_key = key }

		quest_data [#quest_data + 1] = data
	end
	local request = { FunctionName = "generateQuestRewards",

		FunctionParameter = {
			quest_data = quest_data,
			id = id } }



	local success_callback = callback(self, "claim_multiple_quest_rewards_request_cb", quest_data, id)
	local request_queue = self._backend_mirror:request_queue()

	request_queue:enqueue(request, success_callback, true)

	return id
end

function BackendInterfaceQuestsPlayfab:claim_multiple_quest_rewards_request_cb(data, id, result)
	local function_result = result.FunctionResult

	if not function_result then
		Managers.backend:playfab_api_error(result)
		return
	end

	local id = id
	local items = function_result.items
	local chips = function_result.chips
	local currency_added = function_result.currency_added
	local backend_mirror = self._backend_mirror
	local quest_names = function_result.quest_data_names
	local quest_keys = { }
	for i = 1, #data do
		quest_keys [#quest_keys + 1] = data [i].quest_key
	end
	local rewards = {
		quest_key = quest_keys,
		loot = { } }

	local loot = rewards.loot

	if items then
		for i = 1, #items do
			local item = items [i]
			local backend_id = item.ItemInstanceId
			local amount = item.UsesIncrementedBy or 1

			backend_mirror:add_item(backend_id, item)

			loot [i] = { type = "item", backend_id = backend_id, amount = amount }
		end
	end

	local new_keep_decorations = function_result.new_keep_decorations

	if new_keep_decorations then
		for i = 1, #new_keep_decorations do
			local keep_decoration_name = new_keep_decorations [i]

			backend_mirror:add_keep_decoration(keep_decoration_name)

			loot [#loot + 1] = { type = "keep_decoration_painting", keep_decoration_name = keep_decoration_name }
		end
	end

	local new_weapon_skins = function_result.new_weapon_skins

	if new_weapon_skins then
		for i = 1, #new_weapon_skins do
			local weapon_skin_name = new_weapon_skins [i]

			backend_mirror:add_unlocked_weapon_skin(weapon_skin_name)

			loot [#loot + 1] = { type = "weapon_skin", weapon_skin_name = weapon_skin_name }
		end
	end


	local new_cosmetics = function_result.new_cosmetics
	if new_cosmetics then
		local item_master_list = ItemMasterList
		for i = 1, #new_cosmetics do
			local cosmetic_name = new_cosmetics [i]

			local backend_id = backend_mirror:add_item(nil, { ItemId = cosmetic_name })
			if backend_id then
				local item = item_master_list [cosmetic_name]
				loot [#loot + 1] = { amount = 1, type = item.slot_type, backend_id = backend_id }
			end
		end
	end


	local rewarded_currency = { }
	if currency_added then
		for _, data in ipairs(currency_added) do
			local code = data.code
			local amount = data.amount
			local current_amount = rewarded_currency [code]
			rewarded_currency [code] = current_amount and current_amount or 0 + amount

			loot [#loot + 1] = { type = "currency", currency_code = code, amount = amount }
		end
	end

	if chips then
		local peddler_interface = Managers.backend:get_interface("peddler")
		if peddler_interface then
			for chip_type, amount in pairs(chips) do
				peddler_interface:set_chips(chip_type, amount)
			end
		end
	end

	local claimed_quest_names = { }
	local claimed_quest_type = nil
	if quest_names then
		for i = 1, #quest_names do
			claimed_quest_names [#claimed_quest_names + 1] = quest_names [i]
		end
		claimed_quest_type = function_result.quest_type
	else

		local quest_types = { "current_daily_quests", "current_event_quests", "current_weekly_quests" }
		local quest_types_map = { current_event_quests = "event", current_weekly_quests = "weekly", current_daily_quests = "daily" }
		local quest_data = backend_mirror:get_quest_data()
		for j = 1, #data do
			for i = 1, #quest_types do
				local key = quest_types [i]
				local current_quests = quest_data [key]
				local claimed_quest_data = current_quests [data [j].quest_key]
				if claimed_quest_data then
					claimed_quest_names [#claimed_quest_names + 1] = claimed_quest_data.name

					claimed_quest_type =
					claimed_quest_type or quest_types_map [key]
				end
			end
		end
	end


	if claimed_quest_type == "event" then
		backend_mirror:add_claimed_multiple_event_quests(claimed_quest_names)
	end

	local current_daily_quests = function_result.current_daily_quests
	local current_weekly_quests = function_result.current_weekly_quests
	local current_event_quests = function_result.current_event_quests

	backend_mirror:set_quest_data("current_daily_quests", current_daily_quests)
	backend_mirror:set_quest_data("current_weekly_quests", current_weekly_quests)
	backend_mirror:set_quest_data("current_event_quests", current_event_quests)

	local player = Managers.player and Managers.player:local_player()
	local statistics_db = Managers.player:statistics_db()

	if not player or not statistics_db then
		Application.warning("[BackendInterfaceQuestsPlayfab] Could not get statistics_db, skipping updating statistics...")
	else
		local player_stats_id = player:stats_id()
		local quests = self:get_quests()
		local daily_quests = quests.daily
		local weekly_quests = quests.weekly
		for i = 1, #data do
			for quest_key, _ in pairs(daily_quests) do
				if quest_key == data [i].quest_key then
					statistics_db:increment_stat(player_stats_id, "completed_daily_quests")
					break
				end
			end

			for quest_key, _ in pairs(weekly_quests) do
				if quest_key == data [i].quest_key then
					statistics_db:increment_stat(player_stats_id, "completed_weekly_quests")
					break
				end
			end
		end
	end

	self._quest_reward_requests [id] = rewards
	self._dirty = true
end

function BackendInterfaceQuestsPlayfab:get_quest_key(quest_id)
	local quests = self:get_quests()
	local daily_quests = quests.daily
	local weekly_quests = quests.weekly
	local event_quests = quests.event

	for quest_key, quest_data in pairs(daily_quests) do
		local id = quest_data.name

		if id == quest_id then
			return quest_key
		end
	end

	for quest_key, quest_data in pairs(weekly_quests) do
		local id = quest_data.name

		if id == quest_id then
			return quest_key
		end
	end

	for quest_key, quest_data in pairs(event_quests) do
		local id = quest_data.name

		if id == quest_id then
			return quest_key
		end
	end

	return nil
end

function BackendInterfaceQuestsPlayfab:get_quest_by_key(key)
	local quests = self:get_quests()
	local daily_quests = quests.daily
	local weekly_quests = quests.weekly
	local event_quests = quests.event

	for quest_key, quest_data in pairs(daily_quests) do
		if key == quest_key then
			return quest_data
		end
	end

	for quest_key, quest_data in pairs(weekly_quests) do
		if key == quest_key then
			return quest_data
		end
	end

	for quest_key, quest_data in pairs(event_quests) do
		if key == quest_key then
			return quest_data
		end
	end

	return nil
end





function BackendInterfaceQuestsPlayfab:quest_rewards_generated(id)
	local request = self._quest_reward_requests [id]

	if request then
		return true
	end

	return false
end

function BackendInterfaceQuestsPlayfab:get_quest_rewards(id)
	return self._quest_reward_requests [id]
end

function BackendInterfaceQuestsPlayfab:get_claimed_event_quests()
	local mirror = self._backend_mirror
	return mirror:get_claimed_event_quests()
end