require("core/gwnav/lua/safe_require")
local NavRoute = safe_require_guard()

local NavClass = safe_require("core/gwnav/lua/runtime/navclass")
NavRoute = NavClass(NavRoute)

local Vector3Box = stingray.Vector3Box

function NavRoute:init()
	self._positions = { }
end

function NavRoute:add_position(position)
	self._positions [#self._positions + 1] = Vector3Box(position)
end

function NavRoute:positions()
	return self._positions
end

return NavRoute