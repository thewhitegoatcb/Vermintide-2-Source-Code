





BanListManager = class(BanListManager)

local SAVE_FILE = "ban_list"
















function BanListManager:init()

	self._bans = { }

	self:_load_bans()
end






function BanListManager:ban(peer_id, name, until_time_stamp)
	self._bans [peer_id] = { name = name, ban_end = until_time_stamp }
end



function BanListManager:unban(peer_id)
	self._bans [peer_id] = nil
end



function BanListManager:save(callback)
	local function cb(result)
		self:_save_done_callback(result, callback)
	end
	local force_local_save = true
	Managers.save:auto_save(SAVE_FILE, self._bans, cb, force_local_save)
end



local function in_ban_range(ban_info)
	local ban_end = ban_info.ban_end
	local now = os.time()
	return ban_end == nil or now < ban_end
end



function BanListManager:is_banned(peer_id)
	local ban_info = self._bans [peer_id]
	if ban_info == nil then

		return false
	end

	return in_ban_range(ban_info)
end






function BanListManager:ban_list()
	local result = { }


	local function order_func(t, a, b)
		local left_name = t [a].name
		local right_name = t [b].name

		if left_name ~= right_name then
			return left_name < right_name
		end

		return a < b
	end


	for peer_id, ban_info in table.sorted(self._bans, order_func) do
		result [#result + 1] = {
			name = ban_info.name,
			peer_id = peer_id,
			ban_end = ban_info.ban_end }
	end


	return result
end


function BanListManager:banned_peers()
	local result = { }
	for peer, _ in pairs(self._bans) do
		result [#result + 1] = peer
	end
	return result
end
















function BanListManager:_load_bans()
	local function callback(result)
		self:_load_done_callback(result)
	end
	local force_local_load = true
	Managers.save:auto_load(SAVE_FILE, callback, force_local_load)
end


function BanListManager:_load_done_callback(result)
	if result.error ~= nil then

		print(string.format("Failed to load the ban list (%s). It will be empty.", result.error))
		return
	end

	table.merge(self._bans, result.data)

	self:_remove_old_bans()
end

function BanListManager:_save_done_callback(result, callback)
	if result.error ~= nil then

		print(string.format("Failed to save the ban list (%s).", result.error))
		callback(result.error)
		return
	end
	callback()
end


function BanListManager:_remove_old_bans()
	local new_bans = { }
	for peer_id, ban_info in pairs(self._bans) do
		if in_ban_range(ban_info) then

			new_bans [peer_id] = ban_info
		end
	end
	self._bans = new_bans
end