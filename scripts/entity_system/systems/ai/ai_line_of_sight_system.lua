AILineOfSightSystem = class(AILineOfSightSystem, ExtensionSystemBase)

local extensions = { "AILineOfSightExtension" }



function AILineOfSightSystem:init(context, system_name)
	AILineOfSightSystem.super.init(self, context, system_name, extensions)
	self._is_server = context.is_server
	self._world = context.world
	self._physics_world = World.physics_world(self._world)
	self._extensions = { }
	self._frozen_extensions = { }
	self._num_raycasts = 0
end

function AILineOfSightSystem:destroy()

	return end

function AILineOfSightSystem:on_add_extension(world, unit, extension_name, extension_init_data)
	ScriptUnit.add_extension(nil, unit, extension_name, self.NAME, extension_init_data)
	local extension = ScriptUnit.extension(unit, self.NAME)
	self._extensions [unit] = extension
	return extension
end

function AILineOfSightSystem:on_remove_extension(unit, extension_name)
	self._frozen_extensions [unit] = nil
	self:_cleanup_extension(unit, extension_name)
	ScriptUnit.remove_extension(unit, self.NAME)
end

function AILineOfSightSystem:on_freeze_extension(unit, extension_name)
	local extension = self._extensions [unit]
	fassert(extension, "Unit was already frozen.")
	if extension == nil then return end
	self._frozen_extensions [unit] = extension
	self:_cleanup_extension(unit, extension_name)
end

function AILineOfSightSystem:_cleanup_extension(unit, extension_name)
	local extensions = self._extensions
	if extensions [unit] == nil then return end
	extensions [unit] = nil
end

function AILineOfSightSystem:freeze(unit, extension_name, reason)
	local frozen_extensions = self._frozen_extensions
	if self._frozen_extensions [unit] then return end
	local extension = self._extensions [unit]
	fassert(extension, "Unit to freeze didn't have unfrozen extension")
	self:_cleanup_extension(unit, extension_name)
	frozen_extensions [unit] = extension
end

function AILineOfSightSystem:unfreeze(unit)
	local extension = self._frozen_extensions [unit]
	self._frozen_extensions [unit] = nil
	self._extensions [unit] = extension
end

function AILineOfSightSystem:hot_join_sync(peer_id, player)
	return end

function AILineOfSightSystem:extensions_ready(world, unit, extension_name)
	local bb = BLACKBOARDS [unit]
	self._extensions [unit].blackboard = bb

end

function AILineOfSightSystem:target_changed(unit)
	self._extensions [unit].blackboard.has_line_of_sight = true
end

local is_win32 = PLATFORM == Application.WIN32
local MAX_RAYCASTS = is_win32 and 10 or 2

function AILineOfSightSystem:update(context, t)

	local dt = context.dt
	local unit_extensions = self._extensions


	while self._num_raycasts <= MAX_RAYCASTS do
		local current_unit = self._current_unit
		local unit, extension = nil


		if current_unit == nil or unit_extensions [current_unit] then
			unit, extension = next(unit_extensions, current_unit)
		end

		if extension then
			local blackboard = extension.blackboard
			local success, num_raycasts = extension:has_line_of_sight(unit, blackboard)
			self._num_raycasts = self._num_raycasts + num_raycasts
			self._current_unit = unit
			blackboard.has_line_of_sight = success
		else
			self._current_unit = nil
			break
		end
	end

	self._num_raycasts = 0

end