RatOgreHealthExtension = class(RatOgreHealthExtension, GenericHealthExtension)

function RatOgreHealthExtension:init(extension_init_context, unit, ...)
	RatOgreHealthExtension.super.init(self, extension_init_context, unit, ...)
	self._wounded_anim_variable = Unit.animation_find_variable(unit, "wounded")
end

function RatOgreHealthExtension:update(dt, ...)
	local unit = self.unit
	local wounded_value = self.damage / self.health > 0.5 and 1 or 0
	Unit.animation_set_variable(unit, self._wounded_anim_variable, wounded_value)
end