









































local function localize_err_string(text_id)
	return "<" .. tostring(text_id) .. ">"
end

LocalizationManager = class(LocalizationManager)

function LocalizationManager:init(language_id)
	self:_setup_localizers()
	self._macros = { }
	self._find_macro_callback_to_self = callback(self._find_macro, self)

	local has_steam = rawget(_G, "Steam")
	self._language_id = language_id or Application.user_setting("language_id") or has_steam and Steam.language() or "en"
	self._backend_localizations = { }


	rawset(_G, "Localize", function (text_id)
		return self:lookup(text_id)
	end)
end

function LocalizationManager:destroy()
	rawset(_G, "Localize", nil)
end

function LocalizationManager:_setup_localizers()
	fassert(not self._localizers, "LocalizationManager already initialized")

	self._localizers = { Localizer("localization/game") }
	for dlc, settings in pairs(DLCSettings) do
		local localization = settings.localization
		if localization and Application.can_get("strings", localization) then
			self._localizers [#self._localizers + 1] = Localizer(localization)
		end
	end
end

function LocalizationManager:_base_lookup(text_id)

	local text = self._backend_localizations [text_id]
	if text then
		return text
	end


	local lookup = Localizer.lookup
	local localizer_list = self._localizers
	for i = 1, #localizer_list do
		text = lookup(localizer_list [i], text_id)
		if text then
			return text
		end
	end

	return nil
end

function LocalizationManager:append_backend_localizations(localizations)
	local backend_localizations = self._backend_localizations
	for string_id, text in pairs(localizations) do
		backend_localizations [string_id] = text
	end
end

function LocalizationManager:add_macro(macro, callback_function)
	self._macros [macro] = callback_function
end

function LocalizationManager:language_id()
	return self._language_id
end

function LocalizationManager:text_to_upper(text)
	return Utf8.upper(text)
end

function LocalizationManager:lookup(text_id)









	fassert(self._localizers, "LocalizationManager not initialized")
	local str = self:_base_lookup(text_id) or localize_err_string(text_id)
	return self:apply_macro(str)

end

function LocalizationManager:apply_macro(str)
	return string.gsub(str, "%b$;[%a%d_]*:", self._find_macro_callback_to_self)
end

function LocalizationManager:simple_lookup(text_id)
	fassert(self._localizers, "LocalizationManager not initialized")

	return self:_base_lookup(text_id) or localize_err_string(text_id)
end

function LocalizationManager:_find_macro(macro_string)
	local arg_start = string.find(macro_string, ";")
	return self._macros [string.sub(macro_string, 2, arg_start - 1)](string.sub(macro_string, arg_start + 1, -2))
end

function LocalizationManager:exists(text_id)
	fassert(self._localizers, "LocalizationManager not initialized")
	return self:_base_lookup(text_id) ~= nil
end



function LocalizationManager:plural_form(n)
	local loc = self._language_id
	if loc == "en" or loc == "es" or loc == "it" or loc == "br-pt" then
		do return n ~= 1 and 1 or 0 end
	elseif loc == "fr" then
		do return n > 1 and 1 or 0 end
	elseif loc == "zh" then
		do return 0 end
	elseif loc == "ru" then
		if n % 10 == 1 and n % 100 ~= 11 then
			do return 0 end
		elseif n % 10 >= 2 and n % 10 <= 4 and (n % 100 < 10 or n % 100 >= 20) then
			do return 1 end
		else
			do return 2 end
		end
	elseif loc == "pl" then
		if n == 1 then
			do return 0 end
		elseif n % 10 >= 2 and n % 10 <= 4 and (n % 100 < 10 or n % 100 >= 20) then
			do return 1 end
		else
			return 2
		end
	end

	return 0
end

function LocalizeArray(text_ids, result)
	result = result or { }
	local num_ids = #text_ids
	for i = 1, num_ids do
		local text_id = text_ids [i]
		result [i] = Localize(text_id)
	end
	return result
end

function TextToUpper(text)
	return Managers.localizer:text_to_upper(text)
end

local INPUT_ACTIONS = { }
local INPUT_SERVICE_NAMES = { }
function LocalizationManager:get_input_action(text_id)
	local str = self:_base_lookup(text_id) or localize_err_string(text_id)
	local macro = string.match(str, "%b$;[%a%d_]*:")
	local input_service_name = nil
	table.clear(INPUT_ACTIONS)
	table.clear(INPUT_SERVICE_NAMES)
	while macro do
		local start_index, end_index = string.find(str, macro)
		str = string.sub(str, end_index + 2)
		local arg_start = string.find(macro, ";")
		local input_service_and_action = string.sub(macro, arg_start + 1, -2)

		local split_start, split_end = string.find(input_service_and_action, "__")
		INPUT_SERVICE_NAMES [#INPUT_SERVICE_NAMES + 1] = string.sub(input_service_and_action, 1, split_start - 1)
		INPUT_ACTIONS [#INPUT_ACTIONS + 1] = string.sub(input_service_and_action, split_end + 1)

		macro = string.match(str, "%b$;[%a%d_]*:")
	end

	return INPUT_ACTIONS [1], INPUT_ACTIONS, INPUT_SERVICE_NAMES [1], INPUT_SERVICE_NAMES
end

function LocalizationManager:replace_macro_in_string(text_id, replacement_str, skip_localization, number_of_replacements)
	local str = text_id
	if not skip_localization then
		str = self:_base_lookup(text_id) or localize_err_string(text_id)
	end

	local result, num_replacements = string.gsub(str, "%b$;[%a%d_]*:", replacement_str, number_of_replacements)
	return result, str, self:lookup(text_id), num_replacements
end




function LocalizationManager:_set_locale(locale, lightweight)
	print("[LocalizationManager] Setting locale to:", locale)
	DeadlockStack.pause()
	self._language_id = locale
	self:_reload_locale_packages(locale, lightweight)
	if not lightweight then
		Managers.backend:get_interface("cdn"):load_backend_localizations(
		locale, function (localizations)
			if localizations then
				self:append_backend_localizations(localizations)
			end
		end)
	end
	Managers.ui:reload_ingame_ui(true)
	collectgarbage()
	DeadlockStack.unpause()
end


function LocalizationManager:_reload_locale_packages(locale, dont_reload_fonts)
	printf("[LocalizationManager] reload_locale_packages(%q)", locale)
	Application.set_resource_property_preference_order(locale, "en")
	self:_reload_boot_package("resource_packages/strings")
	if not dont_reload_fonts then
		self:_reload_boot_package("resource_packages/fonts")
	end
end


function LocalizationManager:_reload_boot_package(package_name)
	DeadlockStack.pause()
	local packages = Boot.startup_package_handles
	local handle = packages [package_name]
	ResourcePackage.unload(handle)
	Application.release_resource_package(handle)
	handle = Application.resource_package(package_name)
	ResourcePackage.load(handle)
	ResourcePackage.flush(handle)
	packages [package_name] = handle
	DeadlockStack.unpause()
end


function LocalizationManager:set_locale_override_setting(locale)
	Application.set_user_setting("language_id", locale)
	Application.save_user_settings()
end