local function get_median(list)
	local n = #list
	local median = nil
	if n % 2 == 0 then
		local i1 = n / 2
		local i2 = i1 + 1

		local d1 = list [i1]
		local d2 = list [i2]

		median = ( d1 + d2 ) / 2
	else
		local i = math.ceil(n / 2)
		median = list [i]
	end

	return median
end

local function get_mean(list)
	local n = #list
	local s = 0
	for i = 1, n do
		s = s + list [i]
	end

	local mean = s / n
	return mean
end

local function get_sd(list, median)
	local n = #list

	local differences = 0
	for i = 1, n do
		local val = list [i]
		local difference_squared = ( val - median ) ^ 2
		differences = differences + difference_squared
	end
	local variance = differences / n
	local sd = math.sqrt(variance)
	return sd
end

NetworkClockClient = class(NetworkClockClient)

local RPCS = { "rpc_network_time_sync_response", "rpc_network_current_server_time_response" }




function NetworkClockClient:init()
	self._clock = 0

	self._delta_mean = nil
	self._delta_history = { }

	self._request_timer = 0
	self._times_synced = 0

	self._state = "syncing"
end

function NetworkClockClient:register_rpcs(network_event_delegate)
	network_event_delegate:register(self, unpack(RPCS))
	self._network_event_delegate = network_event_delegate
end

function NetworkClockClient:unregister_rpcs()
	self._network_event_delegate:unregister(self)
	self._network_event_delegate = nil
end

function NetworkClockClient:synchronized()
	return self._state == "synced" and true or false
end

function NetworkClockClient:time()
	return self._clock
end

local INIT_SYNC_TIME_STEP = 3
local INIT_SYNC_TIMES = 6
local SYNC_TIME_STEP = 2
function NetworkClockClient:update(dt)
	if self._state == "syncing" then
		self:_update_clock(dt)

		local network_manager = Managers.state.network
		if not network_manager:in_game_session() then
			return
		end

		local request_timer = self._request_timer + dt
		if INIT_SYNC_TIME_STEP <= request_timer and self._times_synced < INIT_SYNC_TIMES then
			request_timer = 0
			self._times_synced = self._times_synced + 1
			network_manager.network_transmit:send_rpc_server("rpc_network_clock_sync_request", self._clock)
		end
		self._request_timer = request_timer
	elseif self._state == "synced" then
		self:_update_clock(dt)

		local network_manager = Managers.state.network
		if not network_manager:in_game_session() then
			return
		end

		local request_timer = self._request_timer + dt
		if SYNC_TIME_STEP <= request_timer then
			request_timer = 0
			network_manager.network_transmit:send_rpc_server("rpc_network_current_server_time_request", self._clock)
		end
		self._request_timer = request_timer
	else
		printf("[NetworkClockClient] FAIL Unknown state: %q", self._state)
	end

	if Development.parameter("network_clock_debug") then
		self:_debug_stuff(dt)
	end
end

function NetworkClockClient:_update_clock(delta)
	local new_time = self._clock + delta
	if new_time < 0 then
		new_time = 0
		printf("[NetworkClockClient] delta (%f) larger than current time (%f), clamping resulting time to 0.", delta, self._clock)
	end
	self._clock = new_time
end

local function sort_function(a, b) return a < b end
function NetworkClockClient:_update_delta_history(delta)
	local delta_history = self._delta_history
	delta_history [#delta_history + 1] = delta
	table.sort(delta_history, sort_function)
	self._delta_history = delta_history
end

function NetworkClockClient:_calculate_mean_dt()
	local delta_history = self._delta_history
	local median = get_median(delta_history)
	local sd = get_sd(delta_history, median)


	local n = #delta_history
	local i = 1
	while n >= i do
		local dt = delta_history [i]
		if dt > median + sd or dt < median - sd then
			table.remove(delta_history, i)
			n = n - 1
		else
			i = i + 1
		end
	end

	self._mean_dt = get_mean(delta_history)
	self._delta_history = delta_history
end

function NetworkClockClient:destroy()
	return end

function NetworkClockClient:_debug_stuff(dt)
	local debug_text_manager = Managers.state.debug_text
	if debug_text_manager then
		local text = string.format("%.3f", self._clock)
		debug_text_manager:output_screen_text(text, 22, 0.1)
	end

	if Keyboard.pressed(Keyboard.button_index("p")) then
		print("<[NetworkClockClient] DEBUG INFO>")
		printf("state: %q", self._state)
		printf("mean dt: %q", self._mean_dt)
		table.dump(self._delta_history, "delta_history")
		print("</[NetworkClockClient] DEBUG INFO>")
	end
end


function NetworkClockClient:rpc_network_time_sync_response(channel_id, time_sent_request, server_time)
	local current_time = self._clock
	local client_latency_delta = ( current_time - time_sent_request ) / 2
	local client_server_delta = server_time - current_time
	local delta = client_server_delta + client_latency_delta

	if #self._delta_history == 0 then
		self:_update_clock(delta)
	end
	self:_update_delta_history(delta)

	if INIT_SYNC_TIMES <= self._times_synced then
		self:_calculate_mean_dt()
		self:_update_clock(self._mean_dt)
		self._state = "synced"
		self._request_timer = 0
	end
end

function NetworkClockClient:rpc_network_current_server_time_response(channel_id, time_sent_request, server_time)
	local current_time = self._clock
	local client_latency_delta = ( current_time - time_sent_request ) / 2
	local client_server_delta = server_time - current_time
	local delta = client_server_delta + client_latency_delta

	self:_update_clock(delta)
end