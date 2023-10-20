require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTSelector = class(BTSelector, BTNode)

function BTSelector:init(...)
	BTSelector.super.init(self, ...)
	self._children = { }
end

BTSelector.name = "BTSelector"

function BTSelector:leave(unit, blackboard, t, reason)
	self:set_running_child(unit, blackboard, t, nil, reason)
end

function BTSelector:run(unit, blackboard, t, dt)
	local child_running = self:current_running_child(blackboard)
	for index, node in ipairs(self._children) do
		if node:condition(blackboard) then
			self:set_running_child(unit, blackboard, t, node, "aborted")

			local result, evaluate = node:run(unit, blackboard, t, dt)
			if result ~= "running" then
				self:set_running_child(unit, blackboard, t, nil, result)
			end

			if result ~= "failed" then
				do return result, evaluate end
			end
		elseif node == child_running then
			self:set_running_child(unit, blackboard, t, nil, "failed")
		end
	end

	if script_data.debug_behaviour_trees and script_data.debug_unit == unit then
		print("BTSelector fail: ", self:id())
	end
	fassert(self:current_running_child(blackboard) == nil)
	return "failed"
end

function BTSelector:add_child(node)
	self._children [#self._children + 1] = node
end