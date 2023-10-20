ActionReload = class(ActionReload, ActionBase)

function ActionReload:init(world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	self.weapon_system = weapon_system
	self.owner_unit = owner_unit
	self.first_person_unit = first_person_unit
	self.weapon_unit = weapon_unit
	self.world = world
	self.item_name = item_name
	self.wwise_world = Managers.world:wwise_world(world)
	self.is_server = is_server
end

function ActionReload:client_owner_start_action(new_action, t, chain_action_data, power_level)
	ActionReload.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level)
	local owner_unit = self.owner_unit
	local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	local ammo_extension = nil

	local equipment = inventory_extension:equipment()
	if equipment.right_hand_wielded_unit ~= nil and ScriptUnit.has_extension(equipment.right_hand_wielded_unit, "ammo_system") then
		ammo_extension = ScriptUnit.extension(equipment.right_hand_wielded_unit, "ammo_system")
	elseif equipment.left_hand_wielded_unit ~= nil and ScriptUnit.has_extension(equipment.left_hand_wielded_unit, "ammo_system") then
		ammo_extension = ScriptUnit.extension(equipment.left_hand_wielded_unit, "ammo_system")
	end

	local play_reload_animation = true
	ammo_extension:start_reload(play_reload_animation)
end

function ActionReload:client_owner_post_update(dt, t, world, can_damage)
	return end

function ActionReload:finish(reason)
	return end