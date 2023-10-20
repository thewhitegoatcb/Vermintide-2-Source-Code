ImguiDeusChestPreloadDebug = class(ImguiDeusChestPreload)

function ImguiDeusChestPreloadDebug:init()
	return end

function ImguiDeusChestPreloadDebug:update()
	return end

function ImguiDeusChestPreloadDebug:is_persistent()
	return true
end

function ImguiDeusChestPreloadDebug:draw(is_open)
	local mechanism_name = Managers.mechanism:current_mechanism_name()

	local do_close = Imgui.begin_window("ImguiDeusChestPreloadDebug", "always_auto_resize")



































































	Imgui.end_window()
	return do_close
end