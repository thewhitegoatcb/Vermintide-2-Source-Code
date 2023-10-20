require("scripts/managers/telemetry/telemetry_manager_dummy")
require("scripts/managers/telemetry/telemetry_events")
require("scripts/managers/telemetry/telemetry_settings")

local ENABLED = TelemetrySettings.enabled
local ENDPOINT = TelemetrySettings.endpoint
local POST_INTERVAL = TelemetrySettings.batch.post_interval
local FULL_POST_INTERVAL = TelemetrySettings.batch.full_post_interval
local MAX_BATCH_SIZE = TelemetrySettings.batch.max_size
local BATCH_SIZE = TelemetrySettings.batch.size

local function dprintf(...)
	if Development.parameter("debug_telemetry") then
		printf(...)
	end
end

TelemetryManager = class(TelemetryManager)
TelemetryManager.NAME = "TelemetryManager"

function TelemetryManager.create()
	if IS_WINDOWS and rawget(_G, "lcurl") == nil then
		print("[TelemetryManager] No lcurl interface found! Fallback to dummy...")
		return TelemetryManagerDummy:new()
	elseif not IS_WINDOWS and rawget(_G, "REST") == nil then
		print("[TelemetryManager] No REST interface found! Fallback to dummy...")
		return TelemetryManagerDummy:new()
	elseif rawget(_G, "cjson") == nil then
		print("[TelemetryManager] No cjson interface found! Fallback to dummy...")
		return TelemetryManagerDummy:new()
	elseif DEDICATED_SERVER then
		print("[TelemetryManager] No telemetry on the dedicated server! Fallback to dummy...")
		return TelemetryManagerDummy:new()
	elseif TelemetrySettings.enabled == false then
		print("[TelemetryManager] Disabled! Fallback to dummy...")
		return TelemetryManagerDummy:new()
	else
		return TelemetryManager:new()
	end
end

function TelemetryManager:init()
	self._events = { }
	self._batch_post_time = 0
	self._t = 0

	self:reload_settings()
end

function TelemetryManager:reload_settings()
	dprintf("[TelemetryManager] Refreshing settings")
	self._blacklisted_events = table.set(TelemetrySettings.blacklist or { })
end

function TelemetryManager:update(dt, t)
	self._t = t

	if self:_ready_to_post_batch(t) then
		self:post_batch()
	end
end

function TelemetryManager:register_event(event)
	if not ENABLED then
		return
	end

	local raw_event = event:raw()

	if self._blacklisted_events [raw_event.type] then
		dprintf("[TelemetryManager] Skipping blacklisted event '%s'", raw_event.type)
		return
	end

	raw_event.time = self._t
	raw_event.data = self:_convert_userdata(raw_event.data)

	if #self._events < MAX_BATCH_SIZE then
		dprintf("[TelemetryManager] Registered event '%s'", event)
		table.insert(self._events, table.remove_empty_values(raw_event))
	else
		dprintf("[TelemetryManager] Discarding event '%s', buffer is full!", event)
	end
end

function TelemetryManager:_convert_userdata(data)
	local new_data = { }

	if type(data) == "table" then
		for key, value in pairs(data) do
			if Script.type_name(value) == "Vector3" then
				new_data [key] = { x = value.x, y = value.y, z = value.z }
			elseif type(value) == "function" then
				new_data [key] = nil
			elseif type(value) == "userdata" then
				new_data [key] = tostring(value)
			elseif type(value) == "table" then
				new_data [key] = self:_convert_userdata(value)
			else
				new_data [key] = value
			end
		end
	end

	return new_data
end

function TelemetryManager:_ready_to_post_batch(t)
	if self._batch_in_flight then
		return false
	end

	if POST_INTERVAL < t - self._batch_post_time then
		do return true end
	elseif FULL_POST_INTERVAL < t - self._batch_post_time and BATCH_SIZE <= #self._events then
		return true
	end
end

function TelemetryManager:post_batch()
	if not ENABLED or table.is_empty(self._events) then
		return
	end

	dprintf("[TelemetryManager] Posting batch of %d events", #self._events)

	self._batch_in_flight = true
	self._batch_post_time = math.floor(self._t)

	local payload = self:_encode(self._events)

	if IS_WINDOWS then
		local headers = { "Content-Type: application/json", string.format("x-reference-time: %s", self._t) }
		Managers.curl:post(ENDPOINT, payload, headers, callback(self, "cb_post_batch"))
	else
		local headers = { "Content-Type", "application/json", "x-reference-time", tostring(self._t) }
		Managers.rest_transport:post(ENDPOINT, payload, headers, callback(self, "cb_post_batch"))
	end
end


function TelemetryManager:_encode(events)
	local payload = table.map(events, cjson.encode)
	return "[" .. table.concat(payload, ",") .. "]"
end

function TelemetryManager:cb_post_batch(success, _, _, error)
	if success then
		dprintf("[TelemetryManager] Batch sent successfully")
		table.clear(self._events)
		self._batch_in_flight = nil
	else
		dprintf("[TelemetryManager] Error sending batch: %s", error)
		self._batch_in_flight = nil
	end
end

function TelemetryManager:destroy()
	self:post_batch()
end