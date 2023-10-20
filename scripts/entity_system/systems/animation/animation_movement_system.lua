require("scripts/unit_extensions/generic/generic_unit_animation_movement_extension")

local RPCS = { "rpc_enable_animation_movement_system" }



local extensions = { "GenericUnitAnimationMovementExtension" }



AnimationMovementSystem = class(AnimationMovementSystem, ExtensionSystemBase)

function AnimationMovementSystem:init(context, system_name)
	AnimationMovementSystem.super.init(self, context, system_name, extensions)
	self._extensions = { }
	self._frozen_extensions = { }

	local network_event_delegate = context.network_event_delegate
	self.network_event_delegate = network_event_delegate
	network_event_delegate:register(self, unpack(RPCS))
end

function AnimationMovementSystem:destroy()
	self.network_event_delegate:unregister(self)
end

function AnimationMovementSystem:on_add_extension(world, unit, extension_name, extension_init_data)
	local extension = ScriptUnit.add_extension(self.extension_init_context, unit, extension_name, self.NAME, extension_init_data)
	self._extensions [unit] = extension
	return extension
end

function AnimationMovementSystem:on_remove_extension(unit, extension_name)
	self._frozen_extensions [unit] = nil
	self._extensions [unit] = nil
	ScriptUnit.remove_extension(unit, self.NAME)
end

function AnimationMovementSystem:on_freeze_extension(unit, extension_name)
	local extension = self._extensions [unit]
	fassert(extension, "Unit was already frozen.")
	if extension == nil then return end
	self._frozen_extensions [unit] = extension
	self._extensions [unit] = nil
	table.clear(extension.data)
end

function AnimationMovementSystem:freeze(unit, extension_name, reason)
	local frozen_extensions = self._frozen_extensions
	if self._frozen_extensions [unit] then return end
	local extension = self._extensions [unit]
	fassert(extension, "Unit to freeze didn't have unfrozen extension")
	self._extensions [unit] = nil
	frozen_extensions [unit] = extension
	table.clear(extension.data)
end

function AnimationMovementSystem:unfreeze(unit)
	local extension = self._frozen_extensions [unit]
	fassert(extension, "Unit to unfreeze didn't have frozen extension")
	self._frozen_extensions [unit] = nil
	self._extensions [unit] = extension
	extension.enabled = false
	extension.template [extension.network_type].init(extension.unit, extension.data)
end

function AnimationMovementSystem:update(context, t)
	local dt = context.dt

	for unit, extension in pairs(self._extensions) do
		extension:update(unit, nil, dt, context, t)
	end

end

function AnimationMovementSystem:rpc_enable_animation_movement_system(channel_id, unit_id, enable)
	local unit = self.unit_storage:unit(unit_id)
	local extension = self._extensions [unit]

	if extension then
		extension:set_enabled(enable)
	end
end