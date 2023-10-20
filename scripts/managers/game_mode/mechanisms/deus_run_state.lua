require("scripts/helpers/deus_power_up_utils")
require("scripts/network/shared_state")
local shared_state_spec = require("scripts/managers/game_mode/mechanisms/deus_run_state_spec")

























DeusRunState = class(DeusRunState)

function DeusRunState:init(run_id, is_server, network_handler, server_peer_id, own_peer_id, own_initial_loadout, own_initial_talents, weapon_group_whitelist)
	self._run_id = run_id
	self._is_server = is_server
	self._server_peer_id = server_peer_id
	self._own_peer_id = own_peer_id
	self._network_handler = network_handler

	local run_state_id_key = "deus_run_state_" .. run_id
	self._shared_state = SharedState:new(run_state_id_key, shared_state_spec, is_server, network_handler, server_peer_id, own_peer_id)

	self._own_initial_loadout = own_initial_loadout
	self._own_initial_talents = own_initial_talents
	self._weapon_group_whitelist = weapon_group_whitelist
end

function DeusRunState:network_context_created(lobby, server_peer_id, own_peer_id, is_server, network_handler)
	self._is_server = is_server
	self._server_peer_id = server_peer_id
	self._network_handler = network_handler
	self._shared_state:network_context_created(lobby, server_peer_id, own_peer_id, is_server, network_handler)
end

function DeusRunState:register_rpcs(network_event_delegate)
	self._shared_state:register_rpcs(network_event_delegate)
end

function DeusRunState:unregister_rpcs()
	self._shared_state:unregister_rpcs()
end

function DeusRunState:full_sync()
	self._shared_state:full_sync()
end

function DeusRunState:destroy()
	self:unregister_rpcs()
	self._shared_state:destroy()
end

function DeusRunState:get_revision()
	return self._shared_state:get_revision()
end

function DeusRunState:is_server()
	return self._is_server
end

function DeusRunState:get_server_peer_id()
	return self._server_peer_id
end

function DeusRunState:get_own_peer_id()
	return self._own_peer_id
end

function DeusRunState:get_own_initial_loadout()
	return self._own_initial_loadout
end

function DeusRunState:get_own_initial_talents()
	return self._own_initial_talents
end

function DeusRunState:get_weapon_group_whitelist()
	return self._weapon_group_whitelist
end





function DeusRunState:set_run_ended(value)
	self._shared_state:set_server(self._shared_state:get_key("run_ended"), value)
end

function DeusRunState:get_run_ended()
	return self._shared_state:get_server(self._shared_state:get_key("run_ended"))
end

function DeusRunState:set_run_seed(run_seed)
	self._run_seed = run_seed
end

function DeusRunState:set_run_difficulty(difficulty)
	self._difficulty = difficulty
end

function DeusRunState:get_run_difficulty()
	return self._difficulty
end

function DeusRunState:set_journey_name(journey_name)
	self._journey_name = journey_name
end

function DeusRunState:get_journey_name()
	return self._journey_name
end

function DeusRunState:set_dominant_god(dominant_god)
	self._dominant_god = dominant_god
end

function DeusRunState:get_dominant_god()
	return self._dominant_god
end

function DeusRunState:get_run_id()
	return self._run_id
end

function DeusRunState:get_run_seed()
	return self._run_seed
end

function DeusRunState:set_current_node_key(node_key)
	self._shared_state:set_server(self._shared_state:get_key("run_node_key"), node_key)
end

function DeusRunState:get_current_node_key()
	return self._shared_state:get_server(self._shared_state:get_key("run_node_key"))
end

function DeusRunState:get_completed_level_count()
	return self._shared_state:get_server(self._shared_state:get_key("completed_level_count")) or 0
end

function DeusRunState:set_completed_level_count(count)
	self._shared_state:set_server(self._shared_state:get_key("completed_level_count"), count)
end

function DeusRunState:get_traversed_nodes()
	return self._shared_state:get_server(self._shared_state:get_key("traversed_nodes"))
end

function DeusRunState:set_traversed_nodes(traversed_nodes_array)
	self._shared_state:set_server(self._shared_state:get_key("traversed_nodes"), traversed_nodes_array)
end

function DeusRunState:get_blessings()
	local blessings_with_buyer = self._shared_state:get_server(self._shared_state:get_key("blessings_with_buyer"))


	local blessings_array = { }
	for blessing, _ in pairs(blessings_with_buyer) do
		blessings_array [#blessings_array + 1] = blessing
	end

	return blessings_array
end

function DeusRunState:get_blessings_with_buyer()
	return self._shared_state:get_server(self._shared_state:get_key("blessings_with_buyer"))
end

function DeusRunState:set_blessings_with_buyer(blessings_with_buyer)
	self._shared_state:set_server(self._shared_state:get_key("blessings_with_buyer"), blessings_with_buyer)
end

function DeusRunState:get_blessing_lifetime(blessing_name)
	local blessing_lifetimes = self._shared_state:get_server(self._shared_state:get_key("blessing_lifetimes"))

	return blessing_lifetimes [blessing_name] or 0
end

function DeusRunState:set_blessing_lifetime(blessing_name, lifetime)
	local blessing_lifetimes = self._shared_state:get_server(self._shared_state:get_key("blessing_lifetimes"))

	local skip_metatable = true
	blessing_lifetimes = table.clone(blessing_lifetimes, skip_metatable)

	blessing_lifetimes [blessing_name] = lifetime
	self._shared_state:set_server(self._shared_state:get_key("blessing_lifetimes"), blessing_lifetimes)
end

function DeusRunState:get_peer_initialized(peer_id)
	local key = self._shared_state:get_key("peer_initialized", peer_id)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_peer_initialized(peer_id, initialized)
	local key = self._shared_state:get_key("peer_initialized", peer_id)
	self._shared_state:set_server(key, initialized)
end

function DeusRunState:get_profile_initialized(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("profile_initialized", peer_id, local_player_id, profile_index, career_index)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_profile_initialized(peer_id, local_player_id, profile_index, career_index, initialized)
	local key = self._shared_state:get_key("profile_initialized", peer_id, local_player_id, profile_index, career_index)
	self._shared_state:set_server(key, initialized)
end

function DeusRunState:get_cursed_levels_completed(peer_id)
	local key = self._shared_state:get_key("cursed_levels_completed", peer_id)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_cursed_levels_completed(peer_id, count)
	local key = self._shared_state:get_key("cursed_levels_completed", peer_id)
	self._shared_state:set_server(key, count)
end

function DeusRunState:get_cursed_chests_purified(peer_id)
	local key = self._shared_state:get_key("cursed_chests_purified", peer_id)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_cursed_chests_purified(peer_id, count)
	local key = self._shared_state:get_key("cursed_chests_purified", peer_id)
	self._shared_state:set_server(key, count)
end

function DeusRunState:get_coin_chests_collected(peer_id)
	local key = self._shared_state:get_key("coin_chests_collected", peer_id)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_coin_chests_collected(peer_id, count)
	local key = self._shared_state:get_key("coin_chests_collected", peer_id)
	self._shared_state:set_server(key, count)
end

function DeusRunState:get_party_power_ups()
	local key = self._shared_state:get_key("party_power_ups")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_party_power_ups(power_ups)
	local key = self._shared_state:get_key("party_power_ups")
	self._shared_state:set_server(key, power_ups)
end

function DeusRunState:get_bought_power_ups()
	local key = self._shared_state:get_key("bought_power_ups")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_bought_power_ups(bought_power_ups)
	local key = self._shared_state:get_key("bought_power_ups")
	self._shared_state:set_server(key, bought_power_ups)
end

function DeusRunState:get_bought_blessings()
	local key = self._shared_state:get_key("bought_blessings")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_bought_blessings(bought_blessings)
	local key = self._shared_state:get_key("bought_blessings")
	self._shared_state:set_server(key, bought_blessings)
end

function DeusRunState:get_ground_coins_picked_up()
	local key = self._shared_state:get_key("ground_coins_picked_up")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_ground_coins_picked_up(coin_count)
	local key = self._shared_state:get_key("ground_coins_picked_up")
	self._shared_state:set_server(key, coin_count)
end

function DeusRunState:get_monster_coins_picked_up()
	local key = self._shared_state:get_key("monster_coins_picked_up")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_monster_coins_picked_up(coin_count)
	local key = self._shared_state:get_key("monster_coins_picked_up")
	self._shared_state:set_server(key, coin_count)
end

function DeusRunState:get_coins_spent()
	local key = self._shared_state:get_key("coins_spent")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_coins_spent(coin_count)
	local key = self._shared_state:get_key("coins_spent")
	self._shared_state:set_server(key, coin_count)
end

function DeusRunState:get_coins_earned()
	local key = self._shared_state:get_key("coins_earned")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_coins_earned(coin_count)
	local key = self._shared_state:get_key("coins_earned")
	self._shared_state:set_server(key, coin_count)
end

function DeusRunState:get_melee_swap_chests_used()
	local key = self._shared_state:get_key("melee_swap_chests_used")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_melee_swap_chests_used(value)
	local key = self._shared_state:get_key("melee_swap_chests_used")
	self._shared_state:set_server(key, value)
end

function DeusRunState:get_ranged_swap_chests_used()
	local key = self._shared_state:get_key("ranged_swap_chests_used")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_ranged_swap_chests_used(value)
	local key = self._shared_state:get_key("ranged_swap_chests_used")
	self._shared_state:set_server(key, value)
end

function DeusRunState:get_upgrade_chests_used()
	local key = self._shared_state:get_key("upgrade_chests_used")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_upgrade_chests_used(value)
	local key = self._shared_state:get_key("upgrade_chests_used")
	self._shared_state:set_server(key, value)
end

function DeusRunState:get_power_up_chests_used()
	local key = self._shared_state:get_key("power_up_chests_used")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_power_up_chests_used(value)
	local key = self._shared_state:get_key("power_up_chests_used")
	self._shared_state:set_server(key, value)
end

function DeusRunState:get_host_migration_count()
	local key = self._shared_state:get_key("host_migration_count")
	return self._shared_state:get_server(key)
end

function DeusRunState:set_host_migration_count(value)
	local key = self._shared_state:get_key("host_migration_count")
	self._shared_state:set_server(key, value)
end

function DeusRunState:get_belakor_enabled()
	return self._belakor_enabled
end

function DeusRunState:set_belakor_enabled(belakor_enabled)
	self._belakor_enabled = belakor_enabled
end

function DeusRunState:get_arena_belakor_node()
	local key = self._shared_state:get_key("arena_belakor_node")
	local value = self._shared_state:get_server(key)
	return value ~= "" and value or nil
end

function DeusRunState:set_arena_belakor_node(value)
	local key = self._shared_state:get_key("arena_belakor_node")
	self._shared_state:set_server(key, value)
end

function DeusRunState:get_seen_arena_belakor_node(peer_id)
	local key = self._shared_state:get_key("seen_arena_belakor_node", peer_id)
	local value = self._shared_state:get_server(key)
	return value ~= "" and value or nil
end

function DeusRunState:set_seen_arena_belakor_node(peer_id, value)
	local key = self._shared_state:get_key("seen_arena_belakor_node", peer_id)
	self._shared_state:set_server(key, value)
end

function DeusRunState:get_granted_non_party_end_of_level_power_ups(peer_id, local_player_id, profile_index, career_index)
	return self._shared_state:get_server(self._shared_state:get_key("granted_non_party_end_of_level_power_ups", peer_id, local_player_id, profile_index, career_index))
end

function DeusRunState:set_granted_non_party_end_of_level_power_ups(peer_id, local_player_id, profile_index, career_index, granted_non_party_end_of_level_power_ups_array)
	self._shared_state:set_server(self._shared_state:get_key("granted_non_party_end_of_level_power_ups", peer_id, local_player_id, profile_index, career_index), granted_non_party_end_of_level_power_ups_array)
end





function DeusRunState:get_player_profile(peer_id, local_player_id)
	local profile_index, career_index = self._network_handler.profile_synchronizer:profile_by_peer(peer_id, local_player_id)
	return profile_index or 0, career_index or 0
end





function DeusRunState:get_player_level(peer_id)
	return self._shared_state:get_peer(peer_id, self._shared_state:get_key("player_level"))
end

function DeusRunState:set_own_player_level(level)
	self._shared_state:set_own(self._shared_state:get_key("player_level"), level)
end

function DeusRunState:get_player_name(peer_id)
	return self._shared_state:get_peer(peer_id, self._shared_state:get_key("player_name"))
end

function DeusRunState:set_own_player_name(name)
	self._shared_state:set_own(self._shared_state:get_key("player_name"), name)
end

function DeusRunState:get_player_frame(peer_id)
	return self._shared_state:get_peer(peer_id, self._shared_state:get_key("player_frame"))
end

function DeusRunState:set_own_player_frame(frame)
	self._shared_state:set_own(self._shared_state:get_key("player_frame"), frame)
end





function DeusRunState:get_player_spawned_once(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("spawned_once", peer_id, local_player_id, profile_index, career_index)
	return self._shared_state:get_server(key) or false
end

function DeusRunState:set_player_spawned_once(peer_id, local_player_id, profile_index, career_index, player_spawned_once)
	local key = self._shared_state:get_key("spawned_once", peer_id, local_player_id, profile_index, career_index)
	self._shared_state:set_server(key, player_spawned_once)
end

function DeusRunState:get_player_power_ups(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("power_ups", peer_id, local_player_id, profile_index, career_index)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_player_power_ups(peer_id, local_player_id, profile_index, career_index, power_ups)
	local key = self._shared_state:get_key("power_ups", peer_id, local_player_id, profile_index, career_index)
	self._shared_state:set_server(key, power_ups)
end

function DeusRunState:get_player_persistent_buffs(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("persistent_buffs", peer_id, local_player_id, profile_index, career_index)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_player_persistent_buffs(peer_id, local_player_id, profile_index, career_index, persistent_buffs)
	local key = self._shared_state:get_key("persistent_buffs", peer_id, local_player_id, profile_index, career_index)
	self._shared_state:set_server(key, persistent_buffs)
end

function DeusRunState:get_player_soft_currency(peer_id, local_player_id)
	local key = self._shared_state:get_key("soft_currency", peer_id, local_player_id)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_player_soft_currency(peer_id, local_player_id, coins)
	local key = self._shared_state:get_key("soft_currency", peer_id, local_player_id)
	self._shared_state:set_server(key, coins)
end

function DeusRunState:get_player_health_percentage(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("health_percentage", peer_id, local_player_id, profile_index, career_index)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_player_health_percentage(peer_id, local_player_id, profile_index, career_index, health_percentage)
	local key = self._shared_state:get_key("health_percentage", peer_id, local_player_id, profile_index, career_index)
	self._shared_state:set_server(key, health_percentage)
end

function DeusRunState:get_player_health_state(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("health_state", peer_id, local_player_id, profile_index, career_index)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_player_health_state(peer_id, local_player_id, profile_index, career_index, health_state)
	local key = self._shared_state:get_key("health_state", peer_id, local_player_id, profile_index, career_index)
	self._shared_state:set_server(key, health_state)
end

function DeusRunState:get_player_melee_ammo(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("melee_ammo", peer_id, local_player_id, profile_index, career_index)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_player_melee_ammo(peer_id, local_player_id, profile_index, career_index, melee_ammo)
	local key = self._shared_state:get_key("melee_ammo", peer_id, local_player_id, profile_index, career_index)
	self._shared_state:set_server(key, melee_ammo)
end

function DeusRunState:get_player_ranged_ammo(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("ranged_ammo", peer_id, local_player_id, profile_index, career_index)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_player_ranged_ammo(peer_id, local_player_id, profile_index, career_index, ranged_ammo)
	local key = self._shared_state:get_key("ranged_ammo", peer_id, local_player_id, profile_index, career_index)
	self._shared_state:set_server(key, ranged_ammo)
end

function DeusRunState:get_player_consumable_healthkit_slot(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("healthkit", peer_id, local_player_id, profile_index, career_index)
	local val = self._shared_state:get_server(key)


	return val ~= "" and val or nil
end

function DeusRunState:set_player_consumable_healthkit_slot(peer_id, local_player_id, profile_index, career_index, item_name)
	local key = self._shared_state:get_key("healthkit", peer_id, local_player_id, profile_index, career_index)


	local val = item_name or ""
	self._shared_state:set_server(key, val)
end

function DeusRunState:get_player_consumable_potion_slot(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("potion", peer_id, local_player_id, profile_index, career_index)
	local val = self._shared_state:get_server(key)


	return val ~= "" and val or nil
end

function DeusRunState:set_player_consumable_potion_slot(peer_id, local_player_id, profile_index, career_index, item_name)
	local key = self._shared_state:get_key("potion", peer_id, local_player_id, profile_index, career_index)


	local val = item_name or ""
	self._shared_state:set_server(key, val)
end

function DeusRunState:get_player_consumable_grenade_slot(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("grenade", peer_id, local_player_id, profile_index, career_index)
	local val = self._shared_state:get_server(key)


	return val ~= "" and val or nil
end

function DeusRunState:set_player_consumable_grenade_slot(peer_id, local_player_id, profile_index, career_index, item_name)
	local key = self._shared_state:get_key("grenade", peer_id, local_player_id, profile_index, career_index)


	local val = item_name or ""
	self._shared_state:set_server(key, val)
end

function DeusRunState:get_player_additional_items(peer_id, local_player_id, profile_index, career_index)
	local key = self._shared_state:get_key("additional_items", peer_id, local_player_id, profile_index, career_index)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_player_additional_items(peer_id, local_player_id, profile_index, career_index, additional_items)
	local key = self._shared_state:get_key("additional_items", peer_id, local_player_id, profile_index, career_index)
	self._shared_state:set_server(key, additional_items)
end

function DeusRunState:get_player_loadout(peer_id, local_player_id, profile_index, career_index, slot)
	local key = self._shared_state:get_key(slot, peer_id, local_player_id, profile_index, career_index)
	local val = self._shared_state:get_server(key)


	return val ~= "" and val or nil
end

function DeusRunState:set_player_loadout(peer_id, local_player_id, profile_index, career_index, slot, serialized_deus_weapon)
	local key = self._shared_state:get_key(slot, peer_id, local_player_id, profile_index, career_index)


	self._shared_state:set_server(key, serialized_deus_weapon or "")
end

function DeusRunState:set_twitch_level_vote(node_key)

	self._shared_state:set_server(self._shared_state:get_key("twitch_vote"), node_key or "")
end

function DeusRunState:get_twitch_level_vote()
	local twitch_vote = self._shared_state:get_server(self._shared_state:get_key("twitch_vote"))

	if twitch_vote == "" then
		do return nil end
	else
		return twitch_vote
	end
end

function DeusRunState:set_scoreboard(scoreboard)
	self._scoreboard = scoreboard
end

function DeusRunState:get_scoreboard(scoreboard)
	return self._scoreboard
end

function DeusRunState:set_persisted_score(peer_id, local_player_id, persisted_score)
	local key = self._shared_state:get_key("persisted_score", peer_id, local_player_id)
	self._shared_state:set_server(key, persisted_score)
end

function DeusRunState:get_persisted_score(peer_id, local_player_id, persisted_score)
	local key = self._shared_state:get_key("persisted_score", peer_id, local_player_id)
	return self._shared_state:get_server(key)
end

function DeusRunState:set_own_weapon_pool_data(weapon_pool_data)
	self._weapon_pool_data = weapon_pool_data
end

function DeusRunState:get_own_weapon_pool_data()
	return self._weapon_pool_data
end

function DeusRunState:set_own_weapon_pool_excludes(pool_excludes)
	self._weapon_pool_excludes = pool_excludes
end

function DeusRunState:get_own_weapon_pool_excludes()











	return self._weapon_pool_excludes or { }
end

function DeusRunState:get_player_telemetry_id(peer_id)
	local key = self._shared_state:get_key("telemetry_id")
	return self._shared_state:get_peer(peer_id, key)
end

function DeusRunState:set_own_player_telemetry_id(telemetry_id)
	local key = self._shared_state:get_key("telemetry_id")
	self._shared_state:set_own(key, telemetry_id)
end