

















local function error_prone_clone(value)
	if not value then
		return { }
	end
	return table.clone(value)
end















UIWidget = UIWidget or { }






function UIWidget.init(widget_definition)


	local content = error_prone_clone(widget_definition.content)
	local style = error_prone_clone(widget_definition.style)
	local offset = widget_definition.offset and error_prone_clone(widget_definition.offset)


	local passes = widget_definition.element.passes
	local num_passes = #passes
	local pass_data = Script.new_array(num_passes)
	for i = 1, num_passes do
		local pass = passes [i]
		local pass_type = pass.pass_type
		local ui_pass = UIPasses [pass_type]






		pass_data [i] = ui_pass.init(pass, content, style)
	end


	local widget = {
		scenegraph_id = widget_definition.scenegraph_id,
		offset = offset or false,
		element = {
			passes = passes,
			pass_data = pass_data },

		content = content,
		style = style,

		animations = { } }









	return widget
end






function UIWidget.destroy(ui_renderer, widget)
	local element = widget.element
	local pass_data = element.pass_data
	local passes = element.passes
	for i = 1, #passes do
		local pass = passes [i]
		local pass_type = pass.pass_type
		local ui_pass = UIPasses [pass_type]
		fassert(ui_pass, "No such pass-type: %s", pass_type)

		if ui_pass.destroy then
			ui_pass.destroy(ui_renderer, pass_data [i], pass)
		end
	end
end



function UIWidget.animate(widget, animation)
	widget.animations [animation] = true
end

function UIWidget.stop_animations(widget)
	table.clear(widget.animations)
end

function UIWidget.has_animation(widget)
	return next(widget.animations) and true or false
end