GenericAggroableExtension = class(GenericAggroableExtension)

function GenericAggroableExtension:init(extension_init_context, unit, extension_init_data)

	self.aggro_modifier_passive = Unit.has_data(unit, "aggro_modifier_passive") and Unit.get_data(unit, "aggro_modifier_passive") * -1 or 0
	self.aggro_modifier_active = Unit.has_data(unit, "aggro_modifier_active") and Unit.get_data(unit, "aggro_modifier_active") * -1 or 0

	self:use_passive_aggro()
end

function GenericAggroableExtension:use_passive_aggro()
	self.aggro_modifier = self.aggro_modifier_passive
end

function GenericAggroableExtension:use_active_aggro()
	self.aggro_modifier = self.aggro_modifier_active
end

function GenericAggroableExtension:destroy()
	return end