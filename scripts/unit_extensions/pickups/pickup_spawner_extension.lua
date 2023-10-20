PickupSpawnerExtension = class(PickupSpawnerExtension)

function PickupSpawnerExtension:init(extension_init_context, unit, extension_init_data)
	self.world = extension_init_context.world
	self.unit = unit
end

function PickupSpawnerExtension:extensions_ready()
	return end

function PickupSpawnerExtension:get_spawn_location_data()
	local position = Unit.world_position(self.unit, 0)
	local rotation = Unit.world_rotation(self.unit, 0)

	return position, rotation, true
end