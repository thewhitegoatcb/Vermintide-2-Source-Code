TokenManager = class(TokenManager)

function TokenManager:init()
	self._tokens = { }
end

function TokenManager:register_token(token, callback, timeout)
	self._tokens [#self._tokens + 1] = { token = token, callback = callback, timeout = timeout or math.huge }
end

function TokenManager:update(dt, t)
	for id, entry in pairs(self._tokens) do
		local token = entry.token
		token:update()

		if token:done() or entry.timeout <= t then
			local callback = entry.callback

			if callback then
				local info = token:info()
				callback(info)
			end

			token:close()
			self._tokens [id] = nil
		end
	end
end

function TokenManager:destroy()
	for id, entry in pairs(self._tokens) do
		local token = entry.token
		token:close()
		self._tokens [id] = nil
	end
	self._tokens = nil
end