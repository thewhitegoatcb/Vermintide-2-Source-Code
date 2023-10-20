BackendInterfaceTitleProperties = class(BackendInterfaceTitleProperties)

function BackendInterfaceTitleProperties:init()
	return end

function BackendInterfaceTitleProperties:_refresh_if_needed()
	if not self._properties then
		local data = Backend.get_title_properties()
		local properties = { }
		for key, value in pairs(data) do
			properties [key] = cjson.decode(value)
		end
		self._properties = properties
	end
end

function BackendInterfaceTitleProperties:get()
	self:_refresh_if_needed()
	return self._properties
end

function BackendInterfaceTitleProperties:get_value(key)
	self:_refresh_if_needed()
	local value = self._properties [key]
	fassert(value ~= nil, "No such key '%s'", key)
	local decoded = cjson.decode(value)
	return decoded
end