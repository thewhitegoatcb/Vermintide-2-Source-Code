ImguiDeusAutoDebug = class(ImguiDeusAutoDebug)

local helpful_responses = { "That ain't working.", "Have you tried restarting?", "Maybe furiously spamming this button will work.", "I'm not helpful", "I'm helpful", "I'm a notorious liar", "What is truth", "This is a helpful response", "It is wednesday my dudes" }











function ImguiDeusAutoDebug:init()
	self._current_response = ""
end

function ImguiDeusAutoDebug:update()
	return end

function ImguiDeusAutoDebug:is_persistent()
	return false
end

function ImguiDeusAutoDebug:draw()
	local do_close = Imgui.begin_window("DeusAutoDebug", "always_auto_resize")

	if Imgui.button("Automatically debug my problems") then
		local possible_responses = table.clone(helpful_responses)
		table.array_remove_if(possible_responses, function (response) return response == self._current_response end)

		local index = math.random(1, #possible_responses)
		self._current_response = possible_responses [index]
	end

	Imgui.text(self._current_response)

	Imgui.end_window()
	return do_close
end