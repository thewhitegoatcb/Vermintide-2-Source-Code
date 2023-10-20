LootRatHealthExtension = class(LootRatHealthExtension, GenericHealthExtension)

function LootRatHealthExtension:init(extension_init_context, unit, extension_init_data)
	LootRatHealthExtension.super.init(self, extension_init_context, unit, extension_init_data)
end

function LootRatHealthExtension:extensions_ready(world, unit, extension_name)
	local blackboard = BLACKBOARDS [unit]
	blackboard.dodge_damage_points = blackboard.breed.dodge_damage_points
	blackboard.dodge_damage_success = false
end

function LootRatHealthExtension:destroy()
	LootRatHealthExtension.super.destroy(self)
	self.blackboard = nil
end

function LootRatHealthExtension:apply_client_predicted_damage(predicted_damage)

	return end

function LootRatHealthExtension:add_damage(attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, source_attacker_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type)
	local blackboard = BLACKBOARDS [self.unit]
	local dodge_points = blackboard.dodge_damage_points
	local dodge_success = false

	if blackboard.is_dodging then

		dodge_points = math.max(dodge_points - damage_amount, 0)
		if dodge_points > 0 then

			dodge_success = true
		end
		blackboard.dodge_damage_points = dodge_points
	end

	if not dodge_success then
		LootRatHealthExtension.super.add_damage(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, source_attacker_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type)
	end
	blackboard.dodge_damage_success = dodge_success
end

function LootRatHealthExtension:regen_dodge_damage_points()
	local blackboard = BLACKBOARDS [self.unit]
	blackboard.dodge_damage_points = blackboard.breed.dodge_damage_points
end