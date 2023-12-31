LevelHelper = LevelHelper or { }

LevelHelper.INGAME_WORLD_NAME = "level_world"

function LevelHelper:current_level_settings()
	local level_key = Managers.state.game_mode:level_key()
	return LevelSettings [level_key]
end

function LevelHelper:current_level(world)
	local level_settings = self:current_level_settings()
	local level = ScriptWorld.level(world, level_settings.level_name)

	return level
end

function LevelHelper:get_environment_variation_id(level_key)
	local backend_manager = Managers.backend
	local environment_variations = backend_manager:get_title_data("environment_variations")
	if not environment_variations then
		return self:get_random_variation_id(level_key)
	end

	environment_variations = cjson.decode(environment_variations)
	local level_environment_variations = environment_variations [level_key]
	if not level_environment_variations then
		return 0
	end

	local type = level_environment_variations.type
	if type == "random" then
		return self:get_random_variation_id(level_key)

	elseif type == "specific" then
		local level_settings = LevelSettings [level_key]
		local existing_variations = level_settings and level_settings.environment_variations
		if not existing_variations or #existing_variations < 1 then

			return 0
		end

		local variations = level_environment_variations.variations


		local selected_variation_string, i, id = nil



		while #variations > 0 do
			i = math.random(1, #variations)
			selected_variation_string = variations [i]
			if selected_variation_string == "default" then

				return 0
			end

			id = table.find(existing_variations, selected_variation_string)
			if id then
				do return id end
			else

				table.remove(variations, i)
			end
		end
	elseif type == "default" then
		return 0
	end






	return 0
end

function LevelHelper:get_random_variation_id(level_key)
	local settings = rawget(LevelSettings, level_key)
	local variations = settings and settings.environment_variations
	return variations and math.random(0, #variations) or 0
end

function LevelHelper:flow_event(world, event)
	local level_settings = self:current_level_settings()
	local level = ScriptWorld.level(world, level_settings.level_name)

	Level.trigger_event(level, event)
end

function LevelHelper:set_flow_parameter(world, name, value)
	local level_settings = self:current_level_settings()
	local level = ScriptWorld.level(world, level_settings.level_name)

	Level.set_flow_variable(level, name, value)
end

function LevelHelper:unit_index(world, unit)
	local level = self:current_level(world)
	return Level.unit_index(level, unit)
end

function LevelHelper:unit_by_index(world, index)
	local level = self:current_level(world)
	return Level.unit_by_index(level, index)
end

function LevelHelper:find_dialogue_unit(world, dialogue_profile)
	local level = LevelHelper:current_level(world)
	local units = Level.units(level)

	local intro_vo_unit = nil
	for _, unit in ipairs(units) do
		if Unit.has_data(unit, "dialogue_profile") then
			local found_dialogue_profile = Unit.get_data(unit, "dialogue_profile")
			if found_dialogue_profile == dialogue_profile then
				intro_vo_unit = unit
				break
			end
		end
	end

	return intro_vo_unit
end

function LevelHelper:get_base_level(level_key)
	local level_settings = LevelSettings [level_key]
	return level_settings and level_settings.base_level_name or level_key
end

function LevelHelper:get_small_level_image(level_key)
	local level_settings = LevelSettings [level_key]
	local level_image = level_settings.small_level_image or level_key .. "_small_image"
	if not UIAtlasHelper.has_texture_by_name(level_image) then

		level_image = "any_small_image"
	end
	return level_image
end