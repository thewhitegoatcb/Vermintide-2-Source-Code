require("scripts/unit_extensions/generic/linker_transportation_extension")

TransportationSystem = class(TransportationSystem, ExtensionSystemBase)

local extensions = { "LinkerTransportationExtension" }



local RPCS = { "rpc_hot_join_sync_linker_transporting", "rpc_hot_join_sync_linker_transport_state", "rpc_add_transporting_ai_units", "rpc_remove_transporting_ai_units" }








function TransportationSystem:init(context, system_name)
	TransportationSystem.super.init(self, context, system_name, extensions)

	local network_event_delegate = context.network_event_delegate
	self.network_event_delegate = network_event_delegate
	network_event_delegate:register(self, unpack(RPCS))
end

function TransportationSystem:destroy()
	self.network_event_delegate:unregister(self)
	self.network_event_delegate = nil
end

function TransportationSystem:rpc_hot_join_sync_linker_transporting(channel_id, level_unit_id, game_object_id)
	local unit = Level.unit_by_index(LevelHelper:current_level(self.world), level_unit_id)
	ScriptUnit.extension(unit, "transportation_system"):rpc_hot_join_sync_linker_transporting(game_object_id)
end

function TransportationSystem:rpc_hot_join_sync_linker_transport_state(channel_id, level_unit_id, state_id, story_time)
	local unit = Level.unit_by_index(LevelHelper:current_level(self.world), level_unit_id)
	ScriptUnit.extension(unit, "transportation_system"):rpc_hot_join_sync_linker_transport_state(state_id, story_time)
end


function TransportationSystem:rpc_add_transporting_ai_units(channel_id, level_unit_id, game_object_ids, slot_ids)
	local unit = Level.unit_by_index(LevelHelper:current_level(self.world), level_unit_id)
	local extension = ScriptUnit.extension(unit, "transportation_system")

	local unit_storage = Managers.state.network.unit_storage
	for i = 1, #game_object_ids do
		local ai_unit = unit_storage:unit(game_object_ids [i])
		if ai_unit then
			extension:add_transporting_ai_unit(ai_unit, slot_ids [i])
		end
	end
end

function TransportationSystem:rpc_remove_transporting_ai_units(channel_id, level_unit_id, game_object_ids)
	local unit = Level.unit_by_index(LevelHelper:current_level(self.world), level_unit_id)
	local extension = ScriptUnit.extension(unit, "transportation_system")

	local unit_storage = Managers.state.network.unit_storage
	for i = 1, #game_object_ids do
		local ai_unit = unit_storage:unit(game_object_ids [i])
		extension:remove_transporting_ai_unit(ai_unit)
	end
end