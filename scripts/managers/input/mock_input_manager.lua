MockInputService = class(MockInputService)

function MockInputService:init()
	self._cursor_position = { -100000, -100000, -100000 }
end

local KEYS = { left_hold = true, left_press = true }




function MockInputService:get(key)
	if key == "debug_pixeldistance" then
		do return false end
	elseif key == "cursor" then
		do return self._cursor_position end
	elseif KEYS [key] then
		return false
	end
	error(string.format("Wrong parameter %q", tostring(key)))
end

function MockInputService:is_blocked()
	return true
end


MockInputManager = class(MockInputManager)

function MockInputManager:init()
	self._mock_input_service = MockInputService:new()
end

function MockInputManager:get_service()
	return self._mock_input_service
end