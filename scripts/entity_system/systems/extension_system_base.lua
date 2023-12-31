ExtensionSystemBase = class(ExtensionSystemBase)

function ExtensionSystemBase:init(entity_system_creation_context, system_name, extension_list)
	self.is_server = entity_system_creation_context.is_server
	self.world = entity_system_creation_context.world
	self.name = system_name

	local entity_manager = entity_system_creation_context.entity_manager
	entity_manager:register_system(self, system_name, extension_list)
	self.entity_manager = entity_manager
	self.unit_storage = entity_system_creation_context.unit_storage
	self.network_transmit = entity_system_creation_context.network_transmit
	self.system_api = entity_system_creation_context.system_api
	self.statistics_db = entity_system_creation_context.statistics_db

	self.extension_init_context = {
		world = self.world,
		unit_storage = self.unit_storage,
		entity_manager = self.entity_manager,
		network_transmit = self.network_transmit,
		system_api = self.system_api,
		statistics_db = self.statistics_db,
		ingame_ui = entity_system_creation_context.ingame_ui,
		is_server = entity_system_creation_context.is_server,
		owning_system = self }


	self.update_list = { }
	self.extensions = { }
	self.profiler_names = { }
	for i = 1, #extension_list do
		local extension_name = extension_list [i]
		self.update_list [extension_name] = {
			pre_update = { },
			update = { },
			post_update = { } }

		self.extensions [extension_name] = 0
		self.profiler_names [extension_name] = extension_name .. " [ALL]"
	end
end

function ExtensionSystemBase:on_add_extension(world, unit, extension_name, extension_init_data)
	local extension_alias = self.NAME
	local extension_pool_table = nil
	local extension = ScriptUnit.add_extension(self.extension_init_context, unit, extension_name, extension_alias, extension_init_data, extension_pool_table)
	self.extensions [extension_name] = ( self.extensions [extension_name] or 0 ) + 1

	if extension.pre_update then self.update_list [extension_name].pre_update [unit] = extension end
	if extension.update then self.update_list [extension_name].update [unit] = extension end
	if extension.post_update then self.update_list [extension_name].post_update [unit] = extension
	end
	return extension
end

function ExtensionSystemBase:on_remove_extension(unit, extension_name)


	local extension = ScriptUnit.has_extension(unit, self.NAME)
	assert(extension, "Trying to remove non-existing extension %q from unit %s", extension_name, unit)
	ScriptUnit.remove_extension(unit, self.NAME)

	self.extensions [extension_name] = self.extensions [extension_name] - 1

	self.update_list [extension_name].pre_update [unit] = nil
	self.update_list [extension_name].update [unit] = nil
	self.update_list [extension_name].post_update [unit] = nil
end

function ExtensionSystemBase:on_freeze_extension(unit, extension_name)
	return end

local dummy_input = { }
function ExtensionSystemBase:pre_update(context, t)
	local dt = context.dt
	local update_list = self.update_list
	local dummy_input = dummy_input

	for extension_name, _ in pairs(self.extensions) do
		local profiler_name = self.profiler_names [extension_name]

		for unit, extension in pairs(update_list [extension_name].pre_update) do
			extension:pre_update(unit, dummy_input, dt, context, t)
		end
	end

end

function ExtensionSystemBase:enable_update_function(extension_name, update_function_name, unit, extension)
	self.update_list [extension_name] [update_function_name] [unit] = extension
end

function ExtensionSystemBase:disable_update_function(extension_name, update_function_name, unit)
	self.update_list [extension_name] [update_function_name] [unit] = nil
end

function ExtensionSystemBase:update(context, t)
	local dt = context.dt
	local update_list = self.update_list
	local dummy_input = dummy_input

	for extension_name, _ in pairs(self.extensions) do
		local profiler_name = self.profiler_names [extension_name]

		for unit, extension in pairs(update_list [extension_name].update) do
			extension:update(unit, dummy_input, dt, context, t)
		end
	end

end

function ExtensionSystemBase:post_update(context, t)
	local dt = context.dt
	local update_list = self.update_list
	local dummy_input = dummy_input

	for extension_name, _ in pairs(self.extensions) do
		local profiler_name = self.profiler_names [extension_name]

		for unit, extension in pairs(update_list [extension_name].post_update) do
			extension:post_update(unit, dummy_input, dt, context, t)
		end
	end

end

function ExtensionSystemBase:pre_update_extension(extension_name, dt, context, t)
	local dummy_input = dummy_input
	for unit, extension in pairs(self.update_list [extension_name].pre_update) do
		extension:pre_update(unit, dummy_input, dt, context, t)
	end
end

function ExtensionSystemBase:update_extension(extension_name, dt, context, t)
	local dummy_input = dummy_input
	for unit, extension in pairs(self.update_list [extension_name].update) do
		extension:update(unit, dummy_input, dt, context, t)
	end
end

function ExtensionSystemBase:post_update_extension(extension_name, dt, context, t)
	local dummy_input = dummy_input
	for unit, extension in pairs(self.update_list [extension_name].post_update) do
		extension:post_update(unit, dummy_input, dt, context, t)
	end
end

function ExtensionSystemBase:hot_join_sync(peer_id)
	for extension_name, _ in pairs(self.extensions) do
		self:_hot_join_sync_extension(extension_name, peer_id)
	end
end

function ExtensionSystemBase:_hot_join_sync_extension(extension_name, peer_id)
	local entities = self.entity_manager:get_entities(extension_name)
	for unit, internal in pairs(entities) do
		if internal.hot_join_sync then
			internal:hot_join_sync(peer_id)
		end
	end
end

function ExtensionSystemBase:destroy()
	return end