require("scripts/unit_extensions/generic/aim_templates")

GenericUnitAimExtension = class(GenericUnitAimExtension)

function GenericUnitAimExtension:init(extension_init_context, unit, extension_init_data)
	self.unit = unit
	self.template = AimTemplates [extension_init_data.template or Unit.get_data(unit, "aim_template")]
	self.network_type = extension_init_data.is_husk and "husk" or "owner"
	self.data = { }
	self.enabled = false
end

function GenericUnitAimExtension:extensions_ready()
	local template = self.template
	template [self.network_type].init(self.unit, self.data)

	local breed = Unit.get_data(self.unit, "breed")
	self.always_aim = DEDICATED_SERVER or breed and breed.always_look_at_target or self.template == "innkeeper"
end

function GenericUnitAimExtension:destroy()
	local template = self.template
	template [self.network_type].leave(self.unit, self.data)
	self.template = nil
	self.data = nil
end

function GenericUnitAimExtension:reset()
	return end

function GenericUnitAimExtension:set_enabled(enable)
	self.enabled = enable
end

function GenericUnitAimExtension:update(unit, input, dt, context, t)
	local data = self.data
	local template = self.template
	local is_player = DamageUtils.is_player_unit(unit)
	local should_aim = self.enabled or self.always_aim or is_player
	if should_aim then
		template [self.network_type].update(unit, t, dt, data)
	else
		template [self.network_type].leave(unit, data)
	end
end