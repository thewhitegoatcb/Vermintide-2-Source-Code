require("scripts/entity_system/systems/behaviour/nodes/bt_node")
local unit_alive = Unit.alive
local Profiler = Profiler

local function nop()
	return end

BTSelector_tower_homing_skull = class(BTSelector_tower_homing_skull, BTNode)
BTSelector_tower_homing_skull.name = "BTSelector_tower_homing_skull"

function BTSelector_tower_homing_skull:init(...)
	BTSelector_tower_homing_skull.super.init(self, ...)
	self._children = { }
end

function BTSelector_tower_homing_skull:leave(unit, blackboard, t, reason)
	self:set_running_child(unit, blackboard, t, nil, reason)
end

function BTSelector_tower_homing_skull:run(unit, blackboard, t, dt)
	local Profiler_start = Profiler.start local Profiler_stop = Profiler.stop

	local child_running = self:current_running_child(blackboard)
	local children = self._children




	local node_bt_ethereal_homing_flight_action = children [1]
	local condition_result = unit_alive(blackboard.target_unit)

	if condition_result then
		self:set_running_child(unit, blackboard, t, node_bt_ethereal_homing_flight_action, "aborted")


		local result, evaluate = node_bt_ethereal_homing_flight_action:run(unit, blackboard, t, dt)

		if result ~= "running" then
			self:set_running_child(unit, blackboard, t, nil, result)
		end

		if result ~= "failed" then
			do return result, evaluate end
		end
	elseif node_bt_ethereal_homing_flight_action == child_running then
		self:set_running_child(unit, blackboard, t, nil, "failed")
	end


end





function BTSelector_tower_homing_skull:add_child(node)
	self._children [#self._children + 1] = node



end