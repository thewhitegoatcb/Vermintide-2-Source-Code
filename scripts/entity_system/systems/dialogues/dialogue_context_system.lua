

local extensions = { "GenericDialogueContextExtension" }

DialogueContextSystem = class(DialogueContextSystem, ExtensionSystemBase)

function DialogueContextSystem:init(context, system_name)
	local entity_manager = context.entity_manager
	entity_manager:register_system(self, system_name, extensions)
	self.entity_manager = entity_manager
	self._next_player_key = nil

	self.unit_extension_data = { }
	GarbageLeakDetector.register_object(self, "dialogue_context_system")
end

function DialogueContextSystem:destroy()
	self.unit_extension_data = nil
end

function DialogueContextSystem:on_add_extension(world, unit, extension_name, extension_init_data)

	local context = ScriptUnit.extension(unit, "dialogue_system").context
	fassert(extension_init_data.profile, "Missing profile!")
	context.player_profile = extension_init_data.profile.character_vo
	local extension = {



		context = context }

	ScriptUnit.set_extension(unit, "dialogue_context_system", extension, { })
	self.unit_extension_data [unit] = extension

	return extension
end

function DialogueContextSystem:on_remove_extension(unit, extension_name)
	self.unit_extension_data [unit] = nil

	ScriptUnit.remove_extension(unit, self.NAME)
end

function DialogueContextSystem:extensions_ready(world, unit, extension_name)
	local health_extension = ScriptUnit.extension(unit, "health_system")
	local status_extension = ScriptUnit.extension(unit, "status_system")
	local proximity_extension = ScriptUnit.extension(unit, "proximity_system")

	local extension = self.unit_extension_data [unit]
	extension.health_extension = health_extension
	extension.status_extension = status_extension
	extension.proximity_extension = proximity_extension
end

function DialogueContextSystem:update(system_context, t)
	if self._next_player_key and not Unit.alive(self._next_player_key) then
		self._next_player_key = nil
	end

	local next_player_key, extension = next(self.unit_extension_data, self._next_player_key)
	self._next_player_key = next_player_key
	if not next_player_key then
		return
	end

	local context = extension.context
	context.health = extension.health_extension:current_health_percent()

	local status_extension = extension.status_extension
	context.is_pounced_down = not not status_extension:is_pounced_down()
	context.is_knocked_down = not not status_extension:is_knocked_down()
	context.intensity = status_extension:get_pacing_intensity()
	context.pacing_state = Managers.state.conflict.pacing.pacing_state

	local proximity_extension = extension.proximity_extension
	local proximity_types = proximity_extension.proximity_types
	context.friends_close = proximity_types.friends_close.num
	context.friends_distant = proximity_types.friends_distant.num
	context.enemies_close = proximity_types.enemies_close.num
	context.enemies_distant = proximity_types.enemies_distant.num
end

function DialogueContextSystem:hot_join_sync(sender)
	return end