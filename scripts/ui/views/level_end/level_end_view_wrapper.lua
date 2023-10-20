





require("scripts/ui/views/level_end/level_end_view")

for _, dlc in pairs(DLCSettings) do
	local end_view_files = dlc.end_view
	if end_view_files then
		table.map(end_view_files, require)
	end
end

LevelEndViewWrapper = class(LevelEndViewWrapper)

function LevelEndViewWrapper:init(level_end_view_context)
	self._level_end_view_context = level_end_view_context
	self:_create_input_service()

	local level_end_view = level_end_view_context.level_end_view
	if level_end_view then
		local class = rawget(_G, level_end_view)
		self._level_end_view = class:new(level_end_view_context)
	else













		self._level_end_view = LevelEndView:new(level_end_view_context)
	end
end

function LevelEndViewWrapper:_create_input_service()
	local input_manager = Managers.input
	input_manager:create_input_service("end_of_level", "IngameMenuKeymaps", "EndLevelViewKeymapsFilters")
	input_manager:map_device_to_service("end_of_level", "keyboard")
	input_manager:map_device_to_service("end_of_level", "mouse")
	input_manager:map_device_to_service("end_of_level", "gamepad")

	input_manager:block_device_except_service("end_of_level", "keyboard", 1)
	input_manager:block_device_except_service("end_of_level", "mouse", 1)
	input_manager:block_device_except_service("end_of_level", "gamepad", 1)

	self._level_end_view_context.input_manager = input_manager
end

function LevelEndViewWrapper:destroy()
	if not Managers.chat:chat_is_focused() then
		local input_manager = Managers.input
		input_manager:device_unblock_all_services("keyboard")
		input_manager:device_unblock_all_services("mouse")
		input_manager:device_unblock_all_services("gamepad")
	end

	self._level_end_view:delete()
	self._level_end_view = nil

	self._level_end_view_context = nil
end

function LevelEndViewWrapper:game_state_changed()
	self:_create_input_service()

	local input_manager = Managers.input
	self._level_end_view_context.input_manager = input_manager
	self._level_end_view:set_input_manager(input_manager)
end

function LevelEndViewWrapper:start()
	self._level_end_view:start()
end

function LevelEndViewWrapper:done()
	return self._level_end_view:done()
end

function LevelEndViewWrapper:do_retry()
	return self._level_end_view:do_retry()
end

function LevelEndViewWrapper:register_rpcs(network_event_delegate)
	self._level_end_view:register_rpcs(network_event_delegate)
end

function LevelEndViewWrapper:unregister_rpcs()
	self._level_end_view:unregister_rpcs()
end

function LevelEndViewWrapper:left_lobby()
	self._level_end_view:left_lobby()
end

function LevelEndViewWrapper:level_end_view()
	return self._level_end_view
end

function LevelEndViewWrapper:update(dt, t)
	self._level_end_view:update(dt, t)
end

function LevelEndViewWrapper:post_update(dt, t)
	self._level_end_view:post_update(dt, t)
end