ScriptXboxUserPrivilegeToken = class(ScriptXboxUserPrivilegeToken)

function ScriptXboxUserPrivilegeToken:init(token)
	self._token = token
	self._result = { }
end

function ScriptXboxUserPrivilegeToken:update()
	local in_progress, done, error, status_code = UserPrivilege.status(self._token)

	self._result.in_progress = in_progress
	self._result.done = done
	self._result.error = error
	self._result.status_code = status_code
end

function ScriptXboxUserPrivilegeToken:info()
	local info = { }
	if self._result.error then
		info.error = self._result.error
		info.status_code = self._result.status_code
	else
		info.status_code = self._result.status_code
	end

	return info
end

function ScriptXboxUserPrivilegeToken:done()
	return self._result.done
end

function ScriptXboxUserPrivilegeToken:close()
	UserPrivilege.release(self._token)
end