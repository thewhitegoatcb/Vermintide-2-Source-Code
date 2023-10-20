BelakorBalancing = { crystal_throw_speed = 5, homing_skulls_min_time_between_spawns = 20, totem_despawn_distance = 35, homing_skulls_retry_time_on_spawn_failure = 3, homing_skulls_minimum_count = 3, homing_skulls_distance_between_skulls = 2, homing_skulls_maximum_count = 5, captains_chance_per_spawn = 0.5, totem_panic_decal_duration = 1.5, homing_skulls_max_time_between_spawns = 30, homing_skulls_min_distance_above_ground = 2, homing_skulls_vertical_offset_multiplier = 0.1, totem_spawns_distance = 50, totem_decal_duration = 2, homing_skulls_debuff_movespeed_multiplier = 0.5, homing_skulls_debuff_movespeed_duration = 2, homing_skulls_vertical_offset_frequency_multiplier = 4, homing_skulls_lerp_constant = 10, totem_spawn_cooldown = 1, totem_distance_despawn_time = 10, homing_skulls_radius = 10, homing_skulls_max_speed_multiplier = 0.02, totem_crystal_count = 1, homing_skulls_base_speed = 375, captains_stop_spawning_when_crystal_count = 2, harder_spawn_interval = 3, statue_health = 50, homing_skulls_min_speed_multiplier = 0.009, captains_max_marked_enemies = 1,





	captains_possible_enemies = { chaos_marauder = true, chaos_raider = true, skaven_plague_monk = true, beastmen_bestigor = true, chaos_berzerker = true, skaven_clan_rat_with_shield = true, skaven_storm_vermin_with_shield = true, chaos_marauder_with_shield = true, chaos_fanatic = true, skaven_slave = true, skaven_clan_rat = true, beastmen_ungor = true, chaos_warrior = true, skaven_storm_vermin_commander = true, skaven_storm_vermin = true, beastmen_gor = true, skaven_storm_vermin_champion = true },



























	totem_health = { 120, 120, 120, 120, 120, 120, 120, 120 },





























	homing_skulls_min_pitch = math.pi * 0.1,
	homing_skulls_max_pitch = math.pi * 0.25,
	homing_skulls_pitch_delta = math.pi * 0.05,
	homing_skulls_yaw_delta = 2 * math.pi / 10,










	homing_skulls_speed_multiplier_curve_func = function (lifetime)



		return -(1 / (math.min(lifetime + 2, 4) / 4)) + 2
	end }