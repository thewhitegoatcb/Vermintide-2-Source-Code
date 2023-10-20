require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTDummyIdleAction = class(BTDummyIdleAction, BTNode)



function BTDummyIdleAction:init(...)
	BTDummyIdleAction.super.init(self, ...)
end

BTDummyIdleAction.name = "BTDummyIdleAction"

local function randomize(event)
	if type(event) == "table" then
		do return event [Math.random(1, #event)] end
	else
		return event
	end
end

function BTDummyIdleAction:enter(unit, blackboard, t)
	local network_manager = Managers.state.network
	local animation = "idle"
	local action = self._tree_node.action_data
	blackboard.action = action

	if action and action.idle_animation then
		animation = randomize(action.idle_animation)
	end

	if blackboard.move_state ~= "idle" and not action.no_anim then
		network_manager:anim_event(unit, animation)
		blackboard.move_state = "idle"
	end
end

function BTDummyIdleAction:leave(unit, blackboard, t, reason, destroy)

	return end

local Unit_alive = Unit.alive
function BTDummyIdleAction:run(unit, blackboard, t, dt)
	return "running"
end