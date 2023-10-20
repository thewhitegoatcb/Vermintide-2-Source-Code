require("scripts/network/lobby_aux")

LobbyClient = class(LobbyClient)

function LobbyClient:init(network_options, lobby_data, joined_lobby)
	local lobby = joined_lobby or LobbyInternal.join_lobby(lobby_data)
	self.lobby = lobby

	self.stored_lobby_data = lobby_data
	local config_file_name = network_options.config_file_name
	local project_hash = network_options.project_hash
	self.network_hash = LobbyAux.create_network_hash(config_file_name, project_hash)
	self.peer_id = Network.peer_id()

	self._host_peer_id = nil

	self._host_channel_id = nil
end

function LobbyClient:destroy()

	local host = self._host_peer_id
	local channel_id = self._host_channel_id
	if channel_id then
		printf("LobbyClient close server channel %s to %s", tostring(channel_id), host)
		LobbyInternal.close_channel(self.lobby, channel_id)
		PEER_ID_TO_CHANNEL [host] = nil
		CHANNEL_TO_PEER_ID [channel_id] = nil
	end


	if IS_PS4 and self._host_peer_id then --[[ Nothing --]]
	end


	self._host_peer_id = nil
	self._host_channel_id = nil

	LobbyInternal.leave_lobby(self.lobby)

	self.lobby_members = nil
	self.lobby = nil
	self.has_sent_join = false
	GarbageLeakDetector.register_object(self, "Lobby Client")
end

function LobbyClient:update(dt)
	local engine_lobby = self.lobby
	local host_peer_id = engine_lobby:lobby_host()
	local new_state = engine_lobby:state()
	local old_state = self.state
	if new_state ~= old_state then
		printf("[LobbyClient] Changed state from %s to %s", tostring(old_state), new_state)
		self.state = new_state
		if new_state == LobbyState.JOINED then
			self.lobby_members = self.lobby_members or LobbyMembers:new(engine_lobby, self.client)

			Managers.party:set_leader(host_peer_id)
			self._look_for_host = true
			self._reconnecting_to_lobby = nil
			self._try_reconnecting = nil
			self._reconnect_times = nil
			Managers.account:update_presence()
			print("[LobbyClient] connected to lobby, id:", self.stored_lobby_data.id)
		end

		if old_state == LobbyState.JOINED then


			Managers.party:set_leader(nil)

			if self.lobby_members then
				self.lobby_members:clear()
				self.has_sent_join = false
			end
		end

		if self._reconnecting_to_lobby and
		new_state == LobbyState.FAILED then
			self._reconnecting_to_lobby = false
			self._try_reconnecting = not self._reconnect_times or self._reconnect_times < 10
		end
	end


	if self._look_for_host then
		local host = engine_lobby:lobby_host()
		printf("====== Looking for host: %s", tostring(host))
		if host ~= nil then
			local channel_id = LobbyInternal.open_channel(engine_lobby, host)

			self._host_peer_id = host
			self._host_channel_id = channel_id
			PEER_ID_TO_CHANNEL [host] = channel_id
			CHANNEL_TO_PEER_ID [channel_id] = host

			printf("Connected to host: %s, using channel: %d", host, channel_id)
			self._look_for_host = nil
		end
	end

	if self.lobby_members then
		self.lobby_members:update()
		local my_peer_id = self.peer_id
		local members_left = self.lobby_members:get_members_left()
		for i = 1, #members_left do
			local peer_id = members_left [i]
			if peer_id == my_peer_id then
				self._lost_connection_to_lobby = true
				self._try_reconnecting = peer_id == my_peer_id
				print("[LobbyClient] Lost connection to the lobby")
			end
		end
	end

	if HAS_STEAM and
	self:lost_connection_to_lobby() and not self._reconnecting_to_lobby and self._try_reconnecting then
		print("[LobbyClient] Attempting to rejoin lobby", self.stored_lobby_data.id, "Retries:", self._reconnect_times or 0)

		local host = self._host_peer_id
		local channel_id = self._host_channel_id
		if channel_id then
			printf("LobbyClient close server channel %s to %s", tostring(channel_id), host)
			LobbyInternal.close_channel(self.lobby, channel_id)
			PEER_ID_TO_CHANNEL [host] = nil
			CHANNEL_TO_PEER_ID [channel_id] = nil
		end

		LobbyInternal.leave_lobby(self.lobby)
		self.lobby = LobbyInternal.join_lobby(self.stored_lobby_data)
		self.state = nil

		if self.lobby_members then
			self.lobby_members:clear()
			self.has_sent_join = false
		end

		self._reconnect_times = ( self._reconnect_times or 0 ) + 1
		self._reconnecting_to_lobby = true
		self._try_reconnecting = false
	end

end

function LobbyClient:get_stored_lobby_data()
	return self.stored_lobby_data
end

function LobbyClient:update_user_names()
	if IS_PS4 then
		self.lobby:update_user_names()
	end
end

function LobbyClient:members()
	return self.lobby_members
end



function LobbyClient:invite_target()
	return self.lobby
end


function LobbyClient:is_dedicated_server()
	return false
end

function LobbyClient:lobby_host()
	return self._host_peer_id
end

function LobbyClient:lobby_data(key)
	return self.lobby:data(key)
end

function LobbyClient:has_user_name(peer_id)
	return self.lobby:user_name(peer_id) ~= nil
end

function LobbyClient:user_name(peer_id)
	if HAS_STEAM then
		return string.gsub(Steam.user_name(), "%c", "")
	elseif IS_PS4 then
		return string.gsub(self.lobby:user_name(peer_id), "%c", "")
	else
		return peer_id
	end
end

function LobbyClient:is_joined()
	return self.state == LobbyState.JOINED
end

function LobbyClient:failed()
	return self.state == LobbyState.FAILED
end

function LobbyClient:id()
	return LobbyInternal.lobby_id and LobbyInternal.lobby_id(self.lobby) or "no_id"
end

function LobbyClient:attempting_reconnect()
	return self._reconnecting_to_lobby or self._try_reconnecting
end


function LobbyClient:_free_lobby()
	if self.lobby ~= nil then
		LobbyInternal.leave_lobby(self.lobby)
		self.lobby = nil
	end
end

function LobbyClient:lost_connection_to_lobby()
	return LobbyInternal.is_orphaned(self.lobby) or self._lost_connection_to_lobby
end

function LobbyClient:game_session_host()
	return LobbyInternal.game_session_host(self.lobby)
end