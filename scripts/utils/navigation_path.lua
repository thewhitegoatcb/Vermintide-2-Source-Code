NavigationPath = class(NavigationPath)

function NavigationPath:init(path, callback)
	self._path = { }
	self._current_index = 1
	self._callback = callback

	for i = 1, #path do
		self._path [i] = Vector3Box(path [i])
	end
end

function NavigationPath:current()
	return self._path [self._current_index]:unbox()
end

function NavigationPath:last()
	return self._path [#self._path]:unbox()
end

function NavigationPath:advance()
	self._current_index = self._current_index + 1
end

function NavigationPath:is_last()
	return self._current_index == #self._path
end

function NavigationPath:reset()
	self._current_index = 1
end

function NavigationPath:reverse()
	table.reverse(self._path)
end

function NavigationPath:callback()
	return self._callback
end

function NavigationPath:path()
	return self._path
end

function NavigationPath:draw(color, offset)
	local drawer = Managers.state.debug:drawer({ mode = "immediate", name = "nav_path" })
	local offset = offset or Vector3(0, 0, 0)

	local previous_node = nil
	for _, node in ipairs(self._path) do
		drawer:sphere(node:unbox() + Vector3.up() * 0.05 + offset, 0.05, color)
	end
end