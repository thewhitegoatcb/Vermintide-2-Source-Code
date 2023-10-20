




local IngameUITestify = { }




function IngameUITestify.transition_with_fade(ingame_ui, params)
	ingame_ui:transition_with_fade(params.transition, params.transition_params)
end


return IngameUITestify