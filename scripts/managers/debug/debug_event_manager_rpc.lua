DebugEventManagerRPC = class(DebugEventManagerRPC)

function DebugEventManagerRPC:init(network_event_delegate)
	self._event_delegate = network_event_delegate
	self._event_delegate:register(self, "rpc_event_manager_event")
end

function DebugEventManagerRPC:rpc_event_manager_event(channel_id, ...)

	local event_manager = Managers.state.event
	if event_manager then
		event_manager:trigger(...)
	end
end

function DebugEventManagerRPC:destroy()
	self._event_delegate:unregister(self)
end