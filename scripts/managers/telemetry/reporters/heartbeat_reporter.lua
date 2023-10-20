HeartbeatReporter = class(HeartbeatReporter)
HeartbeatReporter.NAME = "HeartbeatReporter"

local SAMPLE_INTERVAL = 300

function HeartbeatReporter:init()
	self._last_sample_time = 0
	Managers.telemetry_events:heartbeat()
end

function HeartbeatReporter:destroy()
	return end

function HeartbeatReporter:update(dt, t)
	if SAMPLE_INTERVAL < t - self._last_sample_time then
		Managers.telemetry_events:heartbeat()
		self._last_sample_time = math.floor(t)
	end
end

function HeartbeatReporter:report()
	return end