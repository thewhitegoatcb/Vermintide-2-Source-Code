ImguiUmbraDebug = class(ImguiUmbraDebug)

local SHOULD_RELOAD = true

function ImguiUmbraDebug:init()
	self.enable_debug = false

	self.debug_options = { { mask = 16, name = "Draw Viewcell", enabled = false, query = 0 },
		{ mask = 32, name = "Draw Portals", enabled = false, query = 0 },
		{ mask = 64, name = "Draw Visibility Lines", enabled = false, query = 0 },
		{ mask = 128, name = "Draw Object bounds", enabled = false, query = 0 },
		{ mask = 256, name = "Draw Visible Volume", enabled = false, query = 0 },
		{ mask = 512, name = "Draw View Frustum", enabled = false, query = 0 },
		{ mask = 32, name = "Draw Shadow Projection", enabled = false, query = 1 },
		{ mask = 1024, name = "Show Statistics", enabled = false, query = 0 },
		{ mask = 1, name = "Single Threaded Query", enabled = false, query = 2 },
		{ mask = 2, name = "Show Occlusion Buffer", enabled = false, query = 2 },
		{ mask = 4, name = "Show Shadow Mask Buffer", enabled = false, query = 2 },
		{ mask = 8, name = "Draw Visible Objects", enabled = false, query = 2 },
		{ mask = 16, name = "Draw Culled Shadow Casters", enabled = false, query = 2 },
		{ mask = 32, name = "Draw Visible Shadow Casters", enabled = false, query = 2 } }


	self.debug_config = {
		portal_query_distance = { speed = 1, idx = 0, min = 0, max = 100 },
		portal_query_accurate_occlusion_threshold = { speed = 1, idx = 1, min = 0, max = 255 },
		portal_query_contribution_threshold_distance = { speed = 1, idx = 2, min = 0, max = 255 },
		portal_query_contribution_threshold = { speed = 1, idx = 3, min = 0, max = 1 } }

	self.sub_windows = { {
			option = self.debug_options [10], draw = World.imgui_draw_umbra_debug_occlusion_buffer }, {
			option = self.debug_options [11], draw = World.imgui_draw_umbra_debug_shadowmask_buffer }, {
			option = self.debug_options [8], draw = World.imgui_draw_umbra_debug_statistics } }

end

function ImguiUmbraDebug:update()
	if SHOULD_RELOAD then
		ImguiUmbraDebug:init()
		SHOULD_RELOAD = false
	end
end

function ImguiUmbraDebug:is_persistent()
	return self:_has_floater()
end

function ImguiUmbraDebug:_has_floater()
	local subwindow_count = 0
	if self.enable_debug == false then
		return false
	end
	for i, v in ipairs(self.sub_windows) do
		subwindow_count = subwindow_count + (v.option.enabled == true and 1 or 0)
	end
	return subwindow_count > 0
end

function ImguiUmbraDebug:draw(is_open)
	if not Managers.world:has_world("level_world") then
		return
	end
	local world = Managers.world:world("level_world")

	local do_close = false
	if is_open then
		do_close = Imgui.begin_window("Umbra Debug")
		self.enable_debug = Imgui.checkbox("Enable Debug", self.enable_debug)
		if self.enable_debug then
			if Imgui.tree_node("Debug render options", true) then
				for i, v in ipairs(self.debug_options) do
					v.enabled = Imgui.checkbox(v.name, v.enabled)
				end
				Imgui.tree_pop()
			end
			if Imgui.tree_node("Config parameters") then
				for k, v in pairs(self.debug_config) do
					local val = World.get_umbra_debug_config_value(world, v.idx)
					local new_val = Imgui.slider_float(k, val, v.min, v.max, v.speed)
					if val ~= new_val then
						World.set_umbra_debug_config_value(world, v.idx, new_val)
					end
				end
				Imgui.tree_pop()
			end
		end
		Imgui.end_window("Umbra Debug")
	end


	World.set_umbra_debug_enable(world, self.enable_debug)
	if self.enable_debug then
		for k, v in pairs(self.debug_options) do
			World.set_umbra_debug_flag(world, v.query, v.mask, v.enabled)
		end
	end

	if self:_has_floater() then
		self:_update_floater(world)
	end

	return do_close
end

function ImguiUmbraDebug:_update_floater(world)
	Imgui.begin_window("Umbra Floater")
	for i, v in ipairs(self.sub_windows) do
		if v.option.enabled then
			v.draw(world)
		end
	end
	Imgui.end_window()
end