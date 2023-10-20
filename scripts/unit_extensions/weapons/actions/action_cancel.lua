ActionCancel = class(ActionCancel, ActionBase)

function ActionCancel:init(world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	ActionCancel.super.init(self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
end

function ActionCancel:client_owner_start_action(new_action, t)
	ActionCancel.super.client_owner_start_action(self, new_action, t)
end

function ActionCancel:client_owner_post_update(dt, t, world, can_damage)
	return end

function ActionCancel:finish(reason)
	return end