BTNode = class(BTNode)

require("scripts/entity_system/systems/behaviour/nodes/bt_conditions")
require("scripts/entity_system/systems/behaviour/nodes/bt_leave_hooks")
require("scripts/entity_system/systems/behaviour/nodes/bt_enter_hooks")

local CONDITIONS = BTConditions
local ENTER_HOOKS = BTEnterHooks
local LEAVE_HOOKS = BTLeaveHooks

function BTNode:init(identifier, parent, condition_name, enter_hook_name, leave_hook_name, tree_node)
	self._parent = parent
	self._identifier = identifier
	self._tree_node = tree_node

	local condition = CONDITIONS [condition_name]
	fassert(condition, "No condition called %q", condition_name)

	self._condition_name = condition_name

	if enter_hook_name then
		local enter_hook = ENTER_HOOKS [enter_hook_name]
		if enter_hook then
			self.old_enter = self.enter
			function self.enter(_self, unit, blackboard, t)
				enter_hook(unit, blackboard, t)
				self.old_enter(_self, unit, blackboard, t)
			end
		else
			error("No behaviour tree enter hook called %q", enter_hook_name)
		end
	end

	if leave_hook_name then
		local leave_hook = LEAVE_HOOKS [leave_hook_name]
		if leave_hook then
			self.old_leave = self.leave
			function self.leave(_self, unit, blackboard, t)
				leave_hook(unit, blackboard, t)
				self.old_leave(_self, unit, blackboard, t)
			end
		else
			ferror("No behaviour tree leave hook called %q", leave_hook_name)
		end
	end
end

function BTNode:condition(blackboard)
	return CONDITIONS [self._condition_name](blackboard, self._tree_node.condition_args, self._tree_node.action_data)
end

function BTNode:id()
	return self._identifier
end

function BTNode:evaluate(unit, blackboard, t, dt)
	if not self:condition(blackboard) then
		return "failed"
	end

	return self:run(unit, blackboard, t, dt)
end

function BTNode:enter(unit, ai_data, t, dt)
	return end

function BTNode:leave(unit, ai_data, t, dt)
	return end

function BTNode:parent()
	return self._parent
end

function BTNode:run(unit, ai_data, t, dt)










	error(false, "Implement in inherited class: " .. self:name())
end

function BTNode:set_running_child(unit, blackboard, t, node, reason, destroy)

	local identifier = self._identifier
	local old_node = blackboard.running_nodes [identifier]
	if old_node == node then

		return
	end

	blackboard.running_nodes [identifier] = node

	if old_node then
		old_node:set_running_child(unit, blackboard, t, nil, reason, destroy)
		old_node:leave(unit, blackboard, t, reason, destroy)
	elseif self._parent ~= nil and node ~= nil then
		self._parent:set_running_child(unit, blackboard, t, self, "aborted", destroy)
	end

	if node then
		node:enter(unit, blackboard, t)
	end


end

function BTNode:current_running_child(blackboard)
	local node = blackboard.running_nodes [self._identifier]
	return node
end