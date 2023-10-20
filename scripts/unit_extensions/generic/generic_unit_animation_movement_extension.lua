require("scripts/unit_extensions/generic/animation_movement_templates")

GenericUnitAnimationMovementExtension = class(GenericUnitAnimationMovementExtension)

function GenericUnitAnimationMovementExtension:init(extension_init_context, unit, extension_init_data)
	self.unit = unit
	local init_data_template_name = extension_init_data.template
	self.template = AnimationMovementTemplates [init_data_template_name]
	self.network_type = extension_init_data.is_husk and "husk" or "owner"
	self.data = { }
	self.enabled = false
end

function GenericUnitAnimationMovementExtension:extensions_ready()
	local template = self.template
	template [self.network_type].init(self.unit, self.data)

	local breed = Unit.get_data(self.unit, "breed")
end

function GenericUnitAnimationMovementExtension:destroy()
	local template = self.template
	template [self.network_type].leave(self.unit, self.data)
	self.template = nil
	self.data = nil
end

function GenericUnitAnimationMovementExtension:reset()
	return end

function GenericUnitAnimationMovementExtension:set_enabled(enable)
	self.enabled = enable

	if not enable then
		self.leave = true
	end
end

function GenericUnitAnimationMovementExtension:update(unit, input, dt, context, t)
	local data = self.data
	local template = self.template
	local enabled = self.enabled

	if enabled then
		template [self.network_type].update(unit, t, dt, data)
	elseif self.leave then
		template [self.network_type].leave(unit, data)
		self.leave = false
	end
end