require("scripts/managers/room/room_handler")

RoomManagerClient = class(RoomManagerClient)

local RPCS = { "rpc_inn_room_created", "rpc_inn_room_destroyed" }




function RoomManagerClient:init(world, network_event_delegate)
	self._peer_rooms = { }
	self._room_order = { }

	self._room_handler = RoomHandler:new(world)
	network_event_delegate:register(self, unpack(RPCS))
	self._network_event_delegate = network_event_delegate
end

function RoomManagerClient:setup_level_anchor_points(level)
	self._room_handler:setup_level_anchor_points(level)
end

function RoomManagerClient:create_room(peer_id, room_id, profile_index)
	local profile = SPProfiles [profile_index]
	if self._peer_rooms [peer_id] then return end
	local room_profile = profile.room_profile
	self._room_handler:create_room(room_profile, room_id)

	self._peer_rooms [peer_id] = { room_id = room_id }
	self._room_order [room_id] = peer_id
end

function RoomManagerClient:destroy_room(peer_id)
	local room_info = self._peer_rooms [peer_id]
	self._room_handler:destroy_room(room_info.room_id)

	self._room_order [room_info.room_id] = nil
	self._peer_rooms [peer_id] = nil
end

function RoomManagerClient:destroy()
	self._room_handler:destroy()
	self._room_handler = nil
	self._network_event_delegate:unregister(self)
	self._network_event_delegate = nil
end

function RoomManagerClient:rpc_inn_room_created(channel_id, peer_id, room_id, profile_index)
	self:create_room(peer_id, room_id, profile_index)
end

function RoomManagerClient:rpc_inn_room_destroyed(channel_id, peer_id)
	self:destroy_room(peer_id)
end

function RoomManagerClient:get_spawn_point_by_peer(peer_id)
	return self._peer_rooms [peer_id].room_id
end