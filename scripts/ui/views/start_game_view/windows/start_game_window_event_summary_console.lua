local definitions = local_require("scripts/ui/views/start_game_view/windows/definitions/start_game_window_event_summary_console_definitions")

local widget_definitions = definitions.widgets
local scenegraph_definition = definitions.scenegraph_definition
local animation_definitions = definitions.animation_definitions



StartGameWindowEventSummaryConsole = class(StartGameWindowEventSummaryConsole)
StartGameWindowEventSummaryConsole.NAME = "StartGameWindowEventSummaryConsole"

function StartGameWindowEventSummaryConsole:on_enter(params, offset)
	print("[StartGameWindow] Enter Substate StartGameWindowEventSummaryConsole")

	self.parent = params.parent
	local ingame_ui_context = params.ingame_ui_context
	self.ui_renderer = ingame_ui_context.ui_renderer
	self._ui_top_renderer = ingame_ui_context.ui_top_renderer
	self.input_manager = ingame_ui_context.input_manager
	self.statistics_db = ingame_ui_context.statistics_db
	self.render_settings = { snap_pixel_positions = true }

	local player_manager = Managers.player
	local local_player = player_manager:local_player()
	self._stats_id = local_player:stats_id()
	self.player_manager = player_manager
	self.peer_id = ingame_ui_context.peer_id

	self._animations = { }
	self:create_ui_elements(params, offset)
end

function StartGameWindowEventSummaryConsole:_start_transition_animation(animation_name)
	local params = {
		render_settings = self.render_settings }


	local widgets = { }
	local anim_id = self.ui_animator:start_animation(animation_name, widgets, scenegraph_definition, params)
	self._animations [animation_name] = anim_id
end

function StartGameWindowEventSummaryConsole:create_ui_elements(params, offset)
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

	if offset then
		local window_position = self.ui_scenegraph.window.local_position
		window_position [1] = window_position [1] + offset [1]
		window_position [2] = window_position [2] + offset [2]
		window_position [3] = window_position [3] + offset [3]
	end
	self:_setup_content_from_backend()
end

function StartGameWindowEventSummaryConsole:_setup_content_from_backend()
	local live_event_interface = Managers.backend:get_interface("live_events")
	local game_mode_data = live_event_interface:get_weekly_events_game_mode_data()

	local widgets_by_name = self._widgets_by_name
	local event_summary_widget = widgets_by_name.event_summary
	local level_key = game_mode_data.level_key
	local mutators = game_mode_data.mutators
	event_summary_widget.content.item = { level_key = level_key, mutators = mutators }
end

function StartGameWindowEventSummaryConsole:on_exit(params)
	print("[StartGameWindow] Exit Substate StartGameWindowEventSummaryConsole")
	self.ui_animator = nil
end

function StartGameWindowEventSummaryConsole:update(dt, t)







	self:_update_animations(dt)
	self:draw(dt)
end

function StartGameWindowEventSummaryConsole:post_update(dt, t)
	return end

function StartGameWindowEventSummaryConsole:_update_animations(dt)
	local ui_animator = self.ui_animator
	ui_animator:update(dt)

	local animations = self._animations
	for animation_name, animation_id in pairs(animations) do
		if ui_animator:is_animation_completed(animation_id) then
			ui_animator:stop_animation(animation_id)
			animations [animation_name] = nil
		end
	end
end

function StartGameWindowEventSummaryConsole:draw(dt)
	local ui_top_renderer = self._ui_top_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.parent:window_input_service()

	UIRenderer.begin_pass(ui_top_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)
	local widgets = self._widgets
	for i = 1, #widgets do
		local widget = widgets [i]
		UIRenderer.draw_widget(ui_top_renderer, widget)
	end
	UIRenderer.end_pass(ui_top_renderer)
end