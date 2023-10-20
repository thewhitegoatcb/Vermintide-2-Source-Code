WhereaboutsSystem = class(WhereaboutsSystem, ExtensionSystemBase)

local extensions = { "PlayerWhereaboutsExtension", "LureWhereaboutsExtension" }





function WhereaboutsSystem:init(context, system_name)
	WhereaboutsSystem.super.init(self, context, system_name, extensions)


	local world = context.world





end

function WhereaboutsSystem:destroy()



	return end

function WhereaboutsSystem:on_add_extension(world, unit, extension_name, extension_init_data)
	local extension = WhereaboutsSystem.super.on_add_extension(self, world, unit, extension_name, extension_init_data)
	return extension
end

function WhereaboutsSystem:extensions_ready(world, unit, extension_name)
	return end

function WhereaboutsSystem:hot_join_sync(sender, player)
	return end

function WhereaboutsSystem:update(context, t)
	WhereaboutsSystem.super.update(self, context, t)
end