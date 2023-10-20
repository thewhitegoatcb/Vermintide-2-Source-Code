SteamHelper = SteamHelper or { }

local FRIEND_STATUS = { [0] = "offline", "online", "busy", "away", "snooze", "trading", "looking_to_play" }









function SteamHelper.debug_friends()
	local number_of_friends = 5
	local friends = { }
	for i = 1, number_of_friends do
		local id = "id_" .. i
		friends [id] = { playing_this_game = false,
			name = "debug_friend_" .. i,
			playing_game = i % 2 == 1,

			status = math.random(1, 6) }
	end


	return friends
end

function SteamHelper.friends()
	local num_friends = Friends.num_friends()
	local friends = { }
	local app_id = Steam.app_id()

	for i = 1, num_friends do
		local id = Friends.id(i)
		local playing_game = Friends.playing_game(id)
		local playing_this_game = playing_game and playing_game.app_id == app_id
		friends [id] = {
			name = Friends.name(id),
			playing_game = playing_game,
			playing_this_game = playing_this_game,
			status = FRIEND_STATUS [Friends.status(id)] }
	end


	return friends
end

function SteamHelper.is_dev()
	if rawget(_G, "Clans") then
		return SteamHelper.is_in_clan("170000000a021fa")
	else
		return false
	end
end

function SteamHelper.is_in_clan(clan_id)
	local clan_count = Clans.clan_count()
	for i = 0, clan_count - 1 do
		local id = Clans.clan_by_index(i)
		if id == clan_id then
			return true
		end
	end
	return false
end

function SteamHelper.clans_short()
	if rawget(_G, "Clans") then
		local clan_count = Clans.clan_count()
		local clan_names = { }
		for i = 0, clan_count - 1 do
			local id = Clans.clan_by_index(i)
			local name = Clans.clan_tag(id)
			clan_names [id] = name
		end

		do return clan_names end
	else
		return { }
	end
end

function SteamHelper.clans()
	local clan_count = Clans.clan_count()
	local clan_names = { }
	for i = 0, clan_count - 1 do
		local id = Clans.clan_by_index(i)
		local name = Clans.clan_name(id)
		clan_names [id] = name
	end

	return clan_names
end