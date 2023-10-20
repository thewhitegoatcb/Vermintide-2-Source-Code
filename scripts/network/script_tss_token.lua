ScriptTssToken = class(ScriptTssToken)

function ScriptTssToken:init(token)
	self._token = token
	self._done = false

	self._result = nil
end

function ScriptTssToken:update()
	local token = self._token
	local done = Tss.has_result(token)

	if Tss.has_result(token) then
		local done, result = Tss.get_result(token)

		self._done = done
		self._result = result
	end
end

function ScriptTssToken:info()
	local info = {

		result = self._result }

	return info
end

function ScriptTssToken:done()
	return self._done
end

function ScriptTssToken:close()
	Tus.free(self._token)
end