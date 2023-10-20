
DebugHelper = DebugHelper or { }

function DebugHelper.remove_debug_stuff()
	function Commands.script() return end
	function Commands.console() return end
	function Commands.game_speed() return end
	function Commands.fov() return end
	function Commands.free_flight_settings() return end
	function Commands.lag() return end
	function Commands.location() return end
	function Commands.next_level() return end
end

function DebugHelper.enable_physics_dump()
	local physics_namespaces = { "PhysicsWorld", "Actor", "Mover" }

	for _, namespace in pairs(physics_namespaces) do
		local namespace_to_debug = _G [namespace]

		for func_name, func in pairs(namespace_to_debug) do
			if type(func) == "function" then
				namespace_to_debug [func_name] = function (...)
					local output = string.format("%s.%s() : ", namespace, func_name)
					print(output, select(2, ...))
					return func(...)
				end
			end
		end
	end
end