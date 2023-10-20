ScriptPresenceToken = class(ScriptPresenceToken)

function ScriptPresenceToken:init(token)
	self._token = token
	self._result = { }
	self._done = false
end

function ScriptPresenceToken:update()
	local done, presence, error_code = Presence.status(self._token)
	self._done = done
	self._presence = presence
	self._error_code = error_code
end

function ScriptPresenceToken:info()
	local info = { }
	if self._error_code then
		info.error_code = self._error_code
	elseif self._presence then
		info.presence = self._presence
	end

	return info
end

function ScriptPresenceToken:done()
	return self._done
end

function ScriptPresenceToken:close()
	Presence.close(self._token)
end