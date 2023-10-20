LureHealthExtension = class(LureHealthExtension)

function LureHealthExtension:init(extension_init_context, unit, extension_init_data)
	self._unit = unit
	self._is_server = Managers.player.is_server

	self._attached_unit = extension_init_data.attached_unit
	self._lifetime = Managers.time:time("game") + extension_init_data.duration

	self.damage_buffers = { pdArray.new(), pdArray.new() }

	self._network_transmit = extension_init_context.network_transmit

	self._is_dead = false
end

function LureHealthExtension:destroy()
	return end

function LureHealthExtension:hot_join_sync(sender)
	return end

function LureHealthExtension:is_alive()
	return not self._is_dead
end

function LureHealthExtension:current_health_percent()
	return self._is_dead and 0 or 1
end

function LureHealthExtension:current_health()
	return 1
end

function LureHealthExtension:get_damage_taken()
	return 0
end

function LureHealthExtension:get_max_health()
	return 1
end

function LureHealthExtension:add_damage(...)
	if self._is_server and not self._is_dead and Unit.alive(self._attached_unit) then
		ScriptUnit.extension(self._attached_unit, "health_system"):add_damage(...)
	end
end

function LureHealthExtension:update(dt, context, t)
	if self._is_server and
	not self._is_dead and self._lifetime < t then
		local death_system = Managers.state.entity:system("death_system")
		death_system:kill_unit(self._unit, { })
	end

end

function LureHealthExtension:add_heal(...)

	return end

function LureHealthExtension:set_dead()
	self._is_dead = true
	HEALTH_ALIVE [self._unit] = nil
end

function LureHealthExtension:has_assist_shield()
	return false
end

function LureHealthExtension:client_predicted_is_alive()
	return self:is_alive()
end

function LureHealthExtension:apply_client_predicted_damage(predicted_damage)
	return end