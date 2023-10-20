ActionDummy = class(ActionDummy, ActionBase)

function ActionDummy:init(world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	ActionDummy.super.init(self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	self._owner_unit = owner_unit
	self.status_extension = ScriptUnit.has_extension(owner_unit, "status_system")
	self.spread_extension = ScriptUnit.has_extension(weapon_unit, "spread_system")
end

function ActionDummy:client_owner_start_action(new_action, t)
	ActionDummy.super.client_owner_start_action(self, new_action, t)
	self.current_action = new_action
	self.action_time_started = t


	local spread_template_override = new_action.spread_template_override

	if spread_template_override then
		self.spread_extension:override_spread_template(spread_template_override)
	end

end

function ActionDummy:client_owner_post_update(dt, t, world, can_damage)
	return end

function ActionDummy:finish(reason)
	if self.spread_extension then
		self.spread_extension:reset_spread_template()
	end

	Unit.flow_event(self.owner_unit, "lua_force_stop")
	Unit.flow_event(self.first_person_unit, "lua_force_stop")
end