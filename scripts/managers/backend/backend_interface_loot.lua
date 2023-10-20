require("scripts/managers/backend/data_server_queue")

local function dprint(...)

	print("[BackendInterfaceLoot]", ...)

end

BackendInterfaceLoot = class(BackendInterfaceLoot)














local DB_ENTITY_TYPE = "item"

function BackendInterfaceLoot:init()
	return end

function BackendInterfaceLoot:setup(data_server_queue)
	self:_register_executors(data_server_queue)
	self._queue = data_server_queue
	self.dirty = false
	self._attributes = { }
end

function BackendInterfaceLoot:_register_executors(queue)
	queue:register_executor("loot_chest_generated", callback(self, "_command_loot_chest_generated"))
	queue:register_executor("loot_chest_consumed", callback(self, "_command_loot_chest_consumed"))
	queue:register_executor("weapon_with_properties_generated", callback(self, "_command_weapon_with_properties_generated"))
end













function BackendInterfaceLoot:_command_loot_chest_generated(entity_id)
	dprint("_command_loot_chest_generated ")

	self.dirty = false
	local backend_item = Managers.backend:get_interface("items")
	self.last_generated_loot_chest = backend_item:get_item_from_id(entity_id).key
	Backend.load_entities()
	self:_refresh_attributes()
end

function BackendInterfaceLoot:_command_loot_chest_consumed(status_code)
	dprint("_command_loot_chest_consumed " .. status_code)
	self.dirty = false
	Backend.load_entities()
end

function BackendInterfaceLoot:_command_weapon_with_properties_generated(status_code)
	dprint("_command_weapon_with_properties_generated " .. status_code)
	self.dirty = false
	Backend.load_entities()
	self:_refresh_attributes()

end












function BackendInterfaceLoot:generate_loot_chest(hero_name, difficulty, num_tomes, num_grimoires, num_loot_dice, level_key)

	self._queue:add_item("generate_loot_chest_1", "hero_name", cjson.encode(hero_name), "difficulty", cjson.encode(difficulty), "tomes", cjson.encode(num_tomes), "grimoires", cjson.encode(num_grimoires), "loot_dice", cjson.encode(num_loot_dice), "level", cjson.encode(level_key))
	self.dirty = true
end

function BackendInterfaceLoot:consume_loot_chest(backend_id, picked_item_key, properties)

	local serialized = ""

	fassert(picked_item_key, "Got nil item key to reward player")
	fassert(properties, "No properties found for item %s", picked_item_key)

	for _, property in pairs(properties) do
		serialized = serialized .. property.rune_slot .. ":" .. property.property_key .. ",empty,"
	end

	self._queue:add_item("consume_loot_chest_1", "entity_id", cjson.encode(backend_id), "item_key", cjson.encode(picked_item_key), "properties", cjson.encode(serialized))
	self.dirty = true
end

function BackendInterfaceLoot:generate_weapon_with_properties(item_key, properties)
	self._queue:add_item("generate_property_weapon", "item_key", cjson.encode(item_key), "properties", cjson.encode(properties))
	self.dirty = true
end

function BackendInterfaceLoot:_refresh_attributes()


	local entities = Backend.get_entities_with_attributes(DB_ENTITY_TYPE)
	local attributes_by_entity_id = { }

	for entity_id, entity in pairs(entities) do
		local attributes = entity.attributes
		if attributes then
			attributes_by_entity_id [entity_id] = attributes
		end
	end

	self._attributes = attributes_by_entity_id


end

function BackendInterfaceLoot:on_authenticated()
	self:_refresh_attributes()
end

function BackendInterfaceLoot:get_loot(backend_id)
	self:_refresh_attributes()

	local attributes = self._attributes [backend_id]

	fassert(attributes, "[BackendInterfaceLoot:get_loot] Tried to get attributes from an item with no attributes", "error")

	local loot = { }

	for _, attr in pairs(attributes) do
		local loot_data = { }
		local properties = { }

		for item_key, loot_type in string.gmatch(attr, "([%w_]+),*([%w_]*);") do
			loot_data.item_key = item_key
			loot_data.loot_type = loot_type
		end

		for rune_slot, property in string.gmatch(attr, "([%w_]+):([%w_]+)") do
			properties [#properties + 1] = { rune_value = "empty", rune_slot = rune_slot, property_key = property }
		end

		loot_data.properties = properties

		loot [#loot + 1] = loot_data
	end

	return loot
end

function BackendInterfaceLoot:is_dirty()
	return self.dirty
end

function BackendInterfaceLoot:get_last_generated_loot_chest()
	return self.last_generated_loot_chest
end