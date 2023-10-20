TargetHealthExtension = class(TargetHealthExtension)

function TargetHealthExtension:init(extension_init_context, unit, extension_init_data)
	self.unit = unit
	self.is_server = Managers.player.is_server
	self._dead = false
	self._out_of_combat_timer = 0
	self._health_regen_timer = 0

	self._damage_per_hit = extension_init_data.damage_per_hit or 1
	self._health = extension_init_data.health or Unit.get_data(unit, "health") or 1
	self._max_health = self._health
	self._health_regen = { interval = 1, out_of_combat_only = false, out_of_combat_delay = 0, amount = 0 }





	for key, value in pairs(extension_init_data.health_regen or { }) do
		self._health_regen [key] = value
	end

	self.damage_buffers = { pdArray.new(), pdArray.new() }
end

function TargetHealthExtension:update(dt, t)
	local heal_amount = self._health_regen.amount
	local heal_interval = self._health_regen.interval

	if heal_amount <= 0 or heal_interval < 0 then
		return
	end

	local out_of_combat_only = self._health_regen.out_of_combat_only
	local out_of_combat_delay = self._health_regen.out_of_combat_delay

	self._out_of_combat_timer = math.min(self._out_of_combat_timer + dt, out_of_combat_delay)
	if out_of_combat_only and self._out_of_combat_timer < out_of_combat_delay then
		return
	end

	if heal_interval <= self._health_regen_timer then
		self:add_heal(heal_amount)
		self._health_regen_timer = 0
	else
		self._health_regen_timer = math.min(self._health_regen_timer + dt, heal_interval)
	end
end

function TargetHealthExtension:add_damage(...)


	if not self:is_dead() then
		self._health = math.max(self._health - self._damage_per_hit, 0)
		self._out_of_combat_timer = 0
		if self:_should_die() then
			self:set_dead()
		end
	end


end

function TargetHealthExtension:add_heal(amount)
	if not self:is_dead() then
		self._health = math.min(self._health + amount, self._max_health)
	end
end

function TargetHealthExtension:is_dead()
	return self._dead
end

function TargetHealthExtension:is_alive()
	return not self._dead
end

function TargetHealthExtension:set_dead()
	self._dead = true
	self._health = 0
	HEALTH_ALIVE [self.unit] = nil
end

function TargetHealthExtension:_should_die()
	return self._health <= 0
end

function TargetHealthExtension:current_health()
	return self._health
end

function TargetHealthExtension:current_health_percent()
	return 1
end

function TargetHealthExtension:current_max_health_percent()
	return 1
end

function TargetHealthExtension:get_is_invincible()
	return false
end

function TargetHealthExtension:has_assist_shield()
	return false
end

function TargetHealthExtension:get_damage_taken()
	return self._max_health - self._health
end

function TargetHealthExtension:get_health_regen()
	return self._health_regen
end

function TargetHealthExtension:client_predicted_is_alive()
	return not self:is_dead()
end

function TargetHealthExtension:apply_client_predicted_damage(predicted_damage)
	return end

function TargetHealthExtension:get_max_health()
	return self._max_health
end