ScriptPSRestrictionToken = class(ScriptPSRestrictionToken)

function ScriptPSRestrictionToken:init(token)
	self._token = token
	self._done = false
end

function ScriptPSRestrictionToken:update()
	local status = NpCheck.status(self._token)

	if status == NpCheck.COMPLETED or status == NpCheck.ERROR then
		self._done = true
	end
end

function ScriptPSRestrictionToken:info()
	local info = { }

	local status = NpCheck.status(self._token)
	if status == NpCheck.ERROR then
		info.error = NpCheck.error_code(self._token)
	else
		info.result = NpCheck.result(self._token)
	end

	info.token = self._token

	return info
end

function ScriptPSRestrictionToken:done()
	return self._done
end

function ScriptPSRestrictionToken:close()
	NpCheck.free(self._token)
end