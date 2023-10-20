ActionBowEnergy = class(ActionBowEnergy, ActionBow)

function ActionBowEnergy:init(world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	ActionBowEnergy.super.init(self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)

	self._energy_extension = ScriptUnit.extension(owner_unit, "energy_system")
end

function ActionBowEnergy:fire(current_action, add_spread)
	ActionBowEnergy.super.fire(self, current_action, add_spread)

	self:_drain_energy()
end

function ActionBowEnergy:_drain_energy()
	local current_action = self.current_action
	local drain_amount = current_action.drain_amount

	if not self.extra_buff_shot then
		self._energy_extension:drain(drain_amount)
	end
end

function ActionBowEnergy:destroy()
	return end