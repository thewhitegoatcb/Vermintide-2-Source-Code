InputUtils = InputUtils or { }

function InputUtils.keymaps_key_approved(platform_key)
	local platform = PLATFORM
	if IS_WINDOWS then
		do return ( platform_key == platform or platform_key == "xb1" ) and true or nil end
	elseif IS_XB1 then
		do return ( platform_key == platform or platform_key == "win32" ) and true or nil end
	else
		return platform_key == platform and true or nil
	end
end

function InputUtils.get_platform_keymaps(keymappings, optional_platform_key)
	local platform = optional_platform_key or PLATFORM
	return keymappings [platform]
end

function InputUtils.get_platform_filters(filters, optional_platform_key)
	local platform = optional_platform_key or PLATFORM
	return filters [platform]
end