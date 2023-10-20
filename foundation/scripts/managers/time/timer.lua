Timer = class(Timer)

function Timer:init(name, parent, start_time)
	self._t = start_time or 0
	self._dt = 0
	self._name = name
	self._active = true
	self._local_scale = 1
	self._global_scale = 1
	self._parent = parent
	self._children = { }
end

function Timer:update(dt, global_scale)
	local local_scale = self._local_scale
	dt = math.max(dt * local_scale, 1e-06)
	global_scale = global_scale * local_scale

	for name, child in pairs(self._children) do
		if child:active() then
			child:update(dt, global_scale)
		end
	end

	self._dt = dt
	self._t = self._t + dt
	self._global_scale = global_scale
end

function Timer:name()
	return self._name
end

function Timer:set_time(time)
	self._t = time
end

function Timer:time()
	return self._t
end

function Timer:time_and_delta()
	return self._t, self._dt
end

function Timer:active()
	return self._active
end

function Timer:set_active(active)
	self._active = active
end

function Timer:set_local_scale(scale)
	self._local_scale = scale
end

function Timer:local_scale()
	return self._local_scale
end

function Timer:global_scale()
	return self._global_scale
end

function Timer:add_child(timer)
	self._children [timer:name()] = timer
end

function Timer:remove_child(timer)
	self._children [timer:name()] = nil
end

function Timer:children()
	return self._children
end

function Timer:parent()
	return self._parent
end

function Timer:destroy()
	self._parent = nil
	self._children = nil
end

function Timer:delta_time()
	return self._dt
end