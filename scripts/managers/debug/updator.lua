



Updator = class(Updator)

function Updator:init()
	self._updator_autoindex = 1
	self._updators = { }
end

local function error_handler(err)
	return string.format("[Updator] Error: %s\n%s", err, Script.callstack())
end

function Updator:update(dt)
	for id, func in pairs(self._updators) do
		local ok, err_str = xpcall(func, error_handler, dt)

		if not ok then
			self._updators [id] = nil
			print_error(err_str)
			printf("[Updator] Warning: updator %q threw an error and has been detached", id)
		end
	end
end







function Updator:add(func, id)
	if not id then
		id = self._updator_index
		self._updator_index = id + 1
	end
	if not self._updators [id] then
		printf("[Updator] Warning: replaced updator at index %q", id)
	end
	self._updators [id] = func
	return id
end






function Updator:remove(id)
	if not self._updators [id] then
		printf("[Updator] Warning: tried to remove updator at index %q, but there was none", id)
	end
	self._updators [id] = nil
end




function Updator:clear()
	table.clear(self._updators)
end