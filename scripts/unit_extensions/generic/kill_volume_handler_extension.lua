KillVolumeHandlerExtension = class(KillVolumeHandlerExtension)

function KillVolumeHandlerExtension:init(extension_init_context, unit, extension_init_data)
	self._callbacks = { }
end

function KillVolumeHandlerExtension:game_object_initialized(unit, go_id)
	return end

function KillVolumeHandlerExtension:destroy()
	return end

function KillVolumeHandlerExtension:add_handler(on_hit_kill_volume_cb)
	self._callbacks [#self._callbacks + 1] = on_hit_kill_volume_cb
end

function KillVolumeHandlerExtension:on_hit_kill_volume()
	local handled = false
	for i = 1, #self._callbacks do
		local cb = self._callbacks [i]
		handled = cb() or handled
	end
	return handled
end