DeusBelakorStatueSocketExtension = class(DeusBelakorStatueSocketExtension)


local function should_objective_be_active(objective_extension, socket_extension)
	if socket_extension.num_closed_sockets > 0 then
		do return false end
	else
		local local_player = Managers.player:local_player()

		local local_player_unit = local_player and local_player.player_unit

		if not local_player_unit then
			return false
		end

		local inventory_extension = ScriptUnit.has_extension(local_player_unit, "inventory_system")
		if not inventory_extension then
			return false
		end

		local weapon_slot = inventory_extension:get_wielded_slot_name()
		local weapon_data = inventory_extension:get_slot_data(weapon_slot)

		if weapon_data then
			local item_data = weapon_data.item_data
			local item_name = item_data and item_data.name

			return item_name == "belakor_crystal"
		end
	end

	return false
end

function DeusBelakorStatueSocketExtension:init(extension_init_context, unit, extension_init_data)
	local world = extension_init_context.world
	self._world = world
	self._unit = unit
end

function DeusBelakorStatueSocketExtension:game_object_initialized(unit, go_id)
	return end

function DeusBelakorStatueSocketExtension:destroy()
	return end

function DeusBelakorStatueSocketExtension:extensions_ready(world, unit)
	local objective_unit_extension = ScriptUnit.extension(unit, "tutorial_system")
	objective_unit_extension:set_active(false)
	objective_unit_extension.network_synced = false
	self._objective_extension = objective_unit_extension

	self._socket_extension = ScriptUnit.extension(unit, "objective_socket_system")
end

function DeusBelakorStatueSocketExtension:update(unit, input, dt, context, t)
	local objective_extension = self._objective_extension
	if not objective_extension then
		return
	end

	local new_value = should_objective_be_active(objective_extension, self._socket_extension)

	local currently_active = objective_extension.active

	if currently_active ~= new_value then
		objective_extension:set_active(new_value)
	end
end