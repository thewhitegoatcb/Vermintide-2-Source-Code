InvincibleHealthExtension = class(InvincibleHealthExtension, GenericHealthExtension)

function InvincibleHealthExtension:init(extension_init_context, unit, extension_init_data)
	self.unit = unit
	self.is_server = Managers.player.is_server
	self.system_data = extension_init_context.system_data
	self.statistics_db = extension_init_context.statistics_db
	self.damage_buffers = { pdArray.new(), pdArray.new() }
	self.network_transmit = extension_init_context.network_transmit

	self.is_invincible = true
	self.health = NetworkConstants.health.max
	self.damage = 0
	self.state = "alive"
end

function InvincibleHealthExtension:destroy()
	return end

function InvincibleHealthExtension:reset()
	return end

function InvincibleHealthExtension:hot_join_sync(sender)
	return end

function InvincibleHealthExtension:is_alive()
	return true
end

function InvincibleHealthExtension:current_health_percent()
	return 1
end

function InvincibleHealthExtension:current_health()
	return self.health
end

function InvincibleHealthExtension:get_max_health()
	return self.health
end

function InvincibleHealthExtension:set_max_health(health, update_unmodfied)
	return end

function InvincibleHealthExtension:get_damage_taken()
	return 0
end

function InvincibleHealthExtension:set_current_damage(damage)
	return end

function InvincibleHealthExtension:die(damage_type)
	fassert(false, "Tried to kill InvincibleHealthExtension")
end

function InvincibleHealthExtension:set_dead()
	return end

function InvincibleHealthExtension:apply_client_predicted_damage(predicted_damage)
	return end