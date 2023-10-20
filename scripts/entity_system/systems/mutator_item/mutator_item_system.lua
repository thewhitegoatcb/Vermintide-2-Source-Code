require("scripts/unit_extensions/mutator_items/mutator_item_spawner_extension")

MutatorItemSystem = class(MutatorItemSystem, ExtensionSystemBase)

local RPCS = { }


local extensions = { "MutatorItemSpawnerExtension" }



function MutatorItemSystem:init(entity_system_creation_context, system_name)
	MutatorItemSystem.super.init(self, entity_system_creation_context, system_name, extensions)

	local network_event_delegate = entity_system_creation_context.network_event_delegate
	self.network_event_delegate = network_event_delegate
	network_event_delegate:register(self, unpack(RPCS))

	self._spawners = { }
	self._spawners_by_name = { }
end

function MutatorItemSystem:on_add_extension(world, unit, extension_name, extension_init_data, ...)
	if extension_name == "MutatorItemSpawnerExtension" then
		local spawners = self._spawners

		spawners [#spawners + 1] = unit

		local spawner_name = Unit.get_data(unit, "mutator_item_spawner_id")

		self._spawners_by_name [spawner_name] = unit
	end

	return MutatorItemSystem.super.on_add_extension(self, world, unit, extension_name, extension_init_data, ...)
end

local units = { }

function MutatorItemSystem:spawn_mutator_items(config)
	local spawners = self._spawners
	local spawners_by_name = self._spawners_by_name

	table.clear(units)

	if not config then
		return
	end

	for spawner_name, unit_settings in pairs(config) do
		local spawner = spawners_by_name [spawner_name]

		if spawner then
			local unit_name = unit_settings.unit_name
			local unit_extension_template = unit_settings.unit_extension_template
			local extension_init_data = unit_settings.extension_init_data
			local position = Unit.local_position(spawner, 0)
			local rotation = Unit.local_rotation(spawner, 0)
			local unit = Managers.state.unit_spawner:spawn_network_unit(unit_name, unit_extension_template, extension_init_data, position, rotation)

			units [#units + 1] = unit
		end
	end



	return units
end

function MutatorItemSystem:on_remove_extension(unit, extension_name, ...)
	return MutatorItemSystem.super.on_remove_extension(self, unit, extension_name, ...)
end

function MutatorItemSystem:update(dt, t)
	if self.is_server then --[[ Nothing --]]
	end
end

function MutatorItemSystem:destroy()
	self.network_event_delegate:unregister(self)
end

function MutatorItemSystem:hot_join_sync(sender)
	return end