PositionLookupSystem = class(PositionLookupSystem, ExtensionSystemBase)

local extensions = { "PositionLookupExtension" }



function PositionLookupSystem:init(entity_system_creation_context, system_name)
	PositionLookupSystem.super.init(self, entity_system_creation_context, system_name, extensions)
end

function PositionLookupSystem:update() return end

function PositionLookupSystem:on_add_extension(world, unit, extension_name, extension_init_data)
	fassert(self.extensions [extension_name], "[PositionLookupSystem] There is no known extension called %s", extension_name)

	POSITION_LOOKUP [unit] = Unit.world_position(unit, 0)

	local extension = { position = POSITION_LOOKUP [unit] }
	ScriptUnit.set_extension(unit, self.NAME, extension)

	return extension
end

function PositionLookupSystem:on_remove_extension(unit, extension_name)
	fassert(self.extensions [extension_name], "[PositionLookupSystem] There is no known extension called %s", extension_name)

	POSITION_LOOKUP [unit] = nil

	ScriptUnit.remove_extension(unit, self.NAME)
end

function PositionLookupSystem:destroy() return end