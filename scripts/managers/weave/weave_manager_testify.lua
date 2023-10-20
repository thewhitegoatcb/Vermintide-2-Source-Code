



require("scripts/settings/weave_settings")


local WeaveManagerTestify = { }


function WeaveManagerTestify.set_next_weave(weave_manager, weave_name)
	weave_manager._remaining_time = WeaveSettings.starting_time
	weave_manager:set_next_weave(weave_name)
	weave_manager:set_next_objective(1)
end






function WeaveManagerTestify.get_weave_end_zone(weave_number)
	local weave_template = WeaveSettings.templates_ordered [weave_number]
	return weave_template.objectives [1].end_zone_name
end




function WeaveManagerTestify.weave_remaining_time(weave_manager)
	return weave_manager._remaining_time
end




function WeaveManagerTestify.get_active_weave_phase(weave_manager)
	return weave_manager:get_active_weave_phase()
end


return WeaveManagerTestify