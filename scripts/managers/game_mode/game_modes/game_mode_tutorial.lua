require("scripts/managers/game_mode/game_modes/game_mode_base")

script_data.disable_gamemode_end = script_data.disable_gamemode_end or Development.parameter("disable_gamemode_end")

GameModeTutorial = class(GameModeTutorial, GameModeBase)

local COMPLETE_LEVEL_VAR = false
local FAIL_LEVEL_VAR = false

function GameModeTutorial:init(settings, world, ...)
	GameModeTutorial.super.init(self, settings, world, ...)

	local hero_side = Managers.state.side:get_side_from_name("heroes")
	self._adventure_spawning = AdventureSpawning:new(self._profile_synchronizer, hero_side, self._is_server, self._network_server)
	self:_register_player_spawner(self._adventure_spawning)

	self:_switch_profile_to_tutorial()

	local event_manager = Managers.state.event
	event_manager:register(self, "level_start_local_player_spawned", "event_local_player_spawned")

	self.about_to_lose = false
	self.lost_condition_timer = nil
	self._hud_disabled = false

	self._bot_players = { }
end

function GameModeTutorial:_switch_profile_to_tutorial()
	local peer_id = Network.peer_id()
	local local_player_id = 1

	local profile_index, career_index = self._profile_synchronizer:profile_by_peer(peer_id, local_player_id)
	if profile_index and career_index then
		self._previous_profile_index = profile_index
		self._previous_career_index = career_index
	end

	local tutorial_profile_name = PROFILES_BY_AFFILIATION.tutorial [1]
	self._tutorial_profile_index = FindProfileIndex(tutorial_profile_name)
	self._tutorial_career_index = 1

	self._local_player_spawned = false

	local is_bot = false
	self._profile_synchronizer:assign_full_profile(peer_id, local_player_id, self._tutorial_profile_index, self._tutorial_career_index, is_bot)
end

function GameModeTutorial:_switch_back_to_previous_profile()
	local peer_id = Network.peer_id()
	local local_player_id = 1

	local prev_profile = self._previous_profile_index local prev_career = self._previous_career_index
	if prev_profile and prev_career then
		local is_bot = false
		self._profile_synchronizer:assign_full_profile(peer_id, local_player_id, prev_profile, prev_career, is_bot)
	else
		self._profile_synchronizer:unassign_profiles_of_peer(peer_id, local_player_id)
	end
end

function GameModeTutorial:register_rpcs(network_event_delegate, network_transmit)
	GameModeTutorial.super.register_rpcs(self, network_event_delegate, network_transmit)

	self._adventure_spawning:register_rpcs(network_event_delegate, network_transmit)
end

function GameModeTutorial:unregister_rpcs()
	self._adventure_spawning:unregister_rpcs()

	GameModeTutorial.super.unregister_rpcs(self)
end

function GameModeTutorial:player_entered_game_session(peer_id, local_player_id, wanted_party_index)
	GameModeTutorial.super.player_entered_game_session(self, peer_id, local_player_id, wanted_party_index)

	local _, current_party_id = Managers.party:get_party_from_player_id(peer_id, local_player_id)
	if current_party_id ~= 1 then
		local party_id = 1
		Managers.party:request_join_party(peer_id, local_player_id, party_id)
	end
end

function GameModeTutorial:event_local_player_spawned(is_initial_spawn)
	self._local_player_spawned = true
	self._is_initial_spawn = is_initial_spawn
end

function GameModeTutorial:destroy()
	self:_switch_back_to_previous_profile()
end

function GameModeTutorial:cleanup_game_mode_units()
	self:_clear_bots()
end

function GameModeTutorial:_clear_bots()
	local bot_players = self._bot_players
	local num_bot_players = #bot_players
	for i = num_bot_players, 1, -1 do
		self:_remove_bot(bot_players, i)
	end
end

function GameModeTutorial:add_bot(profile_index, career_index)
	local bot_players = self._bot_players

	local party_id = 1
	local bot_player = self:_add_bot_to_party(party_id, profile_index, career_index)
	bot_players [#bot_players + 1] = bot_player
end

function GameModeTutorial:_remove_bot(bot_players, index)
	local bot_player = bot_players [index]
	fassert(bot_player, "No bot player at index (%s)", tostring(index))

	self:_remove_bot_instant(bot_player)

	local last = #bot_players
	bot_players [index] = bot_players [last]
	bot_players [last] = nil
end

function GameModeTutorial:update(t, dt)
	self._adventure_spawning:update(t, dt)
end

function GameModeTutorial:server_update(t, dt)
	self._adventure_spawning:server_update(t, dt)
end

function GameModeTutorial:evaluate_end_conditions(round_started, dt, t)
	if COMPLETE_LEVEL_VAR then
		self:complete_level()
		COMPLETE_LEVEL_VAR = false
	end
end

function GameModeTutorial:mutators()
	return end

function GameModeTutorial:complete_level()
	StatisticsUtil.register_complete_tutorial(Managers.state.game_mode.statistics_db)

	local backend_manager = Managers.backend
	local stats_interface = backend_manager:get_interface("statistics")

	stats_interface:save()

	backend_manager:commit(true)

	self._transition = "finish_tutorial"
end

function GameModeTutorial:wanted_transition()
	return self._transition
end

function GameModeTutorial:COMPLETE_LEVEL()
	COMPLETE_LEVEL_VAR = true
end

function GameModeTutorial:game_mode_hud_disabled()
	return self._hud_disabled
end

function GameModeTutorial:disable_hud(disable)
	self._hud_disabled = disable
end

function GameModeTutorial:FAIL_LEVEL()
	FAIL_LEVEL_VAR = true
end
function GameModeTutorial:disable_player_spawning()
	self._adventure_spawning:set_spawning_disabled(true)
end

function GameModeTutorial:enable_player_spawning(safe_position, safe_rotation)
	self._adventure_spawning:set_spawning_disabled(false)
	self._adventure_spawning:force_update_spawn_positions(safe_position, safe_rotation)
end

function GameModeTutorial:teleport_despawned_players(position)
	self._adventure_spawning:teleport_despawned_players(position)
end

function GameModeTutorial:flow_callback_add_spawn_point(unit)
	self._adventure_spawning:add_spawn_point(unit)
end

function GameModeTutorial:set_override_respawn_group(respawn_group_name, active)
	self._adventure_spawning:set_override_respawn_group(respawn_group_name, active)
end

function GameModeTutorial:set_respawn_group_enabled(respawn_group_name, active)
	self._adventure_spawning:set_respawn_group_enabled(respawn_group_name, active)
end

function GameModeTutorial:set_respawn_gate_enabled(respawn_gate_unit, enabled)
	self._adventure_spawning:set_respawn_gate_enabled(respawn_gate_unit, enabled)
end

function GameModeTutorial:respawn_unit_spawned(unit)
	self._adventure_spawning:respawn_unit_spawned(unit)
end

function GameModeTutorial:get_respawn_handler()
	return self._adventure_spawning:get_respawn_handler()
end

function GameModeTutorial:respawn_gate_unit_spawned(unit)
	self._adventure_spawning:respawn_gate_unit_spawned(unit)
end

function GameModeTutorial:set_respawning_enabled(enabled)
	self._adventure_spawning:set_respawning_enabled(enabled)
end

function GameModeTutorial:remove_respawn_units_due_to_crossroads(removed_path_distances, total_main_path_length)
	self._adventure_spawning:remove_respawn_units_due_to_crossroads(removed_path_distances, total_main_path_length)
end

function GameModeTutorial:recalc_respawner_dist_due_to_crossroads()
	self._adventure_spawning:recalc_respawner_dist_due_to_crossroads()
end

function GameModeTutorial:force_respawn_dead_players()
	self._adventure_spawning:force_respawn_dead_players()
end

function GameModeTutorial:get_active_respawn_units()
	return self._adventure_spawning:get_active_respawn_units()
end

function GameModeTutorial:get_end_screen_config(game_won, game_lost, player)
	local screen_name = nil local screen_config = { }
	if game_won then
		screen_name = "victory"

		local stats_id = player:stats_id()
		local statistics_db = self._statistics_db
		local level_key = self._level_key
		local previous_completed_difficulty_index = LevelUnlockUtils.completed_level_difficulty_index(statistics_db, stats_id, level_key) or 0

		screen_config = {
			level_key = level_key,
			previous_completed_difficulty_index = previous_completed_difficulty_index }
	else

		screen_name = "defeat"
	end

	return screen_name, screen_config
end


function GameModeTutorial:ended(reason)

	local all_peers_ingame = self._network_server:are_all_peers_ingame()

	if not all_peers_ingame then
		self._network_server:disconnect_joining_peers()
	end
end

function GameModeTutorial:local_player_ready_to_start(player)

	if not self._local_player_spawned then
		return false
	end

	return true
end

function GameModeTutorial:local_player_game_starts(player, loading_context)
	if self._is_initial_spawn then
		LevelHelper:flow_event(self._world, "local_player_spawned")
		if Development.parameter("attract_mode") then
			LevelHelper:flow_event(self._world, "start_benchmark")
		else
			LevelHelper:flow_event(self._world, "level_start_local_player_spawned")
		end
	end
end