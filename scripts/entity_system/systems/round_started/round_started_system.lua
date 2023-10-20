RoundStartedSystem = class(RoundStartedSystem, ExtensionSystemBase)

local extensions = { "RoundStartedExtension" }



local RPCS = { "rpc_round_started" }



RoundStartedExtension = class(RoundStartedExtension)

function RoundStartedExtension:init()
	return end

function RoundStartedExtension:destroy()
	return end


function RoundStartedSystem:init(context, system_name)
	local entity_manager = context.entity_manager
	entity_manager:register_system(self, system_name, extensions)

	self._is_server = context.is_server
	self._world = context.world

	self._network_event_delegate = context.network_event_delegate
	self._network_event_delegate:register(self, unpack(RPCS))

	self._start_area = "start_area"

	self._round_started = false
	self._player_spawned = false
	self._units = { }
end

function RoundStartedSystem:destroy()
	self._network_event_delegate:unregister(self)
end

function RoundStartedSystem:set_start_area(volume_name)
	local level = LevelHelper:current_level(self._world)
	local level_name = LevelHelper:current_level_settings(self._world).level_name


	self._start_area = volume_name
end

function RoundStartedSystem:on_add_extension(world, unit, extension_name, extension_init_data)
	ScriptUnit.add_extension(nil, unit, "RoundStartedExtension", self.NAME, extension_init_data)
	self._units [unit] = true

	local ext = ScriptUnit.extension(unit, self.NAME)

	return ext
end

function RoundStartedSystem:on_remove_extension(unit, extension_name)
	ScriptUnit.remove_extension(unit, self.NAME)
	self._units [unit] = nil
end

function RoundStartedSystem:hot_join_sync(sender, player)

	return end

function RoundStartedSystem:update(context, t)
	if not self._is_server or self._round_started then
		return
	end

	local started = self:_players_left_start_area()

	if started then
		Managers.state.game_mode:round_started()


		local level_settings = LevelHelper:current_level_settings()
		local score_type = level_settings.score_type
		if score_type then
			local start_data = { start_time = t }
			local leaderboard_system = Managers.state.entity:system("leaderboard_system")
			leaderboard_system:round_started(score_type, start_data)
		end

		self:_on_round_started()
	end
end

function RoundStartedSystem:_players_left_start_area()
	local checkpoint_data = Managers.state.spawn:checkpoint_data()
	local volume_name = checkpoint_data and checkpoint_data.safe_zone_volume_name or self._start_area
	local level = LevelHelper:current_level(self._world)

	if not Level.has_volume(level, volume_name) then
		if script_data.debug_level then
			Application.warning("Level is missing start area.")
		end
		return self._player_spawned
	end

	for unit, _ in pairs(self._units) do
		local pos = POSITION_LOOKUP [unit]
		if not Level.is_point_inside_volume(level, volume_name, pos) then

			return true
		end
	end

	return false
end

function RoundStartedSystem:player_spawned()
	self._player_spawned = true
end

function RoundStartedSystem:_on_round_started()
	self._round_started = true
	Managers.state.achievement:trigger_event("on_round_started")

	if self._is_server then
		Managers.state.network.network_transmit:send_rpc_clients("rpc_round_started")
	end
end

function RoundStartedSystem:rpc_round_started()
	self:_on_round_started()
end