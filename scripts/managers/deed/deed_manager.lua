DeedManager = class(DeedManager)

local RPCS = { "rpc_select_deed", "rpc_reset_deed", "rpc_deed_consumed" }





function DeedManager:init()
	self._selected_deed_data = nil
	self._selected_deed_id = nil
	self._owner_peer_id = nil
end

function DeedManager:destroy()
	if self._network_event_delegate then
		self._network_event_delegate:unregister(self)
		self._network_event_delegate = nil
	end
end


function DeedManager:network_context_created(lobby, server_peer_id, own_peer_id, is_server, network_handler)
	self._lobby = lobby
	self._server_peer_id = server_peer_id
	self._peer_id = own_peer_id
	self._network_server = is_server and network_handler or nil
	self._is_server = is_server

	local ignore_send = true
	self:reset(ignore_send)
end


function DeedManager:network_context_destroyed()
	self._lobby = nil
	self._server_peer_id = nil
	self._peer_id = nil
	self._network_server = nil
	self._is_server = false

	local ignore_send = true
	self:reset(ignore_send)
end

function DeedManager:register_rpcs(network_event_delegate)
	network_event_delegate:register(self, unpack(RPCS))
	self._network_event_delegate = network_event_delegate
end

function DeedManager:unregister_rpcs()
	self._network_event_delegate:unregister(self)
	self._network_event_delegate = nil
end

function DeedManager:reset(ignore_send)
	self._selected_deed_data = nil
	self._selected_deed_id = nil
	self._owner_peer_id = nil
	self._deed_session_faulty = nil

	if self._is_server and not ignore_send then
		self:_send_rpc_to_clients("rpc_reset_deed")
	end
end

function DeedManager:mutators()
	if self._selected_deed_data then
		do return self._selected_deed_data.mutators end
	else
		return nil
	end
end

function DeedManager:rewards()
	if self._selected_deed_data then
		do return self._selected_deed_data.rewards end
	else
		return nil
	end
end

function DeedManager:has_deed()
	return self._selected_deed_data ~= nil
end

function DeedManager:active_deed()
	fassert(self._selected_deed_data, "Has no active deed")
	return self._selected_deed_data, self._selected_deed_id
end

function DeedManager:is_deed_owner(peer_id)
	peer_id = peer_id or self._peer_id
	return self._owner_peer_id == peer_id
end

function DeedManager:is_session_faulty()
	return self._deed_session_faulty
end

function DeedManager:consume_deed(reward_callback)
	print("[DeedManager]:consume_deed()")
	if self._owner_peer_id == self._peer_id then
		local network_manager = Managers.state.network
		if network_manager and network_manager:game() then
			if self._is_server then
				self:_send_rpc_to_clients("rpc_deed_consumed")
			else
				self:_send_rpc_to_server("rpc_deed_consumed")
			end
		end

	elseif self._has_consumed_deed then
		self._has_consumed_deed = nil

		self._reward_callback = reward_callback
		self:_use_reward_callback()
	else
		self._reward_callback = reward_callback
	end

end

function DeedManager:hot_join_sync(peer_id)
	if not self:has_deed() then
		return
	end

	local selected_deed_data = self._selected_deed_data
	local owner_peer_id = self._owner_peer_id
	local item_name_id = NetworkLookup.item_names [selected_deed_data.name]

	self:_send_rpc_to_client("rpc_select_deed", peer_id, item_name_id, owner_peer_id)
end

function DeedManager:delete_marked_deeds(deed_list)
	local item_interface = Managers.backend:get_interface("items")
	item_interface:delete_marked_deeds(deed_list)
	local is_deleting_deeds = item_interface:is_deleting_deeds()
	self._is_deleting_deeds = is_deleting_deeds
	return is_deleting_deeds
end

function DeedManager:is_deleting_deeds()
	return self._is_deleting_deeds and true or false
end

function DeedManager:_update_deed_deletion()
	local is_deleting_deeds = self._is_deleting_deeds
	if is_deleting_deeds then
		local item_interface = Managers.backend:get_interface("items")
		local deletion_completed = item_interface:is_deleting_deeds()

		if not deletion_completed then
			self._is_deleting_deeds = nil
		end
	end
end

function DeedManager:can_delete_deeds(current_deeds, marked_deeds)
	local item_interface = Managers.backend:get_interface("items")
	local can_delete, remaining_deeds, deletable_deeds = item_interface:can_delete_deeds(current_deeds, marked_deeds)

	local num_marked_deeds, num_deletable_deeds = nil
	num_marked_deeds = marked_deeds and #marked_deeds or 0
	num_deletable_deeds = deletable_deeds and #deletable_deeds or 0
	if can_delete and num_deletable_deeds ~= num_marked_deeds then
		return remaining_deeds, deletable_deeds, "Not all marked deeds could be deleted."
	end

	if not can_delete then
		return nil, nil, "No deeds could be deleted!"
	end

	return remaining_deeds, deletable_deeds, nil
end


function DeedManager:update(dt)
	if self:has_deed() then
		self:_update_owner(dt)
	end
	self:_update_deed_deletion()
end

function DeedManager:select_deed(backend_id, peer_id)
	local item_interface = Managers.backend:get_interface("items")
	local item = item_interface:get_item_from_id(backend_id)
	local item_data = item.data

	self._selected_deed_data = item_data
	self._selected_deed_id = backend_id
	self._owner_peer_id = peer_id
	self._deed_session_faulty = false

	local network_manager = Managers.state.network
	if network_manager and network_manager:game() then

		local item_name_id = NetworkLookup.item_names [item_data.name]

		if self._is_server then
			self:_send_rpc_to_clients("rpc_select_deed", item_name_id, peer_id)
		else
			self:_send_rpc_to_server("rpc_select_deed", item_name_id, peer_id)
		end
	end
end

function DeedManager:_update_owner(dt)
	if self._deed_session_faulty then
		return
	end

	local owner_peer_id = self._owner_peer_id

	local lobby = self._lobby
	local members_map = lobby:members():members_map()


	if not members_map [owner_peer_id] then
		Managers.chat:add_local_system_message(1, Localize("deed_owner_left_game"), true)

		self._deed_session_faulty = true
	end
end

function DeedManager:_use_reward_callback()
	fassert(self._reward_callback, "there is no reward callback")

	local reward_callback = self._reward_callback
	self._reward_callback = nil

	reward_callback()
end


function DeedManager:rpc_select_deed(channel_id, item_name_id, owner_peer_id)
	local item_name = NetworkLookup.item_names [item_name_id]
	local item_data = ItemMasterList [item_name]

	self._selected_deed_data = item_data
	self._selected_deed_id = nil
	self._owner_peer_id = owner_peer_id

	local network_manager = Managers.state.network
	if self._is_server and network_manager and network_manager:game() then
		local peer_id = CHANNEL_TO_PEER_ID [channel_id]
		self:_send_rpc_to_clients_except("rpc_select_deed", peer_id, item_name_id, owner_peer_id)
	end
end

function DeedManager:rpc_deed_consumed(channel_id)
	print("Deed has been consumed by owner, act on reward callback!")

	if not self._reward_callback then
		self._has_consumed_deed = true
	else
		self:_use_reward_callback()
	end

	local network_manager = Managers.state.network
	if self._is_server and network_manager and network_manager:game() then
		print("Sending to the other clients to act on deed consume")
		local peer_id = CHANNEL_TO_PEER_ID [channel_id]
		self:_send_rpc_to_clients_except("rpc_deed_consumed", peer_id)
	end
end

function DeedManager:rpc_reset_deed(channel_id)

	local peer_id = CHANNEL_TO_PEER_ID [channel_id]
	if peer_id ~= self._server_peer_id then
		print("[DeedManager] Skipping rpc_reset_deed, not sent from current server")
		return
	end

	local ignore_send = true
	self:reset(ignore_send)
end


function DeedManager:_send_rpc_to_server(rpc_name, ...)
	local rpc = RPC [rpc_name]
	local channel_id = PEER_ID_TO_CHANNEL [self._server_peer_id]
	rpc(channel_id, ...)
end

function DeedManager:_send_rpc_to_clients(rpc_name, ...)
	local network_server = self._network_server
	if not network_server then
		return
	end

	local rpc = RPC [rpc_name]
	local server_peer_id = self._server_peer_id
	local client_peer_ids = network_server:players_past_connecting()

	for i = 1, #client_peer_ids do
		local peer_id = client_peer_ids [i]
		if peer_id ~= server_peer_id then
			local channel_id = PEER_ID_TO_CHANNEL [peer_id]
			rpc(channel_id, ...)
		end
	end
end

function DeedManager:_send_rpc_to_clients_except(rpc_name, except, ...)
	local network_server = self._network_server
	if not network_server then
		return
	end

	local rpc = RPC [rpc_name]
	local server_peer_id = self._server_peer_id
	local client_peer_ids = network_server:players_past_connecting()

	for i = 1, #client_peer_ids do
		local peer_id = client_peer_ids [i]
		if peer_id ~= server_peer_id and peer_id ~= except then
			local channel_id = PEER_ID_TO_CHANNEL [peer_id]
			rpc(channel_id, ...)
		end
	end
end

function DeedManager:_send_rpc_to_client(rpc_name, client_peer_id, ...)
	local network_server = self._network_server
	if not network_server then
		return
	end

	local rpc = RPC [rpc_name]

	local channel_id = PEER_ID_TO_CHANNEL [client_peer_id]
	rpc(channel_id, ...)
end