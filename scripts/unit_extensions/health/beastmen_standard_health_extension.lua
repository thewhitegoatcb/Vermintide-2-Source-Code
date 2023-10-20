BeastmenStandardHealthExtension = class(BeastmenStandardHealthExtension, GenericHealthExtension)

function BeastmenStandardHealthExtension:init(extension_init_context, unit, extension_init_data)
	BeastmenStandardHealthExtension.super.init(self, extension_init_context, unit, extension_init_data)
	self._unit = unit
end

function BeastmenStandardHealthExtension:extensions_ready(world, unit, extension_name)
	return end

function BeastmenStandardHealthExtension:destroy()
	BeastmenStandardHealthExtension.super.destroy(self)
	self.blackboard = nil
end

function BeastmenStandardHealthExtension:apply_client_predicted_damage(predicted_damage)

	return end

local white_listed_damage_sources = { grenade_frag_02 = true, torch = true, grenade_fire_01 = true, grenade_fire_02 = true, wpn_deus_relic_01 = true, grenade_frag_01 = true, explosive_barrel = true, markus_questingknight_career_skill_weapon = true, dr_deus_01 = true, shadow_torch = true }












function BeastmenStandardHealthExtension:add_damage(attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type)
	if damage_source_name == "suicide" then
		BeastmenStandardHealthExtension.super.add_damage(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type)
	else
		local can_damage_banner = false
		can_damage_banner = attack_type and (attack_type == "heavy_attack" or attack_type == "light_attack") or white_listed_damage_sources [damage_source_name]
		if can_damage_banner then
			BeastmenStandardHealthExtension.super.add_damage(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type)
			local standard_extension = ScriptUnit.has_extension(self._unit, "ai_supplementary_system")
			local standard_template = standard_extension.standard_template

			if standard_template then
				local sfx_taking_damage = standard_template.sfx_taking_damage
				WwiseUtils.trigger_unit_event(standard_extension.world, sfx_taking_damage, self._unit, 0)
			end
		end
	end
end