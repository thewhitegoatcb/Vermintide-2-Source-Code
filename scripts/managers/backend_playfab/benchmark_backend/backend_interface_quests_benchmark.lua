BackendInterfaceQuestsBenchmark = class(BackendInterfaceQuestsBenchmark)

function BackendInterfaceQuestsBenchmark:init(backend_mirror)
	return end

function BackendInterfaceQuestsBenchmark:_refresh()
	return end

function BackendInterfaceQuestsBenchmark:ready()
	return true
end

function BackendInterfaceQuestsBenchmark:make_dirty()
	return end

function BackendInterfaceQuestsBenchmark:update(dt)
	return end

function BackendInterfaceQuestsBenchmark:get_quests_cb(result)
	return end

function BackendInterfaceQuestsBenchmark:delete()
	return end

function BackendInterfaceQuestsBenchmark:get_quests()
	return { }
end

function BackendInterfaceQuestsBenchmark:get_daily_quest_update_time()
	return 0
end

function BackendInterfaceQuestsBenchmark:get_time_left_on_event_quest(key)
	return 0
end

function BackendInterfaceQuestsBenchmark:can_refresh_daily_quest()
	return false
end

function BackendInterfaceQuestsBenchmark:refresh_daily_quest(key)
	return 1
end

function BackendInterfaceQuestsBenchmark:refresh_quest_cb(id, key, result)
	return end

function BackendInterfaceQuestsBenchmark:is_quest_refreshed(id)
	return true
end

function BackendInterfaceQuestsBenchmark:can_claim_quest_rewards(key)
	return false
end

function BackendInterfaceQuestsBenchmark:claim_quest_rewards(key)
	return 1
end

function BackendInterfaceQuestsBenchmark:quest_rewards_request_cb(data, result)
	return end

function BackendInterfaceQuestsBenchmark:get_quest_key(quest_id)
	return nil
end





function BackendInterfaceQuestsBenchmark:quest_rewards_generated(id)
	return false
end

function BackendInterfaceQuestsBenchmark:get_quest_rewards(id)
	return { }
end