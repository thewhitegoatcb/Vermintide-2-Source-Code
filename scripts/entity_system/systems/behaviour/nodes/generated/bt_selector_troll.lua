require("scripts/entity_system/systems/behaviour/nodes/bt_node")
local unit_alive = Unit.alive
local Profiler = Profiler

local function nop()
	return end

BTSelector_troll = class(BTSelector_troll, BTNode)
BTSelector_troll.name = "BTSelector_troll"

function BTSelector_troll:init(...)
	BTSelector_troll.super.init(self, ...)
	self._children = { }
end

function BTSelector_troll:leave(unit, blackboard, t, reason)
	self:set_running_child(unit, blackboard, t, nil, reason)
end

function BTSelector_troll:run(unit, blackboard, t, dt)


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





	local node_smartobject = children [2]
	local condition_result = nil
	if blackboard.keep_target then
		condition_result = false
	end
	if condition_result == nil then
		condition_result = BTConditions.at_smartobject(blackboard)
	end

	if condition_result then
		self:set_running_child(unit, blackboard, t, node_smartobject, "aborted")


		local result, evaluate = node_smartobject:run(unit, blackboard, t, dt)

		if result ~= "running" then
			self:set_running_child(unit, blackboard, t, nil, result)
		end

		if result ~= "failed" then
			do return result, evaluate end
		end
	elseif node_smartobject == child_running then
		self:set_running_child(unit, blackboard, t, nil, "failed")
	end





	local node_downed = children [3]
	local condition_result = blackboard.can_get_downed and blackboard.downed_state

	if condition_result then
		self:set_running_child(unit, blackboard, t, node_downed, "aborted")


		local result, evaluate = node_downed:run(unit, blackboard, t, dt)

		if result ~= "running" then
			self:set_running_child(unit, blackboard, t, nil, result)
		end

		if result ~= "failed" then
			do return result, evaluate end
		end
	elseif node_downed == child_running then
		self:set_running_child(unit, blackboard, t, nil, "failed")
	end





	local node_stagger = children [4]
	local condition_result = nil
	if blackboard.stagger then
		if blackboard.stagger_prohibited then
			blackboard.stagger = false
		else
			condition_result = true
		end
	end

	if condition_result then
		self:set_running_child(unit, blackboard, t, node_stagger, "aborted")


		local result, evaluate = node_stagger:run(unit, blackboard, t, dt)

		if result ~= "running" then
			self:set_running_child(unit, blackboard, t, nil, result)
		end

		if result ~= "failed" then
			do return result, evaluate end
		end
	elseif node_stagger == child_running then
		self:set_running_child(unit, blackboard, t, nil, "failed")
	end





	local node_has_target = children [5]
	local condition_result = unit_alive(blackboard.target_unit)

	if condition_result then
		self:set_running_child(unit, blackboard, t, node_has_target, "aborted")


		local result, evaluate = node_has_target:run(unit, blackboard, t, dt)

		if result ~= "running" then
			self:set_running_child(unit, blackboard, t, nil, result)
		end

		if result ~= "failed" then
			do return result, evaluate end
		end
	elseif node_has_target == child_running then
		self:set_running_child(unit, blackboard, t, nil, "failed")
	end





	local node_move_to_goal = children [6]
	local condition_result = blackboard.goal_destination ~= nil

	if condition_result then
		self:set_running_child(unit, blackboard, t, node_move_to_goal, "aborted")


		local result, evaluate = node_move_to_goal:run(unit, blackboard, t, dt)

		if result ~= "running" then
			self:set_running_child(unit, blackboard, t, nil, result)
		end

		if result ~= "failed" then
			do return result, evaluate end
		end
	elseif node_move_to_goal == child_running then
		self:set_running_child(unit, blackboard, t, nil, "failed")
	end




	local node_idle = children [7]
	self:set_running_child(unit, blackboard, t, node_idle, "aborted")


	local result, evaluate = node_idle:run(unit, blackboard, t, dt)


	if result ~= "running" then
		self:set_running_child(unit, blackboard, t, nil, result)
	end

	if result ~= "failed" then
		return result, evaluate
	end
end











function BTSelector_troll:add_child(node)
	self._children [#self._children + 1] = node



end