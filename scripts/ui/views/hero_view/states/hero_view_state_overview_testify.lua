




local HeroViewStateOverviewTestify = { }


function HeroViewStateOverviewTestify.close_hero_view(hero_view_state_overview)
	hero_view_state_overview:close_menu()
end



function HeroViewStateOverviewTestify.set_hero_window_layout(hero_view_state_overview, index)
	hero_view_state_overview:set_layout(index)
end



function HeroViewStateOverviewTestify.wait_for_hero_view()
	return end


return HeroViewStateOverviewTestify