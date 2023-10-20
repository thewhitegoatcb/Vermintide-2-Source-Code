
MutatorItemSpawnerExtension = class(MutatorItemSpawnerExtension)

function MutatorItemSpawnerExtension:init(extension_init_context, unit, extension_init_data, is_server)
	self.world = extension_init_context.world
	self.unit = unit

	self.is_server = is_server
end

function MutatorItemSpawnerExtension:destroy()
	return end