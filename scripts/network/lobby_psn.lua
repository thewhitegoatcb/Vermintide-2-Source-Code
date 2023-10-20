require("scripts/network/lobby_aux")
require("scripts/network/lobby_host")
require("scripts/network/lobby_client")
require("scripts/network/lobby_finder")
require("scripts/network/lobby_members")
require("scripts/network_lookup/network_lookup")

LobbyInternal = LobbyInternal or { }

LobbyInternal.lobby_data_version = 2

LobbyInternal.TYPE = "psn"

local USE_C_SERIALIZATION = false

LobbyInternal.comparison_lookup = { less_than = 3, greater_or_equal = 6, less_or_equal = 4, greater_than = 5, equal = 1, not_equal = 2 }









LobbyInternal.matchmaking_lobby_data = {
	matchmaking = { data_type = "integer",

		id = PsnRoom.SEARCHABLE_INTEGER_ID_1 },

	difficulty = { data_type = "integer",

		id = PsnRoom.SEARCHABLE_INTEGER_ID_2 },

	selected_mission_id = { data_type = "integer",

		id = PsnRoom.SEARCHABLE_INTEGER_ID_3 },

	matchmaking_type = { data_type = "integer",

		id = PsnRoom.SEARCHABLE_INTEGER_ID_4 },

	primary_region = { data_type = "integer",

		id = PsnRoom.SEARCHABLE_INTEGER_ID_5 },

	secondary_region = { data_type = "integer",

		id = PsnRoom.SEARCHABLE_INTEGER_ID_6 },

	network_hash_as_int = { data_type = "integer",

		id = PsnRoom.SEARCHABLE_INTEGER_ID_7 },

	mechanism = { data_type = "integer",

		id = PsnRoom.SEARCHABLE_INTEGER_ID_8 } }



LobbyInternal.lobby_data_network_lookups = { matchmaking = "lobby_data_values", secondary_region = "matchmaking_regions", mechanism = "mechanism_keys", is_private = "lobby_data_values", matchmaking_type = "matchmaking_types", mission_id = "mission_ids", primary_region = "matchmaking_regions", quick_game = "lobby_data_values", selected_mission_id = "mission_ids", difficulty = "difficulties", twitch_enabled = "lobby_data_values" }














LobbyInternal.key_order = { "network_hash", "difficulty", "matchmaking_type", "is_private", "mission_id", "selected_mission_id", "matchmaking", "num_players", "quick_game", "session_id", "player_slot_1", "player_slot_2", "player_slot_3", "player_slot_4", "player_slot_5", "unique_server_name", "host", "country_code", "twitch_enabled", "power_level", "mechanism" }































LobbyInternal.key_index = { }
for i, key in ipairs(LobbyInternal.key_order) do
	LobbyInternal.key_index [key] = i
end





LobbyInternal.default_lobby_data = { is_private = "false", matchmaking_type = "n/a", mission_id = "n/a", matchmaking = "false", num_players = 1, quick_game = "false", selected_mission_id = "n/a", difficulty = "normal", twitch_enabled = "false" }













function LobbyInternal.init_client(network_options)
	if not LobbyInternal.client then
		LobbyInternal.client = Network.init_psn_client(network_options.config_file_name)
		LobbyInternal.psn_room_browser = PSNRoomBrowser:new(LobbyInternal.client)
		LobbyInternal.psn_room_data_external = PsnClient.room_data_external(LobbyInternal.client)
	end

	GameSettingsDevelopment.set_ignored_rpc_logs()
end

function LobbyInternal.network_initialized()
	return not not LobbyInternal.client
end

function LobbyInternal.client_ready()
	return PsnClient.ready(LobbyInternal.client)
end

function LobbyInternal.ping(peer_id)
	return Network.ping(peer_id)
end

function LobbyInternal.shutdown_client()
	Network.shutdown_psn_client(LobbyInternal.client)
	LobbyInternal.client = nil
	LobbyInternal.psn_room_browser = nil
	LobbyInternal.psn_room_data_external = nil

	if script_data.debug_psn then
		print("[LobbyInternal] shutdown_client")
		print(Script.callstack())
	end
end

function LobbyInternal.open_channel(lobby, peer)
	local channel_id = PsnRoom.open_channel(lobby.room_id, peer)
	printf("LobbyInternal.open_channel lobby: %s, to peer: %s channel: %s", lobby, peer, channel_id)
	return channel_id
end

function LobbyInternal.close_channel(lobby, channel)
	printf("LobbyInternal.close_channel lobby: %s, channel: %s", lobby, channel)
	PsnRoom.close_channel(lobby.room_id, channel)
end


function LobbyInternal.is_orphaned(engine_lobby)
	return false
end

function LobbyInternal.game_session_host(engine_lobby)
	return PsnRoom.game_session_host(engine_lobby.room_id)
end

function LobbyInternal.create_lobby(network_options)
	local name = Managers.account:online_id() or "UNKNOWN"
	local room_id = Network.create_psn_room(name, network_options.max_members)
	if script_data.debug_psn then
		print("[LobbyInternal] creating room:", room_id)
		print(Script.callstack())
	end
	return PSNRoom:new(room_id)
end

function LobbyInternal.join_lobby(lobby_data)
	local id = lobby_data.id
	local room_id = Network.join_psn_room(id)
	if script_data.debug_psn then
		print("[LobbyInternal] joining room [room_id, id]", room_id, id)
		print(Script.callstack())
	end
	return PSNRoom:new(room_id)
end

function LobbyInternal.leave_lobby(psn_room)
	if script_data.debug_psn then
		print("[LobbyInternal] Leaving room:", psn_room.room_id)
		print(Script.callstack())
	end
	Network.leave_psn_room(psn_room.room_id)
end

function LobbyInternal.get_lobby(room_browser, index, verify_lobby_data)
	local network_psn_room_info = room_browser:lobby(index)
	local data_string = network_psn_room_info.data
	local data_table, verified = LobbyInternal.unserialize_psn_data(data_string, verify_lobby_data)
	data_table.id = network_psn_room_info.id
	data_table.name = network_psn_room_info.name

	return data_table, verified
end

function LobbyInternal.lobby_browser()
	return LobbyInternal.psn_room_browser
end

function LobbyInternal.client_lost_context()
	return PsnClient.lost_context(LobbyInternal.client)
end

function LobbyInternal.client_failed()
	return PsnClient.failed(LobbyInternal.client)
end

function LobbyInternal.get_lobby_data_from_id(id)
	local entry = LobbyInternal.room_data_entry(id)
	if entry then
		return entry.data
	end
end

function LobbyInternal.get_lobby_data_from_id_by_key(id, key)
	local entry = LobbyInternal.room_data_entry(id)
	if entry then
		return entry.data [key]
	end
end


function LobbyInternal.room_data_refresh(ids)
	if script_data.debug_psn then
		printf("[LobbyInternal] Refreshing PsnRoomDataExternal for %s number of rooms:", #ids)
		for i, id in ipairs(ids) do
			printf("\tRoomId #%d: %s", i, id)
		end
	end
	PsnRoomDataExternal.refresh(LobbyInternal.psn_room_data_external, ids)
end

function LobbyInternal.room_data_is_refreshing()
	return PsnRoomDataExternal.is_refreshing(LobbyInternal.psn_room_data_external)
end

function LobbyInternal.room_data_all_entries()
	local entries = PsnRoomDataExternal.all_entries(LobbyInternal.psn_room_data_external)
	for _, entry in ipairs(entries) do
		entry.data = LobbyInternal.unserialize_psn_data(entry.data)
	end
	return entries
end

function LobbyInternal.room_data_entry(id)
	local entry = PsnRoomDataExternal.entry(LobbyInternal.psn_room_data_external, id)
	if entry then
		entry.data = LobbyInternal.unserialize_psn_data(entry.data)
	end
	return entry
end

function LobbyInternal.room_data_num_entries()
	return PsnRoomDataExternal.num_entries(LobbyInternal.psn_room_data_external)
end

local conv_table = { }
function LobbyInternal.serialize_psn_data(data_table)
	table.clear(conv_table)

	local lobby_data_network_lookups = LobbyInternal.lobby_data_network_lookups

	for key, value in pairs(LobbyInternal.default_lobby_data) do
		if not data_table [key] then
			data_table [key] = value
		end
	end

	for key, value in pairs(data_table) do
		if lobby_data_network_lookups [key] then
			conv_table [key] = NetworkLookup [lobby_data_network_lookups [key]] [value]
		else
			conv_table [key] = value
		end
	end

	local packed_data, packed_data_size = nil

	if USE_C_SERIALIZATION then
		packed_data = PsnRoom.pack_room_data(conv_table)
		packed_data_size = string.len(packed_data)
	else
		packed_data = ""
		for idx, key in ipairs(LobbyInternal.key_order) do

			if idx > 1 then
				packed_data = packed_data .. "/"
			end

			packed_data = packed_data .. (conv_table [key] or "1")
		end

		packed_data_size = string.len(packed_data)
	end

	fassert(packed_data_size <= PSNRoom.room_data_max_size, "[PSNRoom] Tried to store %d characters in the PSN Room Data, maximum is 255 bytes", packed_data_size)

	return packed_data
end

function LobbyInternal.verify_lobby_data(lobby_data_table)
	local my_network_hash = Managers.lobby:network_hash()
	local lobby_network_hash = lobby_data_table.network_hash

	return lobby_network_hash == my_network_hash
end

function LobbyInternal.unserialize_psn_data(data_string, verify_lobby_data)
	local t = nil
	if USE_C_SERIALIZATION then
		t = PsnRoom.unpack_room_data(data_string)
	else
		t = { }
		local data_string_table = string.split(data_string, "/")


		if #data_string_table > #LobbyInternal.key_order then
			t.broken_lobby_data = data_string
			return t, false
		end


		local my_network_hash = Managers.lobby:network_hash()
		local index = LobbyInternal.key_index.network_hash
		local lobby_network_hash = data_string_table [index]
		if lobby_network_hash ~= my_network_hash then
			t.old_lobby_data = data_string
			return t, false
		end

		for i = 1, #data_string_table do
			local key = LobbyInternal.key_order [i]
			local value = data_string_table [i]
			t [key] = value
		end
	end

	local lobby_data_network_lookups = LobbyInternal.lobby_data_network_lookups

	if
	verify_lobby_data and not LobbyInternal.verify_lobby_data(t) then
		return t, false
	end


	for key, value in pairs(t) do
		if lobby_data_network_lookups [key] then
			t [key] = NetworkLookup [lobby_data_network_lookups [key]] [tonumber(value)]
		end
	end

	return t, true
end

function LobbyInternal.clear_filter_requirements()
	local room_browser = LobbyInternal.psn_room_browser
	room_browser:clear_filters()
end

function LobbyInternal.add_filter_requirements(requirements)
	local room_browser = LobbyInternal.psn_room_browser
	room_browser:clear_filters(room_browser)

	local lobby_data_network_lookups = LobbyInternal.lobby_data_network_lookups

	for key, filter in pairs(requirements.filters) do
		local mm_lobby_data = LobbyInternal.matchmaking_lobby_data [key]
		if mm_lobby_data then
			local id = mm_lobby_data.id

			local value = filter.value local comparison = filter.comparison

			if lobby_data_network_lookups [key] then
				value = NetworkLookup [lobby_data_network_lookups [key]] [value]
			end

			local comparison = LobbyInternal.comparison_lookup [comparison]

			room_browser:add_filter(id, value, comparison)
			mm_printf("Filter: %s, comparison(%s), id=%s, value(untouched)=%s, value=%s", tostring(key), tostring(comparison), tostring(id), tostring(filter.value), tostring(value))
		else
			mm_printf("Skipping filter %q matchmaking_lobby_data not setup. Probably redundant on ps4", key)
		end
	end
end

function LobbyInternal._set_matchmaking_data(room_id, key, value)
	local mm_lobby_data = LobbyInternal.matchmaking_lobby_data [key]
	fassert(mm_lobby_data, "Lobby data key %q is not set up for matchmaking", key)

	local lobby_data_network_lookups = LobbyInternal.lobby_data_network_lookups

	local data_type = mm_lobby_data.data_type
	if data_type == "integer" then

		if lobby_data_network_lookups [key] then
			value = NetworkLookup [lobby_data_network_lookups [key]] [value]
		end

		fassert(type(value) == "number", "Value needs to be an integer.")

		PsnRoom.set_searchable_attribute(room_id, mm_lobby_data.id, value)
	else
		ferror("unsupported data type %q", data_type)
	end
end

function LobbyInternal.user_name(user)
	return nil
end

function LobbyInternal.lobby_id(psn_room)
	return PsnRoom.sce_np_room_id(psn_room.room_id)
end

function LobbyInternal.is_friend(peer_id)
	print("LobbyInternal.is_friend() is not implemented on the ps4")
	return false
end

function LobbyInternal.set_max_members(lobby, max_members)
	ferror("set_max_members not supported on platform.")
end





PSNRoom = class(PSNRoom)




PSNRoom.room_data_max_size = 256

function PSNRoom:init(room_id)
	self.room_id = room_id
	self._room_data = { }
	self._serialized_room_data = ""
	self._user_names = { }

	self._refresh_room_data = false
	self._refresh_cooldown = 0
end

function PSNRoom:state()
	return PsnRoom.state(self.room_id)
end

function PSNRoom:update(dt)
	self._refresh_cooldown = math.max(self._refresh_cooldown - dt, 0)

	if self._refresh_room_data and self._refresh_cooldown == 0 then
		local packed_data_size = string.len(self._serialized_room_data)
		fassert(packed_data_size <= PSNRoom.room_data_max_size, "[PSNRoom] Tried to store %d characters in the PSN Room Data, maximum is 255 bytes", packed_data_size)

		print("ROOM DATA", self._serialized_room_data)
		PsnRoom.set_data(self.room_id, self._serialized_room_data)
		PsnRoom.set_data_internal(self.room_id, self._serialized_room_data)

		if script_data.debug_psn then
			printf("[PSNRoom] Setting Packed Room Data: %q, Packed Size: %d/%d", self._serialized_room_data, packed_data_size, PSNRoom.room_data_max_size)
		end

		self._refresh_room_data = false
		self._refresh_cooldown = 1
	end
end

function PSNRoom:set_data(key, value)
	local room_data = self._room_data
	room_data [key] = tostring(value)

	if LobbyInternal.matchmaking_lobby_data [key] then
		LobbyInternal._set_matchmaking_data(self.room_id, key, value)
	end

	local data_string = LobbyInternal.serialize_psn_data(room_data)

	if data_string ~= self._serialized_room_data then
		self._serialized_room_data = data_string

		self._refresh_room_data = true
	end
end

function PSNRoom:set_data_table(data_table)
	local room_data = self._room_data
	for key, value in pairs(data_table) do
		room_data [key] = tostring(value)

		if LobbyInternal.matchmaking_lobby_data [key] then
			LobbyInternal._set_matchmaking_data(self.room_id, key, value)
		end
	end

	local data_string = LobbyInternal.serialize_psn_data(room_data)

	if data_string ~= self._serialized_room_data then
		self._serialized_room_data = data_string

		self._refresh_room_data = true
	end
end

function PSNRoom:data(key)
	local data_string = PsnRoom.data_internal(self.room_id)
	local room_data = LobbyInternal.unserialize_psn_data(data_string)
	return room_data [key]
end










function PSNRoom:members()
	local room_id = self.room_id
	local num_members = PsnRoom.num_members(room_id)
	local t = { }
	for i = 0, num_members - 1 do
		local member = PsnRoom.member(room_id, i)
		t [i + 1] = member.peer_id
	end
	return t
end

function PSNRoom:members_np_id(t)
	local room_id = self.room_id
	local num_members = PsnRoom.num_members(room_id)
	for i = 0, num_members - 1 do
		local member = PsnRoom.member(room_id, i)
		t [i + 1] = member.np_id
	end
end

function PSNRoom:online_id_from_peer_id(peer_id)
	local room_id = self.room_id
	local num_members = PsnRoom.num_members(room_id)
	for i = 0, num_members - 1 do
		local member = PsnRoom.member(room_id, i)
		if member.peer_id == peer_id then
			return member.online_id
		end
	end

	local user_name = self._user_names [peer_id]
	if user_name then
		return user_name
	end

	fassert(false, "[PSNRoom]:np_id_froom_peer_id() No member with peer id(%s) in room(%d)", peer_id, room_id)
end

function PSNRoom:lobby_host()
	return PsnRoom.owner(self.room_id)
end

function PSNRoom:sce_np_room_id()
	return PsnRoom.sce_np_room_id(self.room_id)
end

function PSNRoom:update_user_names()
	local room_id = self.room_id
	local num_members = PsnRoom.num_members(room_id)
	for i = 0, num_members - 1 do
		local member = PsnRoom.member(room_id, i)
		self._user_names [member.peer_id] = member.online_id
	end
end

function PSNRoom:user_name(peer_id)
	local user_name = nil

	local room_id = self.room_id
	local num_members = PsnRoom.num_members(room_id)
	for i = 0, num_members - 1 do
		local member = PsnRoom.member(room_id, i)
		if member.peer_id == peer_id then
			user_name = member.online_id
			break
		end
	end
	user_name =
	user_name or self._user_names [peer_id]

	return user_name
end

function PSNRoom:user_id(peer_id)
	local user_id = nil

	local room_id = self.room_id
	local num_members = PsnRoom.num_members(room_id)
	for i = 0, num_members - 1 do
		local member = PsnRoom.member(room_id, i)
		if member.peer_id == peer_id then
			user_id = PsnRoom.user_id(room_id, i)
		end
	end

	fassert(user_id ~= nil, "[PSNRoom]:user_id() No member with peer id(%s) in room(%d)", peer_id, room_id)
	return user_id
end

function PSNRoom:set_game_session_host(peer_id)
	PsnRoom.set_game_session_host(self.room_id, peer_id)
end





PSNRoomBrowser = class(PSNRoomBrowser)

function PSNRoomBrowser:init(psn_client)
	self.browser = PsnClient.room_browser(psn_client)
end

function PSNRoomBrowser:is_refreshing()
	return PsnRoomBrowser.is_refreshing(self.browser)
end

function PSNRoomBrowser:num_lobbies()
	return PsnRoomBrowser.num_rooms(self.browser)
end

function PSNRoomBrowser:refresh()
	PsnRoomBrowser.refresh(self.browser)
end

function PSNRoomBrowser:lobby(index)
	return PsnRoomBrowser.room(self.browser, index)
end

function PSNRoomBrowser:add_filter(id, value, comparison)
	PsnRoomBrowser.add_filter(self.browser, id, value, comparison)
end

function PSNRoomBrowser:clear_filters()
	PsnRoomBrowser.clear_filters(self.browser)
end