


ScriptExtendedReplay = class(ScriptExtendedReplay)


function ScriptExtendedReplay.reload()
	Managers.replay:reload()
end


function ScriptExtendedReplay.play(enable)
	Managers.replay:play(enable)
end


function ScriptExtendedReplay.set_frame(frame)
	Managers.replay:set_frame(frame)
end


function ScriptExtendedReplay.set_level(level)
	Managers.replay:set_level(level)
end


function ScriptExtendedReplay.set_stories(stories)
	Managers.replay:set_stories(stories)
end

function ScriptExtendedReplay.request_moving_units()
	local cmd = { message = "moving_units", type = "replay",


		units = ExtendedReplay.moving_units() }

	Application.console_send(cmd)
end