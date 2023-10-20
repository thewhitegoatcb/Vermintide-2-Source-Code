CircularQueue = class(CircularQueue)

function CircularQueue:init(capacity)
	self.queue = { }
	self.capacity = capacity
	self.first = 1
	self.last = capacity
	self.num_items = 0
end

function CircularQueue:push_back(item)
	fassert(item ~= nil, "Queue can't contain nil item!")
	self.last = self.last % self.capacity + 1
	fassert(self.num_items < self.capacity, "Can't push to full queue (%d).", self.capacity)
	self.num_items = self.num_items + 1
	self.queue [self.last] = item

end

function CircularQueue:write_at(item, index)
	ferror("Disabled this for now, should probably assert that index is within first->last")
	fassert(item ~= nil, "Queue can't contain nil item!")
	fassert(index > 0 and index <= self.capacity, "Wrong index!")

end

function CircularQueue:pop_first()
	fassert(self.num_items > 0, "Can't pop empty queue.")
	local item = self.queue [self.first]
	self.queue [self.first] = nil
	self.num_items = self.num_items - 1
	self.first = self.first % self.capacity + 1
	fassert(self.num_items == 0 or self.queue [self.first] ~= nil, "Queue contained nil item!")

	return item
end

function CircularQueue:reset()
	self.first = 1
	self.last = self.capacity
	self.num_items = 0
end

function CircularQueue:contains(item)
	local curr = self.first
	local queue = self.queue
	for i = 1, self.num_items do
		local queued_item = queue [curr]
		if item == queued_item then
			return true
		end
		curr = curr % self.capacity + 1
	end

	return false
end

function CircularQueue:size()
	return self.num_items
end

function CircularQueue:available()
	return self.capacity - self.num_items
end

function CircularQueue:is_full()
	return self.num_items == self.capacity
end

function CircularQueue:is_empty()
	return self.num_items == 0
end

function CircularQueue:get_first()
	return self.queue [self.first]
end

function CircularQueue:get_last()
	return self.queue [self.last]
end

function CircularQueue:foreach(obj, func, ...)
	local curr_index = self.first
	local queue = self.queue
	local capacity = self.capacity
	for i = 1, self.num_items do
		local queued_item = queue [curr_index]
		if obj then
			func(obj, queued_item, ...)
		else
			func(queued_item, ...)
		end
		curr_index = curr_index % capacity + 1
	end
end

function CircularQueue:index_before(index)
	return ( index - 2 ) % self.capacity + 1
end

function CircularQueue:index_after(index)
	return index % self.capacity + 1
end

function CircularQueue:tostring(tostringfunc, max_count)
	tostringfunc = tostringfunc or tostring
	max_count = max_count or self.num_items
	local s = string.format("{[%d->%d][%d/%d] ", self.first, self.last, self.num_items, self.capacity)
	local curr = self.first
	local queue = self.queue
	for i = 1, math.min(max_count, self.num_items) do
		s = s .. tostringfunc(queue [curr]) .. ","
		curr = curr % self.capacity + 1
	end
	if max_count < self.num_items then
		s = s .. "... "
	end

	s = s .. "}"
	return s
end


function CircularQueue:tostring2(tostringfunc, max_count)
	tostringfunc = tostringfunc or tostring
	max_count = max_count or self.num_items
	local s = string.format("{[%d->%d][%d/%d] ", self.first, self.last, self.num_items, self.capacity)
	local queue = self.queue
	for i = 1, math.min(max_count, self.capacity) do
		s = s .. (queue [i] and tostringfunc(queue [i]) or "_") .. ","
	end
	if max_count < self.num_items then
		s = s .. "... "
	end

	s = s .. "}"
	return s
end

function CircularQueue:print_items(s)
	local s = ( s or "" ) .. " queue: [" .. self.first .. "->" .. self.last .. "] --> "
	local curr = self.first
	local queue = self.queue
	for i = 1, self.num_items do
		s = s .. tostring(queue [curr]) .. ","
		curr = curr % self.capacity + 1
	end
	print(s)
end