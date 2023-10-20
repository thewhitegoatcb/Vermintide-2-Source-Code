require("scripts/unit_extensions/default_player_unit/energy/energy_data")

PlayerHuskEnergyExtension = class(PlayerHuskEnergyExtension)

function PlayerHuskEnergyExtension:init(extension_init_context, unit, extension_init_data)
	self.network_manager = Managers.state.network
	self.unit = unit

	local energy_data = extension_init_data.energy_data
	self._max_energy = energy_data.max_value or 40
	self._energy = self._max_energy

	self._recharge_delay_timer = 0
	self._recharge_delay = energy_data.recharge_delay or 0
	self._recharge_rate = energy_data.recharge_rate or 0

	self._depletion_cooldown_timer = 0
	self._depletion_cooldown = energy_data.depletion_cooldown or 0

	self._previous_can_drain = self:is_drainable()
end

function PlayerHuskEnergyExtension:extensions_ready(world, unit)
	return end

function PlayerHuskEnergyExtension:reset()
	return end

function PlayerHuskEnergyExtension:destroy()
	return end

function PlayerHuskEnergyExtension:_update_game_object()
	local network_manager = self.network_manager
	local unit = self.unit
	local game = network_manager:game()
	local go_id = Managers.state.unit_storage:go_id(unit)

	if game and go_id then
		local max_energy = GameSession.game_object_field(game, go_id, "energy_max_value")

		self._depletion_cooldown_active = GameSession.game_object_field(game, go_id, "is_on_depletion_cooldown")
		self._energy = max_energy * GameSession.game_object_field(game, go_id, "energy_percentage")
		self._max_energy = max_energy
	end
end

function PlayerHuskEnergyExtension:_update_events()
	local previous_is_drainable = self._previous_can_drain
	local is_drainable = self:is_drainable()

	if previous_is_drainable ~= is_drainable then
		if is_drainable then
			self:_broadcast_equipment_flow_event("on_energy_drainable")
		else
			self:_broadcast_equipment_flow_event("on_energy_not_drainable")
		end
	end

	self._previous_can_drain = is_drainable
end

function PlayerHuskEnergyExtension:update(unit, input, dt, context, t)
	self:_update_game_object()
	self:_update_events()









end

function PlayerHuskEnergyExtension:drain()
	return end

function PlayerHuskEnergyExtension:get_max()
	return self._max_energy
end

function PlayerHuskEnergyExtension:is_drainable()
	local is_depleted = self:is_depleted()
	local is_on_depletion_cooldown = self:_is_on_depletion_cooldown()
	if is_depleted or is_on_depletion_cooldown then
		return false
	end

	return true
end

function PlayerHuskEnergyExtension:is_depleted()
	return self._energy <= 0
end

function PlayerHuskEnergyExtension:get_fraction()
	return math.clamp(self._energy / self._max_energy, 0, 1)
end

function PlayerHuskEnergyExtension:_is_recharging()
	return self._recharge_delay_timer <= Managers.time:time("game")
end

function PlayerHuskEnergyExtension:_is_on_depletion_cooldown()
	return self._depletion_cooldown_active
end

function PlayerHuskEnergyExtension:_broadcast_equipment_flow_event(event_name)
	local inventory_extension = ScriptUnit.has_extension(self.unit, "inventory_system")
	local equipment = inventory_extension and inventory_extension:equipment()

	if equipment then

		local right_hand_wielded_unit_3p = equipment.right_hand_wielded_unit_3p
		local right_hand_ammo_unit_3p = equipment.right_hand_ammo_unit_3p
		local right_hand_wielded_unit = equipment.right_hand_wielded_unit
		local right_hand_ammo_unit_1p = equipment.right_hand_ammo_unit_1p

		if right_hand_wielded_unit_3p then
			Unit.flow_event(right_hand_wielded_unit_3p, event_name)
		end

		if right_hand_ammo_unit_3p then
			Unit.flow_event(right_hand_ammo_unit_3p, event_name)
		end

		if right_hand_wielded_unit then
			Unit.flow_event(right_hand_wielded_unit, event_name)
		end

		if right_hand_ammo_unit_1p then
			Unit.flow_event(right_hand_ammo_unit_1p, event_name)
		end


		local left_hand_wielded_unit_3p = equipment.left_hand_wielded_unit_3p
		local left_hand_ammo_unit_3p = equipment.left_hand_ammo_unit_3p
		local left_hand_wielded_unit = equipment.left_hand_wielded_unit
		local left_hand_ammo_unit_1p = equipment.left_hand_ammo_unit_1p

		if left_hand_wielded_unit_3p then
			Unit.flow_event(left_hand_wielded_unit_3p, event_name)
		end

		if left_hand_ammo_unit_3p then
			Unit.flow_event(left_hand_ammo_unit_3p, event_name)
		end

		if left_hand_wielded_unit then
			Unit.flow_event(left_hand_wielded_unit, event_name)
		end

		if left_hand_ammo_unit_1p then
			Unit.flow_event(left_hand_ammo_unit_1p, event_name)
		end
	end
end