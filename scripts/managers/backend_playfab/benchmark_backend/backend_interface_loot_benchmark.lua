BackendInterfaceLootBenchmark = class(BackendInterfaceLootBenchmark)

function BackendInterfaceLootBenchmark:init(backend_mirror)
	return end

function BackendInterfaceLootBenchmark:ready()
	return true
end

function BackendInterfaceLootBenchmark:update(dt)
	return end





function BackendInterfaceLootBenchmark:open_loot_chest(hero_name, backend_id)
	return 1
end

function BackendInterfaceLootBenchmark:loot_chest_rewards_request_cb(data, result)
	return end





function BackendInterfaceLootBenchmark:generate_end_of_level_loot(game_won, quick_play_bonus, difficulty, level_key, hero_name, start_experience, end_experience, loot_profile_name, deed_item_name, deed_backend_id, game_mode_key, game_time, end_of_level_rewards_arguments)
	return 1
end

function BackendInterfaceLootBenchmark:end_of_level_loot_request_cb(data, result)
	return end





function BackendInterfaceLootBenchmark:achievement_rewards_claimed(achievement_id)
	return nil
end


function BackendInterfaceLootBenchmark:can_claim_achievement_rewards(achievement_id)
	return false
end

function BackendInterfaceLootBenchmark:claim_achievement_rewards(achievement_id)
	return 1
end

function BackendInterfaceLootBenchmark:achievement_rewards_request_cb(data, result)
	return end





function BackendInterfaceLootBenchmark:is_loot_generated(id)
	return false
end

function BackendInterfaceLootBenchmark:get_loot(id)
	return nil
end