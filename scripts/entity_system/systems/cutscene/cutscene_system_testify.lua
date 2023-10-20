




local CutsceneSystemTestify = { }


function CutsceneSystemTestify.skip_cutscene(cutscene_system)
	cutscene_system:skip_pressed()
end



function CutsceneSystemTestify.wait_for_cutscene_to_finish(cutscene_system)
	local cutscene_finished = cutscene_system:has_intro_cutscene_finished_playing()
	if not cutscene_finished then
		return Testify.RETRY
	end
end


return CutsceneSystemTestify