require("foundation/scripts/util/api_verification")
require("scripts/entity_system/systems/sound_environment/sound_environment_system")

SoundEnvironmentSystemDummy = class(SoundEnvironmentSystemDummy, ExtensionSystemBase)

local RPCS = { }
local extensions = { }

function SoundEnvironmentSystemDummy:init(entity_system_creation_context, system_name)
	SoundEnvironmentSystemDummy.super.init(self, entity_system_creation_context, system_name, extensions)


	local world = self.world
	self.wwise_world = Managers.world:wwise_world(world)
end

function SoundEnvironmentSystemDummy:register_sound_environment(volume_name, prio, ambient_sound_event, fade_time, aux_bus_name, environment_state)
	return end

function SoundEnvironmentSystemDummy:set_source_environment(source, position)
	return end

function SoundEnvironmentSystemDummy:register_source_environment_update(source, unit, object)
	return end

function SoundEnvironmentSystemDummy:unregister_source_environment_update(source)
	return end

function SoundEnvironmentSystemDummy:local_player_created(player)
	return end

function SoundEnvironmentSystemDummy:update(context, t)
	return end

function SoundEnvironmentSystemDummy:enter_environment(t, volume_name, current_environment_name)
	return end


ApiVerification.ensure_public_api(SoundEnvironmentSystem, SoundEnvironmentSystemDummy)