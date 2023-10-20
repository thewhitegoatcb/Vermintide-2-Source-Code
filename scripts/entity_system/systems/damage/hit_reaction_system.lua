HitReactionSystem = class(HitReactionSystem, ExtensionSystemBase)

local extensions = { "GenericHitReactionExtension" }



function HitReactionSystem:init(entity_system_creation_context, system_name)
	HitReactionSystem.super.init(self, entity_system_creation_context, system_name, extensions)

	self.unit_extensions = { }
	self.frozen_unit_extensions = { }
end

function HitReactionSystem:destroy()
	return end

function HitReactionSystem:on_add_extension(world, unit, extension_name, extension_init_data)
	local extension = ScriptUnit.add_extension(self.extension_init_context, unit, extension_name, self.NAME, extension_init_data)
	self.unit_extensions [unit] = extension
	return extension
end

function HitReactionSystem:extensions_ready(world, unit, extension_name)
	return end

function HitReactionSystem:on_remove_extension(unit, extension_name)
	self.frozen_unit_extensions [unit] = nil
	self:_cleanup_extension(unit, extension_name)
	ScriptUnit.remove_extension(unit, self.NAME)
end

function HitReactionSystem:on_freeze_extension(unit, extension_name)
	local extension = self.unit_extensions [unit]
	fassert(extension, "Unit was already frozen.")
	if extension == nil then return end
	self.frozen_unit_extensions [unit] = extension
	self:_cleanup_extension(unit, extension_name)
end

function HitReactionSystem:_cleanup_extension(unit, extension_name)
	self.unit_extensions [unit] = nil
end

function HitReactionSystem:freeze(unit, extension_name, reason)
	fassert(self.frozen_unit_extensions [unit] == nil, "Tried to freeze an already frozen unit.")
	local extension = self.unit_extensions [unit]
	fassert(extension, "Unit to freeze didn't have unfrozen extension")
	self.unit_extensions [unit] = nil
	self.frozen_unit_extensions [unit] = extension
end

function HitReactionSystem:unfreeze(unit)
	local extension = self.frozen_unit_extensions [unit]
	fassert(extension, "Unit to unfreeze didn't have frozen extension")
	self.frozen_unit_extensions [unit] = nil
	self.unit_extensions [unit] = extension
	extension:unfreeze()
end

function HitReactionSystem:hot_join_sync(sender)
	return end

function HitReactionSystem:update(context, t)
	local dt = context.dt
	for unit, extension in pairs(self.unit_extensions) do
		extension:update(unit, nil, dt, context, t)
	end
end