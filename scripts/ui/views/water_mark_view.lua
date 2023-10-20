require("scripts/ui/ui_renderer")
require("scripts/ui/ui_elements")

local definitions = require("scripts/ui/views/water_mark_view_definitions")

WaterMarkView = class(WaterMarkView)

function WaterMarkView:init(world)
	self._world = world
	self._ui_renderer = UIRenderer.create(world, "material", "materials/ui/ui_1080p_watermarks")
	self._render_settings = { snap_pixel_positions = true }
	self:_create_ui_elements()
end

function WaterMarkView:_create_ui_elements()
	self._ui_scenegraph = UISceneGraph.init_scenegraph(definitions.scenegraph_definition)
	self._water_mark_widget = UIWidget.init(definitions.water_mark)

	UIRenderer.clear_scenegraph_queue(self._ui_renderer)
end

local DO_RELOAD = true

function WaterMarkView:update(dt)
	if DO_RELOAD then
		DO_RELOAD = false
		self:_create_ui_elements()
	end

	self:_draw(dt)
end

function WaterMarkView:_draw(dt)
	local ui_renderer = self._ui_renderer
	local ui_scenegraph = self._ui_scenegraph

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, FAKE_INPUT_SERVICE, dt, nil, self._render_settings)

	UIRenderer.draw_widget(ui_renderer, self._water_mark_widget)

	UIRenderer.end_pass(ui_renderer)
end

function WaterMarkView:destroy()
	UIRenderer.destroy(self._ui_renderer, self._world)
end