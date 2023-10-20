



local Gui = Gui
local math_floor = math.floor local math_min = math.min local math_max = math.max






Fonts = {
	arial = { "materials/fonts/arial", 14, "arial" },
	arial_masked = { "materials/fonts/arial", 14, "arial", Gui.Masked },
	arial_write_mask = { "materials/fonts/arial", 14, "arial", Gui.WriteMask },

	hell_shark_arial = { "materials/fonts/arial", 14, "arial" },
	hell_shark_arial_masked = { "materials/fonts/arial", 14, "arial", Gui.Masked },
	hell_shark_arial_write_mask = { "materials/fonts/arial", 14, "arial", Gui.WriteMask },

	hell_shark = { "materials/fonts/gw_body", 20, "gw_body" },
	hell_shark_masked = { "materials/fonts/gw_body", 20, "gw_body", Gui.Masked },
	hell_shark_write_mask = { "materials/fonts/gw_body", 20, "gw_body", Gui.WriteMask },

	hell_shark_header = { "materials/fonts/gw_head", 20, "gw_head" },
	hell_shark_header_masked = { "materials/fonts/gw_head", 20, "gw_head", Gui.Masked },
	hell_shark_header_write_mask = { "materials/fonts/gw_head", 20, "gw_head", Gui.WriteMask },

	chat_output_font = { "materials/fonts/arial", 14, "arial", Gui.MultiColor + Gui.ForceSuperSampling + Gui.FormatDirectives },
	chat_output_font_masked = { "materials/fonts/arial", 14, "arial", Gui.MultiColor + Gui.ForceSuperSampling + Gui.FormatDirectives + Gui.Masked } }








function UIFontByResolution(font_style, optional_scale)
	local font_type = font_style.font_type
	local font_size = font_style.font_size


	local scale = RESOLUTION_LOOKUP.scale
	if optional_scale then
		scale = scale * optional_scale
	end
	font_size = font_size * scale


	if not font_style.allow_fractions then
		font_size = math_floor(font_size)
	end


	return Fonts [font_type], math_max(font_size, 1)
end


FontHeights = FontHeights or { }



function UISetupFontHeights(gui)
	local FontHeights = FontHeights
	for font_name, font_data in pairs(Fonts) do
		if FontHeights [font_name] == nil then


			UIGetFontHeight(gui, font_name, font_data [2])
		end
	end
end






function UIGetFontHeight(gui, font_name, font_size)
	 --[[ Decompilation error in this vicinity: --]]  --[[ BLOCK #0 1-4, warpins: 1 --]] local FontHeights = FontHeights
	if not FontHeights [font_name] then  --[[ Decompilation error in this vicinity: --]]  --[[ BLOCK #1 5-5, warpins: 1 --]] slot4 = { } --[[ END OF BLOCK #1 --]] end --[[ END OF BLOCK #0 --]] --[[ FLOW --]] --[[ TARGET BLOCK #2; --]]  --[[ Decompilation error in this vicinity: --]]  --[[ BLOCK #1 5-5, warpins: 1 --]] slot4 = --[[ END OF BLOCK #1 --]]  --[[ Decompilation error in this vicinity: --]]  --[[ BLOCK #2 6-8, warpins: 2 --]] FontHeights [font_name] = slot4


	local height_data = FontHeights [font_name] [font_size] --[[ END OF BLOCK #2 --]] --[[ FLOW --]] --[[ TARGET BLOCK #3; --]]  --[[ Decompilation error in this vicinity: --]] 

	--[[ BLOCK #3 9-10, warpins: 2 --]] if height_data then


		 --[[ Decompilation error in this vicinity: --]]  --[[ BLOCK #4 11-27, warpins: 1 --]] local scale = RESOLUTION_LOOKUP.scale
		local extra_base = scale * math_min(font_size * 0.05, 1)
		local extra_max = 5 * extra_base
		local extra_min = 4 * extra_base
		return height_data [1] + extra_min + extra_max, height_data [2] - extra_min, height_data [3] + extra_max --[[ END OF BLOCK #4 --]] end --[[ END OF BLOCK #3 --]] --[[ FLOW --]] --[[ TARGET BLOCK #5; --]]  --[[ Decompilation error in this vicinity: --]]  --[[ BLOCK #4 11-27, warpins: 1 --]] local scale = RESOLUTION_LOOKUP.scale local extra_base = scale * math_min(font_size * 0.05, 1) local extra_max = 5 * extra_base local extra_min = 4 * extra_base return height_data [1] + extra_min + extra_max, height_data [2] - extra_min, height_data [3] + extra_max --[[ END OF BLOCK #4 --]]  --[[ Decompilation error in this vicinity: --]] 



	--[[ BLOCK #5 28-58, warpins: 2 --]] local material = Fonts [font_name] [1]


	local min, max = Gui.text_extents(gui, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890", material, font_size)
	local base_min, base_max = Gui.text_extents(gui, "A", material, font_size)


	height_data = {
		base_max [2] - base_min [2],
		min [2],
		max [2] }

	FontHeights [font_name] [font_size] = height_data if true then  --[[ Decompilation error in this vicinity: --]]  --[[ BLOCK #6 59-59, warpins: 1 --]] --[[ END OF BLOCK #6 --]] end --[[ END OF BLOCK #5 --]] --[[ FLOW --]] --[[ TARGET BLOCK #6; --]]  --[[ Decompilation error in this vicinity: --]]  --[[ BLOCK #6 59-59, warpins: 1 --]] --[[ END OF BLOCK #6 --]]  --[[ Decompilation error in this vicinity: --]] 


	--[[ BLOCK #6 59-59, warpins: 2 --]] --[[ END OF BLOCK #6 --]] --[[ FLOW --]] --[[ TARGET BLOCK #7; --]]  --[[ Decompilation error in this vicinity: --]]  --[[ BLOCK #7 60-60, warpins: 1 --]] --[[ END OF BLOCK #7 --]] --[[ UNCONDITIONAL JUMP --]] --[[ TARGET BLOCK #3; --]]  --[[ Decompilation error in this vicinity: --]] 

	--[[ BLOCK #8 61-61, warpins: 0 --]] return --[[ END OF BLOCK #8 --]] end