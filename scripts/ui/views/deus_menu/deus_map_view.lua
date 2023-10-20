require(script_data.FEATURE_old_map_ui and

"scripts/ui/views/deus_menu/deus_map_ui" or "scripts/ui/views/deus_menu/deus_map_ui_v2")

require("scripts/ui/views/deus_menu/deus_map_scene")

local REAL_PLAYER_LOCAL_ID = 1

DeusMapView = class(DeusMapView)

local INPUT_SERVICE_NAME = "deus_map_input_service_name"

function DeusMapView:init(context)
	self._ui = DeusMapUI:new(context)
	self._scene = DeusMapScene:new()

	self._active = false

	self._deus_run_controller = context.deus_run_controller

	local input_manager = context.input_manager
	self._input_manager = input_manager
	self._network_event_delegate = context.network_event_delegate

	input_manager:create_input_service(INPUT_SERVICE_NAME, "IngameMenuKeymaps", "IngameMenuFilters")
	input_manager:map_device_to_service(INPUT_SERVICE_NAME, "keyboard")
	input_manager:map_device_to_service(INPUT_SERVICE_NAME, "mouse")
	input_manager:map_device_to_service(INPUT_SERVICE_NAME, "gamepad")
end

function DeusMapView:start(params)
	fassert(params, "DeusMapView needs params to be set in order to function properly, see GameModeMapDeus")
	self._finish_cb = params.finish_cb

	self._active = true


	local input_manager = self._input_manager
	input_manager:capture_input({ "mouse" }, 1, INPUT_SERVICE_NAME, "DeusMapView")

	ShowCursorStack.push()
	input_manager:enable_gamepad_cursor()

	local input_service = input_manager:get_service(INPUT_SERVICE_NAME)
	self._scene:on_enter(
	self._deus_run_controller:get_graph_data(),
	input_service,
	callback(self, "_node_pressed"),
	callback(self, "_node_hovered"),
	callback(self, "_node_unhovered"))

	self._ui:on_enter(input_service)

	self:_start()
end

function DeusMapView:_finish()
	local input_manager = self._input_manager
	input_manager:release_input({ "mouse" }, 1, INPUT_SERVICE_NAME, "DeusMapView")

	ShowCursorStack.pop()
	input_manager:disable_gamepad_cursor()

	self._active = false
	self._scene:on_finish()
end

function DeusMapView:update(dt, t)
	if self._active then
		self:_update(dt, t)
	end

	self._ui:update(dt, t)
	self._scene:update(dt, t, Managers.input:is_device_active("gamepad"))
end

function DeusMapView:post_update(dt, t)
	self._scene:post_update(dt, t)
end

function DeusMapView:input_service()
	return self._input_manager:get_service(INPUT_SERVICE_NAME)
end

function DeusMapView:is_active()
	return self._active
end

function DeusMapView:destroy()
	if self._active then
		self:_finish()
	end

	self._scene:destroy()
	self._ui:destroy()
end





function DeusMapView:register_rpcs(network_event_delegate, network_transmit)
	if network_event_delegate then
		local subclass_rpcs = self._get_rpcs and self:_get_rpcs()
		if subclass_rpcs then
			network_event_delegate:register(self, unpack(subclass_rpcs))
		end
	end
end

function DeusMapView:unregister_rpcs()
	if self._network_event_delegate then
		self._network_event_delegate:unregister(self)
	end
end





function DeusMapView:_start(params) return end

function DeusMapView:_update(dt, t) return end

function DeusMapView:_get_rpcs() return end

function DeusMapView:_node_pressed(node_key) return end

function DeusMapView:_node_hovered(node_key) return end

function DeusMapView:_node_unhovered() return end