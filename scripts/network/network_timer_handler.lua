NetworkTimerHandler = class(NetworkTimerHandler)

function NetworkTimerHandler:init(world, network_clock, is_server)
	self._timer_state = "inactive"

	self._world = world
	self._network_clock = network_clock
	self.is_server = is_server


	self._gui = World.create_screen_gui(world, "material", "materials/fonts/gw_fonts", "immediate")
end

local RPCS = { "rpc_start_network_timer" }



function NetworkTimerHandler:register_rpcs(network_event_delegate)
	network_event_delegate:register(self, unpack(RPCS))
	self._network_event_delegate = network_event_delegate
end

function NetworkTimerHandler:unregister_rpcs()
	self._network_event_delegate:unregister(self)
	self._network_event_delegate = nil
end

function NetworkTimerHandler:start_timer_server(time)
	assert(self.is_server == true, "Tried starting timer as server; not server")

	local current_time = self._network_clock:time()
	local end_time = current_time + time

	self:start_timer_client(end_time)

	local network_manager = Managers.state.network
	network_manager.network_transmit:send_rpc_clients("rpc_start_network_timer", end_time)
end

function NetworkTimerHandler:start_timer_client(end_time)
	self._timer_state = "active"
	self._end_time = end_time
end

function NetworkTimerHandler:update(dt, t)
	if self._timer_state == "inactive" then
		return
	end

	self:_render_timer()

	local current_time = self._network_clock:time()
	if self._end_time <= current_time then
		self._timer_state = "inactive"
		self._end_time = nil

		local level = LevelHelper:current_level(self._world)
		Level.trigger_event(level, "network_timer_done")
	end
end

function NetworkTimerHandler:_render_timer()
	if not script_data.debug_enabled then
		return
	end

	local current_time = self._network_clock:time()
	local end_time = self._end_time
	local time_left = tostring(math.max(0, math.ceil(end_time - current_time)))

	local w, h = Gui.resolution()
	local pos = Vector3(0, 0, 100)
	local size = Vector2(120, 50)

	Gui.rect(self._gui, pos, size, Color(150, 102, 255, 102))

	local text_pos = Vector3(20, 15, 110)
	local material = "arial"
	local font = "materials/fonts/" .. material
	local font_size = 30

	Gui.text(self._gui, time_left, font, font_size, material, text_pos, Color(255, 0, 0, 0))
end

function NetworkTimerHandler:destroy()
	World.destroy_gui(self._world, self._gui)
	self._gui = nil
	self._world = nil
	self._network_clock = nil
end


function NetworkTimerHandler:rpc_start_network_timer(channel_id, end_time)
	self:start_timer_client(end_time)
end