local platform_functions = {
	init = function (achievement_manager)
		return end,
	check_version_number = function ()






		return true
	end,
	version_result = function (token)
		local result = Stats.progress(token)
		if result.done then
			return true, result.error
		end
	end }
function platform_functions.is_unlocked(template)
	assert(template.ID_STEAM, "[AchievementManager] There is no Achievement ID specified for achievement: " .. template.id)
	local unlocked, error_msg = Achievement.unlocked(template.ID_STEAM)
	return unlocked, error_msg
end
function platform_functions.is_platform_achievement(template)
	return template.ID_STEAM
end
function platform_functions.verify_platform_unlocked(template)
	assert(template.ID_STEAM, "[AchievementManager] There is no Achievement ID specified for achievement: " .. template.id)

	local verified = true
	local name = template.name
	local template_id = template.id
	local achievement_id = template.ID_STEAM
	printf("[AchievementManager] Verifying - Name: %q. Template: %q. ID: %q", Localize(name), template_id, achievement_id)

	local token, error_msg = Achievement.unlock(achievement_id)
	if error_msg then
		printf("[AchievementManager] #### Error: %s", error_msg)
	end
	return verified, token
end
function platform_functions.unlock(template)
	assert(template.ID_STEAM, "[AchievementManager] There is no Achievement ID specified for achievement: " .. template.id)
	local token, error_msg = Achievement.unlock(template.ID_STEAM)
	return token, error_msg
end
function platform_functions.unlock_result(token)
	local result = Achievement.progress(token)
	if result.done then
		return true, result.error
	end
end
function platform_functions.reset()
	Achievement.reset()
end


return platform_functions