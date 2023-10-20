BackendInterfaceHeroAttributesTutorial = class(BackendInterfaceHeroAttributesTutorial)

local DEFAULT_ATTRIBUTES = { dwarf_ranger_career = 1, empire_soldier_tutorial_career = 1, wood_elf_experience = 0, dwarf_ranger_experience = 0, bright_wizard_prestige = 0, dwarf_ranger_prestige = 0, empire_soldier_prestige = 0, bright_wizard_experience = 0, witch_hunter_prestige = 0, empire_soldier_tutorial_prestige = 0, wood_elf_career = 1, empire_soldier_career = 1, wood_elf_prestige = 0, witch_hunter_career = 1, bright_wizard_career = 1, witch_hunter_experience = 0, empire_soldier_experience = 0, empire_soldier_tutorial_experience = 0 }

























function BackendInterfaceHeroAttributesTutorial:init(backend_mirror)
	self._attributes = table.clone(DEFAULT_ATTRIBUTES)
	self._initialized = true
end

function BackendInterfaceHeroAttributesTutorial:ready()
	return self._initialized
end

function BackendInterfaceHeroAttributesTutorial:update(dt)
	return end

function BackendInterfaceHeroAttributesTutorial:get(hero, attribute)
	local key = hero .. "_" .. attribute

	return self._attributes [key] or DEFAULT_ATTRIBUTES [key]
end


function BackendInterfaceHeroAttributesTutorial:set(hero, attribute, value)
	return end

function BackendInterfaceHeroAttributesTutorial:prestige(hero_name, callback_function)
	return end

function BackendInterfaceHeroAttributesTutorial:prestige_request_cb(hero_name, callback_function, result)
	return end

function BackendInterfaceHeroAttributesTutorial:save(save_hero_attributes_cb)
	return false
end