














local FindServerState = class(FindServerState)
FindServerState.NAME = "FindServerState"

function FindServerState:init(state_machine, search_type, network_options, ip_port)
	print("Attempting " .. search_type .. " search for game server " .. ip_port)
	assert(search_type == "internet" or search_type == "lan")
	self._search_type = search_type


	self._network_options = network_options


	self._ip_port = ip_port
end

function FindServerState:enter()

	self._finder = GameServerFinder:new(self._network_options)


	self._finder:set_search_type(self._search_type)

	local game_server_requirements = {
		server_browser_filters = { dedicated = "valuenotused",
			gamedir = Managers.mechanism:server_universe() },


		matchmaking_filters = { } }

	local skip_verify_lobby_data = true
	self._finder:add_filter_requirements(game_server_requirements, skip_verify_lobby_data)

	self._finder:refresh()
end

function FindServerState:destroy()
	self._finder:destroy()
	self._finder = nil
end

function FindServerState:update(dt)
	self._finder:update(dt)
	if self._finder:is_refreshing() then
		return
	end




	local servers = self._finder:servers()
	for _, server in ipairs(servers) do
		if server.server_info.ip_port == self._ip_port then
			print("Found server " .. self._ip_port)


			if server.server_info.password then
				do return "password_required" end
			else
				local password = ""
				return "password_not_required", password
			end
		end
	end
	print("Server not found")
	return "server_not_found"
end







local FindServerLANState = class(FindServerLANState, FindServerState)
FindServerLANState.NAME = "FindServerLANState"

function FindServerLANState:init(state_machine, network_options, ip_port)
	self.super.init(self, state_machine, "lan", network_options, ip_port)
end







local FindServerInternetState = class(FindServerInternetState, FindServerState)
FindServerInternetState.NAME = "FindServerInternetState"

function FindServerInternetState:init(state_machine, network_options, ip_port)
	self.super.init(self, state_machine, "internet", network_options, ip_port)
end







local PasswordDialogState = class(PasswordDialogState)
PasswordDialogState.NAME = "PasswordDialogState"

function PasswordDialogState:init(state_machine)
	self._popup_id = Managers.popup:queue_password_popup(Localize("lb_password"), Localize("lb_password_protected"), "ok", Localize("lb_ok"), "cancel", Localize("lb_cancel"))
end

function PasswordDialogState:destroy()
	Managers.popup:cancel_popup(self._popup_id)
	self._popup_id = nil
end

function PasswordDialogState:update()
	local result, params = Managers.popup:query_result(self._popup_id)
	if result then
		if result == "ok" then
			local password = params.input
			do return "password_entered", password end
		else
			return "password_cancelled"
		end
	end
end







local ServerJoinState = class(ServerJoinState)
ServerJoinState.NAME = "ServerJoinState"

function ServerJoinState:init(state_machine)
	self._sm = state_machine
end

function ServerJoinState:enter(password)
	self._sm._action = "join"
	self._sm._password = password
end







local AbortState = class(AbortState)
AbortState.NAME = "AbortState"

function AbortState:init(state_machine)
	state_machine._action = "cancel"
	state_machine._password = ""
end












ServerJoinStateMachine = class(ServerJoinStateMachine, VisualStateMachine)


function ServerJoinStateMachine:init(network_options, ip_port, user_data)
	local parent = nil
	self.super.init(self, "ServerJoinStateMachine", parent, network_options, ip_port)


	self._has_result = false

	self._server_data = nil

	self._ip_port = ip_port

	self._user_data = user_data

	self._action = nil

	self._password = nil

	self:add_transition("FindServerInternetState", "password_required", PasswordDialogState)
	self:add_transition("FindServerInternetState", "password_not_required", ServerJoinState)
	self:add_transition("FindServerInternetState", "server_not_found", FindServerLANState)
	self:add_transition("FindServerLANState", "password_required", PasswordDialogState)
	self:add_transition("FindServerLANState", "password_not_required", ServerJoinState)
	self:add_transition("FindServerLANState", "server_not_found", PasswordDialogState)
	self:add_transition("PasswordDialogState", "password_entered", ServerJoinState)
	self:add_transition("PasswordDialogState", "password_cancelled", AbortState)
	self:set_initial_state(FindServerInternetState)
end





function ServerJoinStateMachine:result()
	if self._action == nil then
		return
	end
	return self._action, self._user_data, self._password
end