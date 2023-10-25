require("scripts/unit_extensions/default_player_unit/buffs/buff_area_extension")

BuffAreaSystem = class(BuffAreaSystem, ExtensionSystemBase)

local extensions = { "BuffAreaExtension" }



function BuffAreaSystem:init(entity_system_creation_context, system_name)
	BuffAreaSystem.super.init(self, entity_system_creation_context, system_name, extensions)

	self._inside_by_side_and_template = { }
	self._inside_by_area = { }
end

function BuffAreaSystem:on_add_extension(world, unit, extension_name, ...)
	local buff_area_extension = BuffAreaSystem.super.on_add_extension(self, world, unit, extension_name, ...)
	local buff_template = buff_area_extension.template

	if buff_template.shared_area then
		local side = buff_area_extension.side
		local name = buff_template.name

		local inside = self._inside_by_side_and_template
		inside [side] = inside [side] or { }

		inside = inside [side]
		inside [name] = inside [name] or {
			by_broadphase = { },
			by_position = { } }
	else

		self._inside_by_area [buff_area_extension] = {
			by_broadphase = { },
			by_position = { } }
	end


	return buff_area_extension
end


function BuffAreaSystem:inside_by_area(buff_area_extension)
	local template = buff_area_extension.template
	if template.shared_area then
		local side = buff_area_extension.side
		local name = template.name

		do return self._inside_by_side_and_template [side] [name] end
	else
		return self._inside_by_area [buff_area_extension]
	end
end