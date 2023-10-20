




local ObjectiveSystemTestify = { }


function ObjectiveSystemTestify.versus_objective_add_time(objective_system, time)
	objective_system:add_time(time)
end








function ObjectiveSystemTestify.versus_current_objective_position(objective_system)
	local _, extension = next(objective_system._main_objectives)
	if not extension then
		return
	end

	local objective_data = { }
	local objective_positions = objective_system:current_objectives_position()
	local _, objective_position = next(objective_positions)
	local _, travel_dist, _, _, _ = EngineOptimized.closest_pos_at_main_path(objective_position)
	objective_data.position = objective_position
	objective_data.main_path_point = travel_dist

	return objective_data
end





function ObjectiveSystemTestify.versus_complete_objectives(objective_system)
	local _, extension = next(objective_system._main_objectives)
	if extension then
		extension._completed = true
	end

	local _, sub_objectives_container = next(objective_system._sub_objectives)
	if sub_objectives_container and sub_objectives_container.extensions then
		local extensions = sub_objectives_container.extensions
		for _, extension in ipairs(extensions) do
			extension._completed = true
		end
	end
end




function ObjectiveSystemTestify.versus_objective_name(objective_system)
	local _, extension = next(objective_system._main_objectives)
	return extension:objective_name()
end






function ObjectiveSystemTestify.versus_objective_type(objective_system)
	local _, extension = next(objective_system._main_objectives)
	if not extension then
		do return "objective not handled by Testify" end
	elseif extension._time_to_capture ~= nil then
		do return "capture point" end
	elseif extension._trigger_type == "interaction_success" then
		do return "interact" end
	elseif extension._trigger_type == "any_alive_players_inside" then
		do return "reach area" end
	else
		return "objective not handled by Testify"
	end
end





function ObjectiveSystemTestify.weave_spawn_essence_on_first_bot_position(objective_system)
	local first_bot_unit = Managers.player:bots() [1].player_unit
	if first_bot_unit then
		local player_position = Unit.local_position(first_bot_unit, 0) + Vector3(0, 0, 0.2)
		objective_system:spawn_essence_unit(player_position)
	end

	objective_system:add_score(2)
end


return ObjectiveSystemTestify