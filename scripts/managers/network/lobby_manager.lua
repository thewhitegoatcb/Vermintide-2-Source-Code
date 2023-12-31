
local network_options = { max_members = 4, project_hash = "bulldozer", config_file_name = "global", map = "None",


	lobby_port = LEVEL_EDITOR_TEST and GameSettingsDevelopment.editor_lobby_port or GameSettingsDevelopment.network_port,


	ip_address = Network.default_network_address() }



LobbyManager = class(LobbyManager)

function LobbyManager:init()
	self._network_options = nil




	self._lobby_port_increment = 0
end

function LobbyManager:network_hash()
	local config_file_name = network_options.config_file_name
	local project_hash = network_options.project_hash

	local disable_print = true
	return LobbyAux.create_network_hash(config_file_name, project_hash, disable_print, disable_print)
end

function LobbyManager:network_options()
	fassert(self._network_options, "Network options has not been set up yet.")
	return self._network_options
end

function LobbyManager:setup_network_options(increment_lobby_port)
	printf("[LobbyManager] Setting up network options")



	printf("server_port -> cmd-line: %s, settings.ini: %s, mechanism-settings: %s ", script_data.server_port, script_data.settings.server_port, Managers.mechanism:mechanism_setting("server_port"))
	printf("query_port -> cmd-line: %s, settings.ini: %s, mechanism-settings: %s ", script_data.query_port, script_data.settings.query_port, Managers.mechanism:mechanism_setting("query_port"))
	printf("steam_port -> cmd-line: %s, settings.ini: %s, mechanism-settings: %s ", script_data.steam_port, script_data.settings.steam_port, Managers.mechanism:mechanism_setting("steam_port"))
	printf("rcon_port -> cmd-line: %s, settings.ini: %s, mechanism-settings: %s ", script_data.rcon_port, script_data.settings.rcon_port, Managers.mechanism:mechanism_setting("rcon_port"))

	local server_port = script_data.server_port or script_data.settings.server_port or Managers.mechanism:mechanism_setting("server_port")
	local query_port = script_data.query_port or script_data.settings.query_port or Managers.mechanism:mechanism_setting("query_port")
	local steam_port = script_data.steam_port or script_data.settings.steam_port or Managers.mechanism:mechanism_setting("steam_port")
	local rcon_port = script_data.rcon_port or script_data.settings.rcon_port or Managers.mechanism:mechanism_setting("rcon_port")

	if increment_lobby_port and BUILD ~= "release" then
		self._lobby_port_increment = self._lobby_port_increment + 1
	end

	if not IS_WINDOWS and not IS_LINUX then
		server_port = network_options.lobby_port
	end

	network_options.server_port = server_port + self._lobby_port_increment
	network_options.query_port = query_port
	network_options.steam_port = steam_port
	network_options.rcon_port = rcon_port

	local max_members = Managers.mechanism:max_members()
	network_options.max_members = max_members

	printf("All ports: server_port %s query_port: %s, steam_port: %s, rcon_port: %s ", network_options.server_port, query_port, steam_port, rcon_port)

	self._network_options = network_options

	print("LobbyManager:setup_network_options server_port:", network_options.server_port)
end