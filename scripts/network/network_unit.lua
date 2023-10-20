NetworkUnit = NetworkUnit or { }

NetworkUnitData = NetworkUnitData or { }
local unit_network_data = NetworkUnitData

function NetworkUnit.reset_unit_data()
	NetworkUnitData = { }
	unit_network_data = NetworkUnitData
end

function NetworkUnit.add_unit(unit)
	assert(unit_network_data [unit] == nil)

	unit_network_data [unit] = { }




end

function NetworkUnit.remove_unit(unit)
	assert(unit_network_data [unit] ~= nil)
	unit_network_data [unit] = nil
end

function NetworkUnit.reset_unit(unit)
	assert(unit_network_data [unit] ~= nil)
	local unit_data = unit_network_data [unit]
	unit_data.go_type = nil
	unit_data.go_id = nil
	unit_data.owner = nil
	unit_data.is_husk = nil
end

function NetworkUnit.set_game_object_type(unit, go_type)
	unit_network_data [unit].go_type = go_type
end

function NetworkUnit.game_object_type(unit)
	return unit_network_data [unit].go_type
end

function NetworkUnit.game_object_type_level(unit)
	return unit_network_data [unit].go_type .. "_level"
end

function NetworkUnit.set_game_object_id(unit, go_id)
	unit_network_data [unit].go_id = go_id
end

function NetworkUnit.game_object_id(unit)
	return unit_network_data [unit].go_id
end

function NetworkUnit.set_owner_peer_id(unit, peer_id)
	unit_network_data [unit].owner = peer_id
end

function NetworkUnit.owner_peer_id(unit)
	return unit_network_data [unit].peer_id
end

function NetworkUnit.set_is_husk_unit(unit, is_husk)
	unit_network_data [unit].is_husk = is_husk
end

function NetworkUnit.is_husk_unit(unit)
	return not not unit_network_data [unit].is_husk
end

function NetworkUnit.is_network_unit(unit)
	return unit_network_data [unit] ~= nil
end





function NetworkUnit.on_extensions_registered(unit)
	Unit.set_flow_variable(unit, "is_husk_unit", NetworkUnit.is_husk_unit(unit))
	Unit.flow_event(unit, "on_extensions_registered")
end


function NetworkUnit.on_game_object_sync_done(unit)
	Unit.set_flow_variable(unit, "is_husk_unit", NetworkUnit.is_husk_unit(unit))
	Unit.flow_event(unit, "on_game_object_sync_done")
end

function NetworkUnit.transfer_unit(unit, unit_new)
	unit_network_data [unit_new] = unit_network_data [unit]
	unit_network_data [unit] = nil
end