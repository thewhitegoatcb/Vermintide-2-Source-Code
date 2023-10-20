local RPCS = { }


local extensions = { "AIInventoryItemExtension" }



AIInventoryItemSystem = class(AIInventoryItemSystem, ExtensionSystemBase)

function AIInventoryItemSystem:init(context, system_name)
	local entity_manager = context.entity_manager
	entity_manager:register_system(self, system_name, extensions)
	self.entity_manager = entity_manager

	self.is_server = context.is_server
	self.world = context.world
	self.unit_storage = context.unit_storage

	local network_event_delegate = context.network_event_delegate
	self.network_event_delegate = network_event_delegate
	network_event_delegate:register(self, unpack(RPCS))

	self.entities = { }
end

function AIInventoryItemSystem:destroy()
	self.network_event_delegate:unregister(self)
end

local dummy_input = { }
function AIInventoryItemSystem:on_add_extension(world, unit, extension_name, extension_init_data)
	local extension = { }

	ScriptUnit.set_extension(unit, "ai_inventory_item_system", extension, dummy_input)

	if extension_name == "AIInventoryItemExtension" then
		self.entities [unit] = extension
		extension.wielding_unit = extension_init_data.wielding_unit
	end

	return extension
end

function AIInventoryItemSystem:on_remove_extension(unit, extension_name)
	self.entities [unit] = nil
	ScriptUnit.remove_extension(unit, self.NAME)
end

function AIInventoryItemSystem:hot_join_sync(peer_id)
	return end

function AIInventoryItemSystem:update(context, t, dt)
	return end