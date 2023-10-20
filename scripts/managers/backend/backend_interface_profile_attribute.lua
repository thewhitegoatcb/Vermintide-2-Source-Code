BackendInterfaceProfileAttribute = class(BackendInterfaceProfileAttribute)

function BackendInterfaceProfileAttribute:init()

	return end

function BackendInterfaceProfileAttribute:set(name, value)
	Backend.write_profile_attribute_as_number(name, value)
end

function BackendInterfaceProfileAttribute:get(name)
	return Backend.read_profile_attribute_as_number(name)
end

function BackendInterfaceProfileAttribute:set_string(name, value)
	Backend.write_profile_attribute_as_string(name, value)
end

function BackendInterfaceProfileAttribute:get_string(name)
	return Backend.read_profile_attribute_as_string(name)
end