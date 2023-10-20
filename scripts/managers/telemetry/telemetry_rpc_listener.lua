local RPCS = { "rpc_to_client_sync_session_id" }



TelemetryRPCListener = class(TelemetryRPCListener)

function TelemetryRPCListener:init(events)
	self._events = events
end

function TelemetryRPCListener:register(network_event_delegate)
	network_event_delegate:register(self, unpack(RPCS))
end

function TelemetryRPCListener:unregister(network_event_delegate)
	network_event_delegate:unregister(self)
end

function TelemetryRPCListener:rpc_to_client_sync_session_id(channel_id, session_id)
	print("[TelemetryRPCListener] Receiving session id from server", session_id)
	self._events:server_session_id(session_id)
end