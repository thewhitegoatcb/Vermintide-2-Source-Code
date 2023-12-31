ScorpionSeasonalSettings = {
	current_season_id = 4,

	get_season_name = function (id)
		if id == 1 then
			return "season_" .. id
		end
		return "s" .. id
	end }

ScorpionSeasonalSettings.current_season_name = ScorpionSeasonalSettings.get_season_name(ScorpionSeasonalSettings.current_season_id)


function ScorpionSeasonalSettings.get_leaderboard_stat_for_season(season_id, player_num)
	return ScorpionSeasonalSettings.get_season_name(season_id) .. "_weave_score_" .. player_num .. "_players"
end
function ScorpionSeasonalSettings.get_leaderboard_stat(player_num)
	return ScorpionSeasonalSettings.get_leaderboard_stat_for_season(ScorpionSeasonalSettings.current_season_id, player_num)
end


function ScorpionSeasonalSettings.get_weave_score_stat_for_season(season_id, weave_id, player_num)
	if season_id == 1 then
		return "weave_score_weave_" .. weave_id .. "_" .. player_num .. "_players"
	end
	return weave_id .. "_" .. player_num
end
function ScorpionSeasonalSettings.get_weave_score_stat(weave_id, player_num)
	return ScorpionSeasonalSettings.get_weave_score_stat_for_season(ScorpionSeasonalSettings.current_season_id, weave_id, player_num)
end