require("scripts/ui/views/menu_world_previewer")

local crafting_recipes, crafting_recipes_by_name, crafting_recipes_lookup = dofile("scripts/settings/crafting/crafting_recipes")
local definitions = local_require("scripts/ui/views/hero_view/craft_pages/definitions/craft_page_extract_skin_definitions")

local widget_definitions = definitions.widgets
local category_settings = definitions.category_settings
local scenegraph_definition = definitions.scenegraph_definition
local animation_definitions = definitions.animation_definitions

local DO_RELOAD = false
local NUM_CRAFT_SLOTS = 1

CraftPageExtractSkin = class(CraftPageExtractSkin)
CraftPageExtractSkin.NAME = "CraftPageExtractSkin"

function CraftPageExtractSkin:on_enter(params, settings)
	print("[HeroWindowCraft] Enter Substate CraftPageExtractSkin")

	self.parent = params.parent
	self.super_parent = self.parent.parent
	local ingame_ui_context = params.ingame_ui_context
	self.ingame_ui_context = ingame_ui_context
	self.ui_renderer = ingame_ui_context.ui_renderer
	self.ui_top_renderer = ingame_ui_context.ui_top_renderer
	self.input_manager = ingame_ui_context.input_manager
	self.statistics_db = ingame_ui_context.statistics_db
	self.render_settings = { snap_pixel_positions = true }
	self.crafting_manager = Managers.state.crafting

	local player_manager = Managers.player
	local local_player = player_manager:local_player()
	self._stats_id = local_player:stats_id()
	self.player_manager = player_manager
	self.peer_id = ingame_ui_context.peer_id

	self.hero_name = params.hero_name
	self.career_index = params.career_index
	self.profile_index = params.profile_index
	self.wwise_world = params.wwise_world

	self.settings = settings

	self._animations = { }
	self:create_ui_elements(params)

	self._craft_items = { }
	self._material_items = { }
	self._item_grid = ItemGridUI:new(category_settings, self._widgets_by_name.item_grid, self.hero_name, self.career_index)
	self._item_grid:disable_locked_items(true)
	self._item_grid:mark_locked_items(true)
	self._item_grid:hide_slots(true)
	self._item_grid:disable_item_drag()

	self.super_parent:clear_disabled_backend_ids()
end

function CraftPageExtractSkin:create_ui_elements(params)
	self.ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)


	local widgets = { }
	local widgets_by_name = { }
	for name, widget_definition in pairs(widget_definitions) do
		local widget = UIWidget.init(widget_definition)
		widgets [#widgets + 1] = widget
		widgets_by_name [name] = widget
	end

	self._widgets = widgets
	self._widgets_by_name = widgets_by_name


	UIRenderer.clear_scenegraph_queue(self.ui_renderer)
	self.ui_animator = UIAnimator:new(self.ui_scenegraph, animation_definitions)
	self:_set_craft_button_disabled(true)
	self:_handle_craft_input_progress(0)
end

function CraftPageExtractSkin:on_exit(params)
	print("[HeroWindowCraft] Exit Substate CraftPageExtractSkin")
	self.ui_animator = nil

	if self._craft_input_time then
		self:_play_sound("play_gui_craft_forge_button_aborted")
	end
end

function CraftPageExtractSkin:update(dt, t)
	if DO_RELOAD then
		DO_RELOAD = false
		self:create_ui_elements()
	end

	self:_handle_input(dt, t)
	self:_update_animations(dt)
	self:_update_craft_items()
	self:draw(dt)
end

function CraftPageExtractSkin:post_update(dt, t)

	return end

function CraftPageExtractSkin:_update_animations(dt)
	self.ui_animator:update(dt)

	local animations = self._animations
	local ui_animator = self.ui_animator

	for animation_name, animation_id in pairs(animations) do
		if ui_animator:is_animation_completed(animation_id) then
			ui_animator:stop_animation(animation_id)
			animations [animation_name] = nil
		end
	end

	local widgets_by_name = self._widgets_by_name
	UIWidgetUtils.animate_default_button(widgets_by_name.craft_button, dt)
end

function CraftPageExtractSkin:_is_button_pressed(widget)
	local content = widget.content
	local hotspot = content.button_hotspot
	if hotspot.on_release then
		hotspot.on_release = false
		return true
	end
end

function CraftPageExtractSkin:_is_button_hovered(widget)
	local content = widget.content
	local hotspot = content.button_hotspot
	if hotspot.on_hover_enter then
		return true
	end
end

function CraftPageExtractSkin:_is_button_held(widget)
	local content = widget.content
	local hotspot = content.button_hotspot
	if hotspot.is_clicked then
		return hotspot.is_clicked
	end
end

function CraftPageExtractSkin:_handle_input(dt, t)
	local parent = self.parent
	if parent:waiting_for_craft() or self._craft_result then
		return
	end

	local widgets_by_name = self._widgets_by_name
	local super_parent = self.super_parent

	local gamepad_active = Managers.input:is_device_active("gamepad")
	local input_service = self.super_parent:window_input_service()
	local widget = widgets_by_name.craft_button
	local is_button_enabled = not widget.content.button_hotspot.disable_button

	local craft_input = self:_is_button_held(widgets_by_name.craft_button)
	local craft_input_gamepad = is_button_enabled and gamepad_active and input_service:get("refresh_hold")
	local craft_input_accepted = false
	if craft_input == 0 or craft_input_gamepad then
		if not self._craft_input_time then
			self._craft_input_time = 0
			self:_play_sound("play_gui_craft_forge_button_begin")
		else
			self._craft_input_time = self._craft_input_time + dt
		end

		local max_time = UISettings.crafting_progress_time
		local progress = math.min(self._craft_input_time / max_time, 1)
		craft_input_accepted = self:_handle_craft_input_progress(progress)

		WwiseWorld.set_global_parameter(self.wwise_world, "craft_forge_button_progress", progress)

	elseif self._craft_input_time then
		self._craft_input_time = nil
		self:_handle_craft_input_progress(0)
		self:_play_sound("play_gui_craft_forge_button_aborted")
	end

	if craft_input_accepted then
		local craft_items = self._craft_items
		local material_items = self._material_items
		local items = { }
		for _, backend_id in ipairs(craft_items) do
			items [#items + 1] = backend_id
		end
		for _, backend_id in ipairs(material_items) do
			items [#items + 1] = backend_id
		end

		local recipe_override = self.settings.name
		local recipe_available = parent:craft(items, recipe_override)

		if recipe_available then
			self:_set_craft_button_disabled(true)

			local item_grid = self._item_grid
			for _, backend_id in pairs(items) do
				item_grid:lock_item_by_id(backend_id, true)
			end
			item_grid:update_items_status()

			self:_play_sound("play_gui_craft_forge_button_completed")
			self:_play_sound("play_gui_craft_forge_begin")
		end
	end
end

function CraftPageExtractSkin:_handle_craft_input_progress(progress)
	local has_progress = progress ~= 0

	local bard_default_width = scenegraph_definition.craft_bar.size [1]
	self.ui_scenegraph.craft_bar.size [1] = bard_default_width * progress

	if progress == 1 then
		return true
	end
end

function CraftPageExtractSkin:craft_result(result, error, reset_slots)
	if not error then
		self._craft_result = result
	end
end

function CraftPageExtractSkin:reset()
	local item_grid = self._item_grid
	item_grid:clear_locked_items()
	item_grid:update_items_status()
end

function CraftPageExtractSkin:on_craft_completed()
	local result = self._craft_result
	local item_grid = self._item_grid
	table.clear(self._craft_items)

	for i = 1, NUM_CRAFT_SLOTS do
		self._craft_items [i] = nil
	end

	item_grid:clear_item_grid()
	self.super_parent:clear_disabled_backend_ids()
	self.super_parent:update_inventory_items()

	local num_reward_items = 0
	for index, data in pairs(result) do
		num_reward_items = num_reward_items + 1
	end

	local ignore_sound = true
	for index, data in pairs(result) do
		local backend_id = data [1]
		local amount = data [3]

		self:_add_craft_item(backend_id, index, ignore_sound)
	end

	item_grid:clear_locked_items()
	for _, backend_id in pairs(self._craft_items) do
		item_grid:lock_item_by_id(backend_id, true)
	end
	item_grid:update_items_status()

	self._num_craft_items = 0
	self:_set_craft_button_disabled(true)
	self._craft_result = nil
end

function CraftPageExtractSkin:_update_craft_items()
	local super_parent = self.super_parent
	local item_grid = self._item_grid
	local is_dragging_craft_item = item_grid:is_dragging_item() or item_grid:is_item_dragged() ~= nil

	local pressed_backend_id, is_drag_item = super_parent:get_pressed_item_backend_id()
	if pressed_backend_id then
		if is_drag_item then
			if not is_dragging_craft_item then
				local slot_index = item_grid:is_slot_hovered()
				if slot_index then
					self:_add_craft_item(pressed_backend_id, slot_index)
				end
			end
		else
			self:_add_craft_item(pressed_backend_id)
		end
	end

	local grid_item_pressed = item_grid:is_item_pressed()
	if grid_item_pressed then
		local backend_id = grid_item_pressed.backend_id
		self:_remove_craft_item(backend_id)
	end
end

function CraftPageExtractSkin:_remove_craft_item(backend_id, slot_index)
	local craft_items = self._craft_items

	if slot_index then
		if craft_items [slot_index] then
			backend_id = craft_items [slot_index]
		end
	else
		for item_slot_index, slot_item_backend_id in pairs(craft_items) do
			if slot_item_backend_id == backend_id then
				slot_index = item_slot_index
				break
			end
		end
	end

	if backend_id and slot_index then
		self.super_parent:set_disabled_backend_id(backend_id, false)
		self._item_grid:add_item_to_slot_index(slot_index, nil)

		craft_items [slot_index] = nil

		self._num_craft_items = math.max(( self._num_craft_items or 0 ) - 1, 0)

		if self._num_craft_items == 0 then
			self:_set_craft_button_disabled(true)
		end

		self:_play_sound("play_gui_craft_item_drag")
	end
end

function CraftPageExtractSkin:_add_craft_item(backend_id, slot_index, ignore_sound)
	if self._num_craft_items == 0 then
		self._item_grid:clear_item_grid()
		table.clear(self._craft_items)
	end

	local craft_items = self._craft_items

	if not slot_index then
		for i = 1, 1 do
			if not craft_items [i] then
				slot_index = i
				break
			end
		end
	end

	if slot_index then
		craft_items [slot_index] = backend_id

		local item_interface = Managers.backend:get_interface("items")
		local item = backend_id and item_interface:get_item_from_id(backend_id)

		self._item_grid:add_item_to_slot_index(slot_index, item)
		self.super_parent:set_disabled_backend_id(backend_id, true)

		self._num_craft_items = math.min(( self._num_craft_items or 0 ) + 1, NUM_CRAFT_SLOTS)
		if self._num_craft_items > 0 then
			self:_set_craft_button_disabled(false)
		end

		if backend_id and not ignore_sound then
			self:_play_sound("play_gui_craft_item_drop")
		end
	end
end

function CraftPageExtractSkin:_set_craft_button_disabled(disabled)
	self._widgets_by_name.craft_button.content.button_hotspot.disable_button = disabled
end

function CraftPageExtractSkin:_exit(selected_level)
	self.exit = true
	self.exit_level_id = selected_level
end

function CraftPageExtractSkin:draw(dt)
	local ui_renderer = self.ui_renderer
	local ui_top_renderer = self.ui_top_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.super_parent:window_input_service()

	UIRenderer.begin_pass(ui_top_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)
	for _, widget in ipairs(self._widgets) do
		UIRenderer.draw_widget(ui_top_renderer, widget)
	end

	UIRenderer.end_pass(ui_top_renderer)
end

function CraftPageExtractSkin:_play_sound(event)
	self.super_parent:play_sound(event)
end

function CraftPageExtractSkin:_set_craft_button_text(text, localize)
	local widgets_by_name = self._widgets_by_name
	local widget = widgets_by_name.craft_button
	widget.content.button_text = localize and Localize(text) or text
end