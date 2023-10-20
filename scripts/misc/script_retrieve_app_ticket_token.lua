ScriptReceiveAppTicketToken = class(ScriptReceiveAppTicketToken)

function ScriptReceiveAppTicketToken:init()
	self._done = false
	self._error = true
end

function ScriptReceiveAppTicketToken:update()
	local encrypted_app_ticket = Steam.poll_encrypted_app_ticket()
	if encrypted_app_ticket then
		self._encrypted_app_ticket = encrypted_app_ticket
		self._done = true
		self._error = false
	end
end

function ScriptReceiveAppTicketToken:info()
	local info = {
		encrypted_app_ticket = self._encrypted_app_ticket,
		error = self._error }

	return info
end

function ScriptReceiveAppTicketToken:done()
	return self._done
end

function ScriptReceiveAppTicketToken:close() return end