require("scripts/entity_system/systems/behaviour/nodes/bt_node")
local unit_alive = Unit.alive
local Profiler = Profiler

local function nop()
	return end

BTSelector_chaos_plague_wave_spawner = class(BTSelector_chaos_plague_wave_spawner, BTNode)
BTSelector_chaos_plague_wave_spawner.name = "BTSelector_chaos_plague_wave_spawner"

function BTSelector_chaos_plague_wave_spawner:init(...)
	BTSelector_chaos_plague_wave_spawner.super.init(self, ...)
	self._children = { }
end

function BTSelector_chaos_plague_wave_spawner:leave(unit, blackboard, t, reason)
	self:set_running_child(unit, blackboard, t, nil, reason)
end

function BTSelector_chaos_plague_wave_spawner:run(unit, blackboard, t, dt)


	local child_running = self:current_running_child(blackboard)
	local children = self._children




	local node_spawn = children [1]
	local condition_result = blackboard.spawn

	if condition_result then
		self:set_running_child(unit, blackboard, t, node_spawn, "aborted")


		local result, evaluate = node_spawn:run(unit, blackboard, t, dt)

		if result ~= "running" then
			self:set_running_child(unit, blackboard, t, nil, result)
		end

		if result ~= "failed" then
			do return result, evaluate end
		end
	elseif node_spawn == child_running then
		self:set_running_child(unit, blackboard, t, nil, "failed")
	end





	local node_in_combat = children [2]
	local condition_result = unit_alive(blackboard.target_unit)

	if condition_result then
		self:set_running_child(unit, blackboard, t, node_in_combat, "aborted")


		local result, evaluate = node_in_combat:run(unit, blackboard, t, dt)

		if result ~= "running" then
			self:set_running_child(unit, blackboard, t, nil, result)
		end

		if result ~= "failed" then
			do return result, evaluate end
		end
	elseif node_in_combat == child_running then
		self:set_running_child(unit, blackboard, t, nil, "failed")
	end


end






function BTSelector_chaos_plague_wave_spawner:add_child(node)
	self._children [#self._children + 1] = node



end