require("scripts/managers/telemetry/reporters/heartbeat_reporter")

TelemetryReporters = class(TelemetryReporters)
TelemetryReporters.NAME = "TelemetryReporters"

local REPORTER_CLASS_MAP = {
	heartbeat = HeartbeatReporter }


function TelemetryReporters:init()
	self._reporters = { }
	self:start_reporter("heartbeat")
end

function TelemetryReporters:start_reporter(name, params)
	local reporter_class = REPORTER_CLASS_MAP [name]
	self._reporters [name] = reporter_class:new(params)
end

function TelemetryReporters:stop_reporter(name)
	self._reporters [name]:report()
	self._reporters [name]:destroy()
	self._reporters [name] = nil
end

function TelemetryReporters:reporter(name)
	return self._reporters [name]
end

function TelemetryReporters:update(dt, t)
	for _, reporter in pairs(self._reporters) do
		reporter:update(dt, t)
	end
end

function TelemetryReporters:destroy()
	for _, reporter in pairs(self._reporters) do
		reporter:destroy()
	end
end

return TelemetryReporters