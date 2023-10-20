FadeSystem = class(FadeSystem, ExtensionSystemBase)

FadeSystem.system_extensions = { "PlayerUnitFadeExtension", "AIUnitFadeExtension" }




local unit_alive = Unit.alive
local script_unit_extension = ScriptUnit.extension

function FadeSystem:init(entity_system_creation_context, system_name)
	local extensions = FadeSystem.system_extensions
	FadeSystem.super.init(self, entity_system_creation_context, system_name, extensions)
	self.fade_system = EngineOptimizedExtensions.fade_init_system()
end

function FadeSystem:destroy()
	EngineOptimizedExtensions.fade_destroy_system(self.fade_system)
end

function FadeSystem:on_add_extension(world, unit, extension_name, extension_init_data)
	EngineOptimizedExtensions.fade_on_add_extension(self.fade_system, unit)
	ScriptUnit.set_extension(unit, self.name, { })
	return { }
end

function FadeSystem:set_min_fade(unit, min_fade)
	EngineOptimizedExtensions.fade_set_min_fade(self.fade_system, unit, min_fade)
end


function FadeSystem:new_linked_units(unit, new_linked_units)
	EngineOptimizedExtensions.fade_new_linked_units(self.fade_system, unit, new_linked_units)
end

function FadeSystem:on_remove_extension(unit, extension_name)
	EngineOptimizedExtensions.fade_on_remove_extension(self.fade_system, unit)
	ScriptUnit.remove_extension(unit, self.name)
end

function FadeSystem:on_freeze_extension(unit, extension_name)
	EngineOptimizedExtensions.fade_on_remove_extension(self.fade_system, unit)
end

function FadeSystem:freeze(unit, extension_name, reason)
	EngineOptimizedExtensions.fade_on_remove_extension(self.fade_system, unit)
end

function FadeSystem:unfreeze(unit)
	EngineOptimizedExtensions.fade_on_add_extension(self.fade_system, unit)
end

function FadeSystem:local_player_created(player)
	self.player = player
end

function FadeSystem:update(context, t)









	if not self.player then
		return
	end

	local local_player = self.player
	local local_player_id = local_player:local_player_id()
	local viewport_name = local_player.viewport_name

	local camera_position = nil

	local freeflight_manager = Managers.free_flight
	if freeflight_manager:active(local_player_id) then
		camera_position = freeflight_manager:camera_position_rotation(local_player_id)
	else
		camera_position = Managers.state.camera:camera_position(viewport_name)
	end

	EngineOptimizedExtensions.fade_update(self.fade_system, camera_position)















end