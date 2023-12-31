
local PlayFabClientApi = require("PlayFab.PlayFabClientApi")

BackendInterfaceLiveEventsPlayfab = class(BackendInterfaceLiveEventsPlayfab)

function BackendInterfaceLiveEventsPlayfab:init(backend_mirror)
	self.is_local = false
	self._backend_mirror = backend_mirror
	self._last_id = 0
	self._live_events = { }
	self._completed_live_event_requests = { }

	local backend_manager = Managers.backend
	local live_events_string = backend_manager:get_title_data("live_events_v2") or backend_manager:get_title_data("live_events")
	local live_events = live_events_string and cjson.decode(live_events_string) or { }

	if is_array(live_events) then
		self._live_events = {
			weekly_events = live_events }
	else

		self._live_events = live_events
	end
end

function BackendInterfaceLiveEventsPlayfab:ready()
	return true
end

function BackendInterfaceLiveEventsPlayfab:update(dt)
	return end

function BackendInterfaceLiveEventsPlayfab:_new_id()
	self._last_id = self._last_id + 1

	return self._last_id
end

function BackendInterfaceLiveEventsPlayfab:request_live_events()
	local id = self:_new_id()
	local request = { FunctionName = "getLiveEvents",

		FunctionParameter = {
			id = id } }



	local success_callback = callback(self, "request_live_events_cb", id)
	local request_queue = self._backend_mirror:request_queue()

	request_queue:enqueue(request, success_callback, false)

	return id
end

function BackendInterfaceLiveEventsPlayfab:request_live_events_cb(id, result)
	local function_result = result.FunctionResult
	local live_events_json = function_result.live_events
	local live_events = { }

	if live_events_json then
		live_events = cjson.decode(live_events_json)
	end

	if is_array(live_events) then
		self._live_events = {
			weekly_events = live_events }
	else

		self._live_events = live_events
	end

	self._completed_live_event_requests [id] = true
end

function BackendInterfaceLiveEventsPlayfab:live_events_request_complete(id)
	local complete = self._completed_live_event_requests [id]

	return complete
end

function BackendInterfaceLiveEventsPlayfab:get_weekly_events()
	return self._live_events.weekly_events
end

function BackendInterfaceLiveEventsPlayfab:get_special_events()
	return self._live_events.special_events
end

function BackendInterfaceLiveEventsPlayfab:get_weekly_events_game_mode_data()
	local weekly_event_data = self._live_events.weekly_events
	for i = 1, #weekly_event_data do
		local event = weekly_event_data [i]
		if event.game_mode_data then
			return event.game_mode_data
		end
	end
end

function BackendInterfaceLiveEventsPlayfab:request_twitch_app_access_token(cb)
	local request = { FunctionName = "getTwitchAccessToken",

		FunctionParameter = { force = true } }




	local success_callback = callback(self, "_request_twitch_app_access_token_cb", cb)
	local request_queue = self._backend_mirror:request_queue()

	request_queue:enqueue(request, success_callback, false)
end

function BackendInterfaceLiveEventsPlayfab:_request_twitch_app_access_token_cb(cb, result)
	local function_result = result.FunctionResult
	local access_token = function_result.access_token
	if access_token then
		self._backend_mirror:set_twitch_app_access_token(access_token)
	end

	if cb then
		cb(access_token)
	end
end