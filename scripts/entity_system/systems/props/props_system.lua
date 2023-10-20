require("scripts/settings/level_settings")
require("scripts/settings/perlin_light_configurations")
require("scripts/unit_extensions/level/rotating_hazard_extension")

PropsSystem = class(PropsSystem, ExtensionSystemBase)

local RPCS = { "rpc_thorn_bush_trigger_area_damage", "rpc_thorn_bush_trigger_despawn", "rpc_sync_rotating_hazard" }





local extensions = { "PerlinLightExtension", "BotNavTransitionExtension", "QuestChallengePropExtension", "ThornMutatorExtension", "ScaleUnitExtension", "StoreDisplayItemGizmoExtension", "RotatingHazardExtension" }









DLCUtils.append("prop_extension", extensions)

function PropsSystem:init(entity_system_creation_context, system_name)
	PropsSystem.super.init(self, entity_system_creation_context, system_name, extensions)

	for k, v in pairs(PerlinLightConfigurations) do
		Light.add_flicker_configuration(k, v.persistance, v.octaves, v.min_value, v.frequency_multiplier,
		v.translation.persistance, v.translation.octaves, v.translation.jitter_multiplier_xy, v.translation.jitter_multiplier_z, v.translation.frequency_multiplier)
	end
	PerlinLightConfigurations_reload = false

	self._extensions = { }
	self._network_event_delegate = entity_system_creation_context.network_event_delegate
	self._network_event_delegate:register(self, unpack(RPCS))
end

function PropsSystem:on_add_extension(world, unit, extension_name, extension_init_data)
	local extension = nil

	if extension_name == "PerlinLightExtension" then
		local flicker_config_name = Unit.get_data(unit, "flicker_config")
		local light = nil
		if Unit.has_data(unit, "perlin_light_node_name") then
			local flicker_node = Unit.get_data(unit, "perlin_light_node_name")
			if Unit.has_light(unit, flicker_node) then
				light = Unit.light(unit, flicker_node)
			end
		end
		if light == nil then
			light = Unit.light(unit, 0)
		end
		Light.set_flicker_type(light, flicker_config_name)
		extension = { }
	else

		if extension_name == "ThornSisterWallExtension" and self.is_server then
			Managers.level_transition_handler.transient_package_loader:add_unit(unit)
		end


		extension = PropsSystem.super.on_add_extension(self, world, unit, extension_name, extension_init_data)
	end

	self._extensions [unit] = extension
	return extension
end

function PropsSystem:destroy()
	self._network_event_delegate:unregister(self)
end

function PropsSystem:on_remove_extension(unit, extension_name)
	if extension_name ~= "PerlinLightExtension" then

		if extension_name == "ThornSisterWallExtension" and self.is_server then
			Managers.level_transition_handler.transient_package_loader:remove_unit(unit)
		end

		PropsSystem.super.on_remove_extension(self, unit, extension_name)
	end
end

function PropsSystem:update(context, t)











	PropsSystem.super.update(self, context, t)
end

function PropsSystem:rpc_thorn_bush_trigger_area_damage(channel_id, unit_id)
	local unit = Managers.state.unit_storage:unit(unit_id)
	local script = ScriptUnit.extension(unit, "props_system")
	if script then
		script:trigger_area_damage()
	end
end

function PropsSystem:rpc_thorn_bush_trigger_despawn(channel_id, unit_id)
	local unit = Managers.state.unit_storage:unit(unit_id)
	local script = ScriptUnit.extension(unit, "props_system")
	local world = Managers.world:world("level_world")
	WwiseUtils.trigger_unit_event(world, "Play_winds_life_gameplay_thorn_hit_player", unit, 0)
	if script then
		script:despawn()
	end
end

function PropsSystem:rpc_sync_rotating_hazard(channel_id, go_id, is_level_unit, start_t, pause_t, state, seed)
	local unit = Managers.state.network:game_object_or_level_unit(go_id, is_level_unit)
	local extension = self._extensions [unit]
	extension:network_sync(start_t, pause_t, state, seed)
end