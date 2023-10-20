ScriptViewport = ScriptViewport or { }

function ScriptViewport.active(viewport)
	return Viewport.get_data(viewport, "active")
end

function ScriptViewport.camera(viewport)
	return Viewport.get_data(viewport, "camera")
end

function ScriptViewport.shadow_cull_camera(viewport)
	return Viewport.get_data(viewport, "shadow_cull_camera")
end