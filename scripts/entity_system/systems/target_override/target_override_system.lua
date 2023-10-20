TargetOverrideSystem = class(TargetOverrideSystem, ExtensionSystemBase)

function TargetOverrideSystem:init(entity_system_creation_context, system_name, extension_list)
	TargetOverrideSystem.super.init(self, entity_system_creation_context, system_name, extension_list)

	local network_event_delegate = entity_system_creation_context.network_event_delegate
	self._network_event_delegate = network_event_delegate
	network_event_delegate:register(self, "rpc_taunt")
end

function TargetOverrideSystem:destroy()
	TargetOverrideSystem.super.destroy(self)

	self._network_event_delegate:unregister(self)
	self._network_event_delegate = nil
end

function TargetOverrideSystem:rpc_taunt(channel_id, game_object_id, radius, duration, do_stagger, taunt_bosses)
	local unit = self.unit_storage:unit(game_object_id)
	ScriptUnit.extension(unit, "target_override_system"):taunt(radius, duration, do_stagger, taunt_bosses)
end