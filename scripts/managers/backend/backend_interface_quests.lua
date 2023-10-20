require("scripts/managers/backend/data_server_queue")

local function dprint(...)

	print("[BackendInterfaceQuests]", ...)

end

BackendInterfaceQuests = class(BackendInterfaceQuests)















function BackendInterfaceQuests:init()
	self._tokens = { }
	self._initiated = false
	self._active_quest = nil
	self._available_quests = { }
	self._active_contracts = { }
	self._available_contracts = { }

	self._expire_times = nil

	self._reward_queue = { }
end

function BackendInterfaceQuests:setup(data_server_queue)
	self:_register_executors(data_server_queue)

	self._queue = data_server_queue

	local param_config = { reset_contracts = true, reset_quests = true }






	self._queue:add_item("qnc_get_state_1")
end

function BackendInterfaceQuests:initiated()
	return self._initiated
end

function BackendInterfaceQuests:_register_executors(queue)
	queue:register_executor("quests", callback(self, "_command_quests"))
	queue:register_executor("contracts", callback(self, "_command_contracts"))
	queue:register_executor("contract_update", callback(self, "_command_contract_update"))
	queue:register_executor("contract_delete", callback(self, "_command_contract_delete"))
	queue:register_executor("quest_update", callback(self, "_command_quest_update"))
	queue:register_executor("quest_delete", callback(self, "_command_quest_delete"))
	queue:register_executor("rewarded", callback(self, "_command_rewarded"))
	queue:register_executor("expire_times", callback(self, "_command_expire_times"))
	queue:register_executor("status", callback(self, "_command_status"))
end













function BackendInterfaceQuests:_command_quests(quests)
	dprint("_command_quests")

	self._initiated = true

	self._quests = quests
	self._quests_dirty = true

	table.clear(self._available_quests)
	for quest_id, quest in pairs(quests) do
		if quest.active then
			self._active_quest = quest
		else
			self._available_quests [quest_id] = quest
		end
	end
end

function BackendInterfaceQuests:_command_contracts(contracts)
	dprint("_command_contracts")
	self._contracts = contracts
	self._contracts_dirty = true

	table.clear(self._active_contracts)
	table.clear(self._available_contracts)
	for contract_id, contract in pairs(contracts) do
		if contract.active then
			self._active_contracts [contract_id] = contract
		else
			self._available_contracts [contract_id] = contract
		end

		local backend_difficulty = contract.requirements.difficulty
		contract.requirements.difficulty = Difficulties [backend_difficulty]
	end
end

function BackendInterfaceQuests:_command_contract_update(contract_update)
	dprint("_command_contract_update")
	self._contracts_dirty = true

	local id = contract_update.id
	local contract = self._contracts [id]
	local data = contract_update.data

	for key, value in pairs(data) do
		contract [key] = value

		if key == "active" then
			if value then
				self._available_contracts [id] = nil
				self._active_contracts [id] = contract
			else
				self._available_contracts [id] = contract
				self._active_contracts [id] = nil
			end
		elseif key == "requirements" then
			local backend_difficulty = value.difficulty
			contract.requirements.difficulty = Difficulties [backend_difficulty]
		end
	end
end

function BackendInterfaceQuests:_command_contract_delete(contract_delete)
	dprint("_command_contract_delete")
	self._contracts_dirty = true

	local id = contract_delete.id
	self._contracts [id] = nil

	local active_contracts = self._active_contracts
	if active_contracts [id] then
		active_contracts [id] = nil
	end
end

function BackendInterfaceQuests:_command_quest_update(quest_update)
	dprint("_command_quest_update")
	self._quests_dirty = true

	local id = quest_update.id
	local quest = self._quests [id]
	local data = quest_update.data

	for key, value in pairs(data) do
		quest [key] = value

		if key == "active" then
			if value then
				self._available_quests [id] = nil
				self._active_quest = quest
			else
				self._available_quests [id] = quest
				self._active_quest = nil
			end
		end
	end
end

function BackendInterfaceQuests:_command_quest_delete(quest_delete)
	dprint("_command_quest_delete")
	self._quests_dirty = true

	local id = quest_delete.id
	self._quests [id] = nil

	local active_quest = self._active_quest
	if active_quest and active_quest.id == id then
		self._active_quest = nil
	end
end

function BackendInterfaceQuests:_command_rewarded(rewarded)
	dprint("_command_rewarded")
	for _, reward in ipairs(rewarded) do

		if reward.type == "item" then
			local gui_reward = { reward.data }
			table.insert(self._reward_queue, reward)

		elseif reward.type == "token" then
			local gui_reward = { type = reward.token_type, amount = reward.amount }
			table.insert(self._reward_queue, reward)
		end
	end

end

function BackendInterfaceQuests:_command_expire_times(expire_times)
	dprint("_command_expire_times")
	self._expire_times_dirty = true
	self._expire_times = expire_times
end

function BackendInterfaceQuests:_command_status(status)
	dprint("_command_status", status)
	self._status_dirty = true
	self._status = status
end













function BackendInterfaceQuests:are_quests_dirty()
	local dirty = self._quests_dirty
	self._quests_dirty = false
	return dirty
end

function BackendInterfaceQuests:get_quests()
	return self._quests
end

function BackendInterfaceQuests:get_available_quests()
	return self._available_quests
end

function BackendInterfaceQuests:get_active_quest()
	return self._active_quest
end

function BackendInterfaceQuests:set_active_quest(quest_id, active)
	local token = self._queue:add_item("qnc_set_quest_active_1", "quest_id", cjson.encode(quest_id), "active", cjson.encode(active))
	self._tokens [#self._tokens + 1] = token
end

function BackendInterfaceQuests:complete_quest(quest_id)
	local token = self._queue:add_item("qnc_turn_in_quest_1", "quest_id", cjson.encode(quest_id))
	self._tokens [#self._tokens + 1] = token
end


function BackendInterfaceQuests:are_contracts_dirty()
	local dirty = self._contracts_dirty
	self._contracts_dirty = false
	return dirty
end

function BackendInterfaceQuests:get_contracts()
	return self._contracts
end

function BackendInterfaceQuests:get_available_contracts()
	return self._available_contracts
end

function BackendInterfaceQuests:get_active_contracts()
	return self._active_contracts
end

function BackendInterfaceQuests:set_contract_active(contract_id, active)
	local token = self._queue:add_item("qnc_set_contract_active_1", "contract_id", cjson.encode(contract_id), "active", cjson.encode(active))
	self._tokens [#self._tokens + 1] = token
end

function BackendInterfaceQuests:add_contract_progress(contract_id, level, amount)
	local token = self._queue:add_item("qnc_add_contract_progress_1", "contract_id", cjson.encode(contract_id), "level", cjson.encode(level), "task_amount", cjson.encode(amount))
	self._tokens [#self._tokens + 1] = token
end

function BackendInterfaceQuests:add_all_contract_progress(contract_id)
	local token = self._queue:add_item("qnc_add_all_contract_progress_1", "contract_id", cjson.encode(contract_id))
	self._tokens [#self._tokens + 1] = token
end

function BackendInterfaceQuests:poll_reward()
	if not table.is_empty(self._reward_queue) then
		local reward = table.remove(self._reward_queue, 1)
		return reward
	end
end

function BackendInterfaceQuests:complete_contract(contract_id)
	local token = self._queue:add_item("qnc_turn_in_contract_1", "contract_id", cjson.encode(contract_id))
	self._tokens [#self._tokens + 1] = token
end

function BackendInterfaceQuests:reset_quests_and_contracts(reset_quests, reset_contracts)
	local config = cjson.encode({ reset_quests = reset_quests, reset_contracts = reset_contracts })
	local token = self._queue:add_item("qnc_reset_1", "param_config", config)
	self._tokens [#self._tokens + 1] = token
	local token2 = self._queue:add_item("qnc_get_state_1")
	self._tokens [#self._tokens + 1] = token2
end

local time_offset = 0
function BackendInterfaceQuests:reset_quests_and_contracts_with_time_offset(reset_quests, reset_contracts, add_time_offset)
	local config = cjson.encode({ reset_quests = reset_quests, reset_contracts = reset_contracts })
	local token = self._queue:add_item("qnc_reset_1", "param_config", config)
	self._tokens [#self._tokens + 1] = token

	if add_time_offset then
		time_offset = time_offset + add_time_offset
	else
		time_offset = 0
	end
	local debug_time = os.time() + time_offset
	local token2 = self._queue:add_item("get_quest_state_debug_1", "debug_time", debug_time)
	self._tokens [#self._tokens + 1] = token2
end

function BackendInterfaceQuests:query_quests_and_contracts()
	local token = self._queue:add_item("qnc_get_state_1")
	self._tokens [#self._tokens + 1] = token
end

function BackendInterfaceQuests:query_expire_times()
	dprint("query_expire_times")
	local token = self._queue:add_item("qnc_get_expire_times_1")
	self._tokens [#self._tokens + 1] = token
end

function BackendInterfaceQuests:are_expire_times_dirty()
	local dirty = self._expire_times_dirty
	self._expire_times_dirty = false
	return dirty
end

function BackendInterfaceQuests:get_expire_times()
	return self._expire_times
end

function BackendInterfaceQuests:are_status_dirty()
	local dirty = self._status_dirty
	self._status_dirty = false
	return dirty
end

function BackendInterfaceQuests:get_status()
	return self._status
end