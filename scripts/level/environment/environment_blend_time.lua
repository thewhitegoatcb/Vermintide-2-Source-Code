EnvironmentBlendTime = class(EnvironmentBlendTime)

function EnvironmentBlendTime:init(data)
	self._environment = data.environment
	self._blend_function = data.blend_function
	self._lerp_in_speed = data.lerp_in_speed
	self._lerp_out_speed = data.lerp_out_speed
	self._lerp_speed = self._lerp_in_speed
	fassert(self._lerp_speed, self._environment)
	self._value = 0
	self._target_value = 0

	Managers.state.event:register(self, "force_blend_environment_volume", "event_force_blend_environment_volume")
end

function EnvironmentBlendTime:event_force_blend_environment_volume()
	self._force_blend = true
end

function EnvironmentBlendTime:environment()
	return self._environment
end

function EnvironmentBlendTime:value()
	return self._value
end

function EnvironmentBlendTime:update(dt)
	if self._blend_function(self._environment) then
		self._target_value = 1
		self._lerp_speed = self._lerp_in_speed
	else
		self._target_value = 0
		self._lerp_speed = self._lerp_out_speed
	end

	if self._force_blend then
		self._value = self._target_value
		self._force_blend = false
	else
		self._value = math.lerp(self._value, self._target_value, self._lerp_speed * dt)
	end

end

function EnvironmentBlendTime:destroy()
	local event_manager = Managers.state.event
	if event_manager then
		event_manager:unregister("force_blend_environment_volume", self)
	end
end