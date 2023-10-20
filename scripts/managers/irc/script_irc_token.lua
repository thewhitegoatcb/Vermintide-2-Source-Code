ScriptIrcToken = class(ScriptIrcToken)

function ScriptIrcToken:init(token)
	self._token = token
	self._result = { }
	self._done = false
end

function ScriptIrcToken:update()
	local done, result = Irc.connect_async_status(self._token)

	self._done = done
	self._result = result
end

function ScriptIrcToken:info()
	local data = { }

	if self._done then
		data.result = self._result
	end

	return data
end

function ScriptIrcToken:done()
	return self._done
end

function ScriptIrcToken:close()
	Irc.release_token(self._token)
end