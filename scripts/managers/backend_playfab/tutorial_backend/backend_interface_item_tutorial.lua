BackendInterfaceItemTutorial = class(BackendInterfaceItemTutorial)

local PlayFabClientApi = require("PlayFab.PlayFabClientApi")

function BackendInterfaceItemTutorial:init(backend_mirror)
	self._loadouts = { }
	self._items = { }
	self._backend_mirror = backend_mirror

	self._modified_templates = { }
	self:_refresh()
end

local loadout_slots = { "slot_ranged", "slot_melee", "slot_skin", "slot_hat", "slot_necklace", "slot_ring", "slot_trinket_1", "slot_frame" }










function BackendInterfaceItemTutorial:_refresh()
	self:_refresh_items()
	self:_refresh_loadouts()

	self._dirty = false

end

function BackendInterfaceItemTutorial:_refresh_items()
	self._items = { { key = "es_longbow_tutorial", rarity = "default", power_level = 10, backend_id = 1,


			data = ItemMasterList.es_longbow_tutorial },



		{ key = "es_2h_hammer_tutorial", rarity = "default", power_level = 10, backend_id = 2,


			data = ItemMasterList.es_2h_hammer_tutorial },



		{ key = "skin_es_knight", backend_id = 3, rarity = "default",


			data = ItemMasterList.skin_es_knight },


		{ key = "knight_hat_0000", backend_id = 4, rarity = "default",


			data = ItemMasterList.knight_hat_0000 },


		{ key = "dr_crossbow", rarity = "default", power_level = 10, backend_id = 5,


			data = ItemMasterList.dr_crossbow },



		{ key = "dr_1h_axe", rarity = "default", power_level = 10, backend_id = 6,


			data = ItemMasterList.dr_1h_axe },



		{ key = "skin_dr_ranger", backend_id = 7, rarity = "default",


			data = ItemMasterList.skin_dr_ranger },


		{ key = "ranger_hat_0000", backend_id = 8, rarity = "default",


			data = ItemMasterList.ranger_hat_0000 },


		{ key = "we_longbow", rarity = "default", power_level = 10, backend_id = 9,


			data = ItemMasterList.we_longbow },



		{ key = "we_dual_wield_daggers", rarity = "default", power_level = 10, backend_id = 10,


			data = ItemMasterList.we_dual_wield_daggers },



		{ key = "skin_ww_waywatcher", backend_id = 11, rarity = "default",


			data = ItemMasterList.skin_ww_waywatcher },


		{ key = "waywatcher_hat_0000", backend_id = 12, rarity = "default",


			data = ItemMasterList.waywatcher_hat_0000 },


		{ key = "bw_skullstaff_fireball", rarity = "default", power_level = 10, backend_id = 13,


			data = ItemMasterList.bw_skullstaff_fireball },



		{ key = "bw_1h_mace", rarity = "default", power_level = 10, backend_id = 14,


			data = ItemMasterList.bw_1h_mace },



		{ key = "skin_bw_adept", backend_id = 15, rarity = "default",


			data = ItemMasterList.skin_bw_adept },


		{ key = "adept_hat_0000", backend_id = 16, rarity = "default",


			data = ItemMasterList.adept_hat_0000 } }




end

function BackendInterfaceItemTutorial:_refresh_loadouts()
	self._loadouts = {
		empire_soldier_tutorial = { slot_skin = 3, slot_melee = 2, slot_hat = 4, slot_ranged = 1 },





		dr_ranger = { slot_skin = 7, slot_melee = 6, slot_hat = 8, slot_ranged = 5 },





		we_waywatcher = { slot_skin = 11, slot_melee = 10, slot_hat = 12, slot_ranged = 9 },





		bw_adept = { slot_skin = 15, slot_melee = 14, slot_hat = 16, slot_ranged = 13 } }






end

function BackendInterfaceItemTutorial:ready()
	if self._items then
		return true
	end

	return false
end

function BackendInterfaceItemTutorial:type()
	return "backend"
end

function BackendInterfaceItemTutorial:update()
	return end

function BackendInterfaceItemTutorial:refresh_entities()
	return end

function BackendInterfaceItemTutorial:check_for_errors()
	return end

function BackendInterfaceItemTutorial:num_current_item_server_requests()
	return 0
end

function BackendInterfaceItemTutorial:set_properties_serialized(backend_id, properties)
	return end

function BackendInterfaceItemTutorial:get_properties(backend_id)
	local item = self:get_item_from_id(backend_id)

	if item then
		local properties = item.properties

		return properties
	end

	return nil
end

function BackendInterfaceItemTutorial:get_traits(backend_id)
	local item = self:get_item_from_id(backend_id)

	if item then
		local traits = item.traits

		return traits
	end

	return nil
end

function BackendInterfaceItemTutorial:set_runes(backend_id, runes)
	return end

function BackendInterfaceItemTutorial:get_runes(backend_id)
	return end

function BackendInterfaceItemTutorial:socket_rune(backend_id, rune_to_insert, rune_index)
	return end

function BackendInterfaceItemTutorial:get_skin()
	return nil
end

function BackendInterfaceItemTutorial:get_item_masterlist_data(backend_id)
	local item = self:get_item_from_id(backend_id)

	if item then
		return item.data
	end
end

function BackendInterfaceItemTutorial:get_item_amount(backend_id)
	local item = self:get_item_from_id(backend_id)

	return item.RemainingUses or 1
end

function BackendInterfaceItemTutorial:get_item_power_level(backend_id)
	local item = self:get_item_from_id(backend_id)
	local power_level = item.power_level

	return power_level
end

function BackendInterfaceItemTutorial:get_item_rarity(backend_id)
	local item = self:get_item_from_id(backend_id)
	local rarity = item.rarity

	return rarity
end

function BackendInterfaceItemTutorial:get_key(backend_id)
	local item = self:get_item_from_id(backend_id)

	return item.key
end

function BackendInterfaceItemTutorial:get_item_from_id(backend_id)
	local items = self:get_all_backend_items()
	local item = items [backend_id]

	return item
end

function BackendInterfaceItemTutorial:get_item_from_key(item_key)
	local items = self:get_all_backend_items()
	for _, item in pairs(items) do
		if item.key == item_key then
			return item
		end
	end
end

function BackendInterfaceItemTutorial:get_all_backend_items()
	if self._dirty then
		self:_refresh()
	end

	return self._items
end

function BackendInterfaceItemTutorial:get_loadout()
	if self._dirty then
		self:_refresh()
	end

	return self._loadouts
end

function BackendInterfaceItemTutorial:get_loadout_item_id(career_name, slot_name)
	local loadouts = self:get_loadout()

	return loadouts [career_name] [slot_name]
end

local empty_params = { }



function BackendInterfaceItemTutorial:get_filtered_items(filter, params)
	local all_items = self:get_all_backend_items()
	local backend_common = Managers.backend:get_interface("common")
	local items = backend_common:filter_items(all_items, filter, params or empty_params)

	return items
end

function BackendInterfaceItemTutorial:set_loadout_item(item_id, career_name, slot_name)
	local all_items = self:get_all_backend_items()

	if item_id then
		fassert(all_items [item_id], "Trying to equip item that doesn't exist %d", item_id or "nil")
	end

	self._backend_mirror:set_character_data(career_name, slot_name, item_id)

	self._dirty = true
end

function BackendInterfaceItemTutorial:remove_item(backend_id, ignore_equipped)
	return end

function BackendInterfaceItemTutorial:award_item(item_key)
	return end

function BackendInterfaceItemTutorial:data_server_script(script_name, ...)
	return end

function BackendInterfaceItemTutorial:upgrades_failed_game(level_start, level_end)
	return end

function BackendInterfaceItemTutorial:poll_upgrades_failed_game()
	return end

function BackendInterfaceItemTutorial:generate_item_server_loot(dice, difficulty, start_level, end_level, hero_name, dlc_name)
	return end

function BackendInterfaceItemTutorial:check_for_loot()
	return end


function BackendInterfaceItemTutorial:equipped_by(backend_id)
	local loadouts = self._loadouts
	local equipped_careers = { }

	for career_name, items_by_slot in pairs(loadouts) do
		for slot_name, item_id in pairs(items_by_slot) do
			if backend_id == item_id then
				table.insert(equipped_careers, career_name)
			end
		end
	end

	return equipped_careers
end

function BackendInterfaceItemTutorial:is_equipped(backend_id, profile_name)
	return end

function BackendInterfaceItemTutorial:set_data_server_queue(queue)
	return end

function BackendInterfaceItemTutorial:make_dirty()
	self._dirty = true
end

function BackendInterfaceItemTutorial:has_item(item_key)
	local items = self:get_all_backend_items()

	for backend_id, item in pairs(items) do
		if item_key == item.key then
			return true
		end
	end

	return false
end

function BackendInterfaceItemTutorial:get_item_template(item_data, backend_id)
	local template_name = item_data.temporary_template or item_data.template
	local item_template = Weapons [template_name]
	local modified_item_templates = self._modified_templates
	local modified_item_template = nil

	if item_template then
		if backend_id then
			if not modified_item_templates [backend_id] then
				modified_item_template = GearUtils.apply_properties_to_item_template(item_template, backend_id)

				self._modified_templates [backend_id] = modified_item_template
			else
				return modified_item_templates [backend_id]
			end
		end

		return modified_item_template or item_template
	end

	item_template = Attachments [template_name]

	if item_template then
		return item_template
	end

	item_template = Cosmetics [template_name]

	if item_template then
		return item_template
	end

	fassert(false, "no item_template for item: " .. item_data.key .. ", template name = " .. template_name)
end

function BackendInterfaceItemTutorial:sum_best_power_levels()
	return 10
end

function BackendInterfaceItemTutorial:configure_game_mode_specific_items(game_mode, items)

	return end

function BackendInterfaceItemTutorial:set_game_mode_specific_items(game_mode)

	return end