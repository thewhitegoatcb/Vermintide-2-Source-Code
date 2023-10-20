




local HeroWindowCosmeticsInventoryTestify = { }



function HeroWindowCosmeticsInventoryTestify.get_hero_window_cosmetics_inventory_item_grid(hero_window_cosmetics_inventory)
	return hero_window_cosmetics_inventory._item_grid
end





function HeroWindowCosmeticsInventoryTestify.set_slot_hotspot_on_right_click(hero_window_cosmetics_inventory, params)
	hero_window_cosmetics_inventory._item_grid._widget.content [

	params.hotspot_name].on_right_click =
	params.value
end



function HeroWindowCosmeticsInventoryTestify.wait_for_cosmetics_inventory_window()
	return end


return HeroWindowCosmeticsInventoryTestify