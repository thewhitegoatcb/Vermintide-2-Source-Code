
GenericTrailExtension = class(GenericTrailExtension)

function GenericTrailExtension:init(extension_init_context, unit)
	self.unit = unit

	Unit.flow_event(unit, "lua_trail")
end