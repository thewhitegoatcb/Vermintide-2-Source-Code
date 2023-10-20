require("scripts/entity_system/systems/behaviour/nodes/bt_node")
local unit_alive = Unit.alive
local Profiler = Profiler

local function nop()
	return end

BTSelector_shadow_totem = class(BTSelector_shadow_totem, BTNode)
BTSelector_shadow_totem.name = "BTSelector_shadow_totem"

function BTSelector_shadow_totem:init(...)
	BTSelector_shadow_totem.super.init(self, ...)
	self._children = { }
end

function BTSelector_shadow_totem:leave(unit, blackboard, t, reason)
	self:set_running_child(unit, blackboard, t, nil, reason)
end

function BTSelector_shadow_totem:run(unit, blackboard, t, dt)


	local child_running = self:current_running_child(blackboard)
	local children = self._children



	local node_idle = children [1]
	self:set_running_child(unit, blackboard, t, node_idle, "aborted")


	local result, evaluate = node_idle:run(unit, blackboard, t, dt)


	if result ~= "running" then
		self:set_running_child(unit, blackboard, t, nil, result)
	end

	if result ~= "failed" then
		return result, evaluate
	end
end





function BTSelector_shadow_totem:add_child(node)
	self._children [#self._children + 1] = node



end