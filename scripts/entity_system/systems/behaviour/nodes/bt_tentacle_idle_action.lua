require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTTentacleIdleAction = class(BTTentacleIdleAction, BTNode)

function BTTentacleIdleAction:init(...)
	BTTentacleIdleAction.super.init(self, ...)
end

BTTentacleIdleAction.name = "BTTentacleIdleAction"

function BTTentacleIdleAction:enter(unit, blackboard, t)
	blackboard.next_attack_time = blackboard.next_attack_time or t + 0.5
end

function BTTentacleIdleAction:leave(unit, blackboard, t, reason, destroy)
	return end

function BTTentacleIdleAction:run(unit, blackboard, t, dt, bt_name)


	local data = blackboard.tentacle_data
	local current_length = data.current_length
	if current_length > 0 then
		local breed = blackboard.breed
		data.current_length = data.current_length - dt * breed.fail_retract_speed
		local tentacle_extension = blackboard.tentacle_spline_extension
		tentacle_extension:set_reach_dist(current_length)
	end

	local target_unit = blackboard.current_unit or blackboard.target_unit
	if not Unit.alive(target_unit) then
		return "running"
	end

	if t < blackboard.next_attack_time then
		return "running"
	end

	if blackboard.target_dist < 20 then
		blackboard.tentacle_satisfied = false
		do return "done" end
	else
		blackboard.next_attack_time = t + 1 + math.random()
	end

	return "running"

end