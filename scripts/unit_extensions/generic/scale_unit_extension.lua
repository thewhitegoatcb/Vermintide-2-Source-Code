ScaleUnitExtension = class(ScaleUnitExtension)


function ScaleUnitExtension:init(extension_init_context, unit, extension_init_data)

	local t = Managers.time:time("game")

	self.start_size = extension_init_data.start_size
	local end_size = extension_init_data.end_size
	self.duration = extension_init_data.duration

	self.full_scale = end_size - self.start_size
	self.timer = 0


end

function ScaleUnitExtension:setup(start_size, end_size, duration)

	self.start_size = start_size or self.start_size
	self.full_scale = end_size - self.start_size
	self.duration = duration
	self.timer = 0
end

function ScaleUnitExtension:update(unit, input, dt, context, t)
	local timer = self.timer
	if timer < self.duration then
		local norm_time = math.clamp(timer / self.duration, 0, 1)
		local scale_value = self.start_size + math.easeCubic(norm_time) * self.full_scale

		local scale = Vector3(1, 1, scale_value)
		Unit.set_local_scale(unit, 0, scale)
		self.timer = self.timer + dt
	end
end

function ScaleUnitExtension:scaling_complete()
	return self.duration <= self.timer
end

function ScaleUnitExtension:despawn()


	return end