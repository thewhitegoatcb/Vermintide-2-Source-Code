








BEQueueItem = class(BEQueueItem)

function BEQueueItem:init(caller, queue_id, script_name, ...)
	fassert(caller and caller == "DataServerQueue", "Only poll BEQueueItem from DataServerQueue")
	self._queue_id = queue_id
	self._script_name = script_name
	self._data = { ... }
end

function BEQueueItem:disable_registered_commands()
	self._disable_registered_commands = true
end

function BEQueueItem:submit_request(caller)
	fassert(caller and caller == "DataServerQueue", "Only poll BEQueueItem from DataServerQueue")

	BackendSession.item_server_script(self._script_name, "queue_id", self._queue_id, unpack(self._data))
end

function BEQueueItem:poll_backend(caller)
	fassert(caller and caller == "DataServerQueue", "Only poll BEQueueItem from DataServerQueue")
	local items, parameters, error_message = BackendSession.poll_item_server()
	if items then
		if error_message or parameters.queue_id ~= self._queue_id then

			local error_string = "Backend data server error"
			error_string = error_string .. "\n script: " .. self._script_name
			error_string = error_string .. "\n error_message.details : " .. tostring(error_message.details)
			error_string = error_string .. "\n error_message.reason : " .. tostring(error_message.reason)
			error_string = error_string .. "\n queue_id: " .. tostring(self._queue_id) .. " (expected)"
			error_string = error_string .. "\n queue_id: " .. tostring(parameters.queue_id) .. " (actual)"

			error_string = error_string .. "\n parameters:"
			local num_parameters = #self._data
			if num_parameters > 0 then
				for ii = 1, 2, num_parameters do
					local key = self._data [ii]
					local value = self._data [ii + 1]
					error_string = error_string .. "\n  " .. tostring(key) .. ": " .. tostring(value)
				end
			end
			Crashify.print_exception("DataServerQueue", error_string)
		end

		self._is_done = true
		self._items = items
		self._parameters = parameters
		self._error_message = error_message

		for backend_id, _ in pairs(items) do
			ItemHelper.mark_backend_id_as_new(backend_id)
		end
		local backend_items = Managers.backend:get_interface("items")
		backend_items:__dirtify()
	end
end

function BEQueueItem:items()
	fassert(self._is_done, "Request hasn't completed yet")
	return self._items
end

function BEQueueItem:parameters()
	fassert(self._is_done, "Request hasn't completed yet")
	return self._parameters
end

function BEQueueItem:error_message()
	fassert(self._is_done, "Request hasn't completed yet")
	return self._error_message
end

function BEQueueItem:use_registered_commands()
	return not self._disable_registered_commands
end

function BEQueueItem:is_done()
	return self._is_done
end










BECommands = class(BECommands)

function BECommands:init()
	self._executors = { }

	self:register_executor("command_group", callback(self, "_command_group_executor"))
end

function BECommands:register_executor(executor_name, executor)

	self._executors [executor_name] = executor
end

function BECommands:unregister_executor(executor_name)

	self._executors [executor_name] = nil
end

function BECommands:execute(queue_item)
	local commands = queue_item:parameters()
	for command, json_data in pairs(commands) do
		if command ~= "queue_id" then
			local data = cjson.decode(json_data)
			self:_execute(command, data)
		end
	end
end

function BECommands:_execute(command, data)
	local executor = self._executors [command]
	executor(data)
end

function BECommands:_command_group_executor(commands)
	for command, data in pairs(commands) do
		self:_execute(command, data)
	end
end










DataServerQueue = class(DataServerQueue)

function DataServerQueue:init()
	self._queue_id = 0
	self._queue = { }
	self._error_items = { }

	self._command_executors = BECommands:new()
end

function DataServerQueue:_next_queue_id()
	self._queue_id = self._queue_id + 1
	return tostring(self._queue_id)
end

function DataServerQueue:add_item(script_name, ...)
	local queue_id = self:_next_queue_id()
	local item = BEQueueItem:new("DataServerQueue", queue_id, script_name, ...)
	if #self._queue == 0 then
		item:submit_request("DataServerQueue")
	end

	table.insert(self._queue, item)

	return item
end

function DataServerQueue:register_executor(executor_name, executor)
	self._command_executors:register_executor(executor_name, executor)
end

function DataServerQueue:unregister_executor(executor_name)
	self._command_executors:unregister_executor(executor_name)
end

function DataServerQueue:clear()
	self._queue = { }
end

function DataServerQueue:update()

	local current = self._queue [1]
	if current then
		current:poll_backend("DataServerQueue")
		if current:is_done() then
			if current:error_message() then
				table.insert(self._error_items, current)
			elseif current:use_registered_commands() then
				self._command_executors:execute(current)
			end

			table.remove(self._queue, 1)
			local new_item = self._queue [1]

			if new_item then
				new_item:submit_request("DataServerQueue")
			end
		end
	end

end

function DataServerQueue:check_for_errors()
	if #self._error_items > 0 then
		local error_item = table.remove(self._error_items, 1)
		local error_message = error_item:error_message()
		return { reason = "data_server_error", details = error_message.details }
	end
end

function DataServerQueue:num_current_requests()
	return #self._queue
end