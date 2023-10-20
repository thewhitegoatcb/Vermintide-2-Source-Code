require("foundation/scripts/util/api_verification")
require("scripts/entity_system/systems/fade/fade_system")

FadeSystemDummy = class(FadeSystemDummy, ExtensionSystemBase)

local extensions = { "PlayerUnitFadeExtension", "AIUnitFadeExtension" }




function FadeSystemDummy:init(entity_system_creation_context, system_name)
	FadeSystemDummy.super.init(self, entity_system_creation_context, system_name, extensions)
end

function FadeSystemDummy:destroy()
	return end

function FadeSystemDummy:on_add_extension(world, unit, extension_name, extension_init_data)
	return { }
end

function FadeSystemDummy:freeze(unit, extension_name, reason)
	return end

function FadeSystemDummy:unfreeze(unit)
	return end

function FadeSystemDummy:set_min_fade(unit, min_fade)
	return end

function FadeSystemDummy:new_linked_units(unit, new_linked_units)
	return end

function FadeSystemDummy:on_remove_extension(unit, extension_name)
	return end

function FadeSystemDummy:local_player_created(player)
	return end

function FadeSystemDummy:update(context, t)
	return end


ApiVerification.ensure_public_api(FadeSystem, FadeSystemDummy)