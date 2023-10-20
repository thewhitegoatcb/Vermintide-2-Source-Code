TelemetryEvent = class(TelemetryEvent)
TelemetryEvent.NAME = "TelemetryEvent"

local type_name = Script.type_name

function TelemetryEvent:init(source, subject, type, session)
	fassert(type_name(source) == "table", "'source' needs to be table")
	fassert(type_name(subject) == "table" or subject == nil, "'subject' needs to be a table or nil")
	fassert(type_name(type) == "string", "'type' needs to be a string")
	fassert(type_name(session) == "table" or session == nil, "'session' needs to be a table or nil")

	self._event = { specversion = "1.2",

		source = source,
		subject = subject,
		type = type,
		session = session }

end

function TelemetryEvent:set_revision(revision)
	fassert(type_name(revision) == "number" or revision == nil, "'revision' needs to be a number or nil")
	self._event.revision = revision
end

function TelemetryEvent:set_data(data)
	assert(type_name(data) == "table" or data == nil, "'data' needs to be a table or nil")
	self._event.data = data
end

function TelemetryEvent:raw()
	return self._event
end

function TelemetryEvent:__tostring()
	return table.tostring(self._event, math.huge)
end