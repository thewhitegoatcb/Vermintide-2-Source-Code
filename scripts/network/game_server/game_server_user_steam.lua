require("scripts/network/game_server/game_server_aux")

GameServerInternal = GameServerInternal or { }

GameServerInternal.lobby_data_version = 2


function GameServerInternal.join_server(game_server_info, password)
	local ip_address = game_server_info.ip_port
	local use_eac = true
	local game_server_lobby = Network.join_steam_server(use_eac, ip_address, password)
	SteamGameServerLobby.auto_update_data(game_server_lobby)
	return game_server_lobby
end


function GameServerInternal.reserve_server(game_server_info, password, reserve_peers)
	local ip_address = game_server_info.ip_port
	local use_eac = true
	local game_server_lobby = Network.reserve_steam_server(use_eac, reserve_peers, ip_address, password)
	SteamGameServerLobby.auto_update_data(game_server_lobby)
	return game_server_lobby
end


function GameServerInternal.claim_reserved(game_server_lobby)
	SteamGameServerLobby.join(game_server_lobby)
end

if not DEDICATED_SERVER then
	function GameServerInternal.open_channel(lobby, peer)
		local channel_id = SteamGameServerLobby.open_channel(lobby, peer)
		print("LobbyInternal.open_channel lobby: %s, to peer: %s channel: %s", lobby, peer, channel_id)
		return channel_id
	end

	function GameServerInternal.close_channel(lobby, channel)
		print("LobbyInternal.close_channel lobby: %s, channel: %s", lobby, channel)
		SteamGameServerLobby.close_channel(lobby, channel)
	end
end

function GameServerInternal.leave_server(game_server_lobby)
	Network.leave_steam_server(game_server_lobby)
end

function GameServerInternal.lobby_host(game_server_lobby)
	return SteamGameServerLobby.game_session_host(game_server_lobby)
end

function GameServerInternal.lobby_id(game_server_lobby)
	return SteamGameServerLobby.game_session_host(game_server_lobby)
end



function GameServerInternal.server_browser()
	return GameServerInternal._browser_wrapper
end

function GameServerInternal.clear_filter_requirements()
	local browser_wrapper = GameServerInternal._browser_wrapper
	browser_wrapper:clear_filters()
end

function GameServerInternal.add_filter_requirements(requirements)
	local browser_wrapper = GameServerInternal._browser_wrapper
	browser_wrapper:clear_filters()
	browser_wrapper:add_filters(requirements)
end


function GameServerInternal.forget_server_browser()
	if GameServerInternal._browser_wrapper then
		GameServerInternal._browser_wrapper:destroy()
		GameServerInternal._browser_wrapper = nil
	end
end



function GameServerInternal.create_server_browser_wrapper()
	fassert(GameServerInternal._browser_wrapper == nil, "Already has server browser wrapper")
	GameServerInternal._browser_wrapper = SteamServerBrowserWrapper:new()
	return GameServerInternal._browser_wrapper
end

SteamServerBrowserWrapper = class(SteamServerBrowserWrapper)

SteamServerBrowserWrapper.compare_funcs = {
	equal = function (lhv, rhv) return lhv == tostring(rhv) end,
	not_equal = function (lhv, rhv) return lhv ~= tostring(rhv) end,
	less = function (lhv, rhv) return tonumber(lhv) < rhv end,
	less_or_equal = function (lhv, rhv) return tonumber(lhv) <= rhv end,
	greater = function (lhv, rhv) return rhv < tonumber(lhv) end,
	greater_or_equal = function (lhv, rhv) return rhv <= tonumber(lhv) end }

SteamServerBrowserWrapper.compare_func_names = { greater_or_equal = ">=", less_or_equal = "<=", greater = ">", less = "<", equal = "==", not_equal = "~=" }








function SteamServerBrowserWrapper:init()

	self._engine_browser = LobbyInternal.client:create_server_browser()

	self._cached_servers = { }
	self._filters = { }

	self._search_type = "internet"

	self._state = "waiting"
end

function SteamServerBrowserWrapper:destroy()
	LobbyInternal.client:destroy_server_browser(self._engine_browser)
end

function SteamServerBrowserWrapper:servers()
	return self._cached_servers
end

function SteamServerBrowserWrapper:is_refreshing()
	local state = self._state
	return state == "refreshing" or state == "fetching_data"
end

function SteamServerBrowserWrapper:refresh()
	if SteamServerBrowser.is_refreshing(self._engine_browser) then
		SteamServerBrowser.abort_refresh(self._engine_browser)
	end

	SteamServerBrowser.refresh(self._engine_browser, self._search_type)

	self._state = "refreshing"
end

function SteamServerBrowserWrapper:set_search_type(search_type)
	self._search_type = search_type
end

function SteamServerBrowserWrapper:add_to_favorites(ip, connection_port, query_port)
	SteamServerBrowser.add_favorite(self._engine_browser, ip, connection_port, query_port)
end

function SteamServerBrowserWrapper:remove_from_favorites(ip, connection_port, query_port)
	SteamServerBrowser.remove_favorite(self._engine_browser, ip, connection_port, query_port)
end

function SteamServerBrowserWrapper:clear_filters()
	SteamServerBrowser.clear_filters(self._engine_browser)
	table.clear(self._filters)
end

function SteamServerBrowserWrapper:add_filters(filters)
	local server_browser_filters = filters.server_browser_filters
	for key, value in pairs(server_browser_filters) do
		SteamServerBrowser.add_filter(self._engine_browser, key, value)
		mm_printf("Adding server filter: key(%s) value=%s", key, value)
	end

	local matchmaking_filters = filters.matchmaking_filters
	for data_name, filter in pairs(matchmaking_filters) do
		local value = filter.value
		local comparison = filter.comparison

		local compare_func = SteamServerBrowserWrapper.compare_funcs [comparison]
		fassert(compare_func, "Compare func does not exist for comparison(%s)", comparison)
		local compare_name = SteamServerBrowserWrapper.compare_func_names [comparison]

		self._filters [data_name] = {
			value = value,
			compare_name = compare_name,
			compare_func = compare_func }


		mm_printf("Server Filter: %s, comparison(%s), value=%s", tostring(data_name), tostring(comparison), tostring(value))
	end
end

function SteamServerBrowserWrapper:update(dt, t)
	local state = self._state

	if state == "refreshing" then
		if not SteamServerBrowser.is_refreshing(self._engine_browser) then
			local num_servers = SteamServerBrowser.num_servers(self._engine_browser)

			for i = 0, num_servers - 1 do
				SteamServerBrowser.request_data(self._engine_browser, i)
			end

			self._state = "fetching_data"
		end
	elseif state == "fetching_data" then
		local is_fetching = false

		local num_servers = SteamServerBrowser.num_servers(self._engine_browser)
		for i = 0, num_servers - 1 do
			local is_fetching_data, fetch_error = SteamServerBrowser.is_fetching_data(self._engine_browser, i)

			if is_fetching_data then
				is_fetching = true
				break
			end
		end



		if not is_fetching then
			local cached_servers = self._cached_servers
			table.clear(cached_servers)

			for i = 0, num_servers - 1 do
				local server = SteamServerBrowser.server(self._engine_browser, i)

				server.ip_port = server.ip_address .. ":" .. server.query_port

				local lobby_data = SteamServerBrowser.data_all(self._engine_browser, i)
				lobby_data.server_info = server

				if self:_filter_server(lobby_data) then
					cached_servers [#cached_servers + 1] = lobby_data
				end
			end

			self._state = "waiting"
		end
	end

	if self._state ~= state then
		printf("[SteamServerBrowserWrapper] Switched state from (%s) to (%s)", state, self._state)
	end
end

function SteamServerBrowserWrapper:_filter_server(server_data)
	local filters = self._filters
	for data_name, filter in pairs(filters) do
		local server_value = server_data [data_name]

		if not server_value then
			printf("[SteamServerBrowserWrapper] Could not find value for server (%s)", data_name)
			do return false end
		else
			printf("[SteamServerBrowserWrapper] Found value %s, %s from server", tostring(server_value), data_name)
		end

		local compare_value = filter.value
		local compare_func = filter.compare_func
		local compare_name = filter.compare_name

		if not compare_func(server_value, compare_value) then
			printf("[SteamServerBrowserWrapper] Server failed on filter %s, server_value(%s) %s compare_value=(%s)", data_name, server_value, compare_name, compare_value)
			return false
		end
	end

	return true
end