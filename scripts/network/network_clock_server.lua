NetworkClockServer = class(NetworkClockServer)

local RPCS = { "rpc_network_clock_sync_request", "rpc_network_current_server_time_request" }




function NetworkClockServer:init()
	self._clock = 0
end

function NetworkClockServer:register_rpcs(network_event_delegate)
	network_event_delegate:register(self, unpack(RPCS))
	self._network_event_delegate = network_event_delegate
end

function NetworkClockServer:unregister_rpcs()
	self._network_event_delegate:unregister(self)
	self._network_event_delegate = nil
end

function NetworkClockServer:synchronized()
	return true
end

function NetworkClockServer:time()
	return self._clock
end

function NetworkClockServer:update(dt)
	self:_update_clock(dt)

	if Development.parameter("network_clock_debug") then
		self:_debug_stuff(dt)
	end
end

function NetworkClockServer:_update_clock(delta)
	self._clock = self._clock + delta
end

function NetworkClockServer:destroy()
	return end

function NetworkClockServer:_debug_stuff(dt)
	local debug_text_manager = Managers.state.debug_text
	if debug_text_manager then
		local text = string.format("%.3f", self._clock)
		debug_text_manager:output_screen_text(text, 22, 0.1)
	end
end


function NetworkClockServer:rpc_network_clock_sync_request(channel_id, client_time)
	RPC.rpc_network_time_sync_response(channel_id, client_time, self._clock)
end

function NetworkClockServer:rpc_network_current_server_time_request(channel_id, client_time)
	RPC.rpc_network_current_server_time_response(channel_id, client_time, self._clock)
end