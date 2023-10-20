require("scripts/ui/views/disconnect_indicator_view")
require("scripts/ui/views/loading_icon_view")
require("scripts/ui/views/twitch_icon_view")

if script_data.honduras_demo then
	require("scripts/ui/views/water_mark_view")
	require("scripts/ui/views/transition_video")
end

TransitionManager = class(TransitionManager)

function TransitionManager:init()
	self:_setup_names()
	self:_setup_world()

	self._loading_icon_view = LoadingIconView:new(self._world)
	self._disconnect_indicator_view = DisconnectIndicatorView:new(self._world)

	self._twitch_icon_view = TwitchIconView:new(self._world)

	if script_data.honduras_demo then
		self._watermark = WaterMarkView:new(self._world)
		self._transition_video = TransitionVideo:new(self._world)
	end

	self._color = Vector3Box(0, 0, 0)
	self._fade_state = "out"
	self._fade = 0
end

function TransitionManager:_setup_names()
	self._world_name = "top_ingame_view"
end

function TransitionManager:set_multiplayer_values(type, data, string)
	self._multiplayer_tracking = self._multiplayer_tracking or { }
	self._multiplayer_tracking [type] = self._multiplayer_tracking [type] or { }
	self._multiplayer_tracking [type] [#self._multiplayer_tracking [type] + 1] = data
	self._multiplayer_tracking.string = self._multiplayer_tracking.string or { }
	self._multiplayer_tracking.string [#self._multiplayer_tracking.string + 1] = string
end

function TransitionManager:dump_multiplayer_data()
	Application.warning(" ")
	Application.warning("##################################")
	Application.warning(" ")
	Application.warning("############## START #############")
	table.dump(self._multiplayer_tracking.start or { }, "MultiplayerRoundStart", 2, Application.warning)
	Application.warning(" ")
	Application.warning("############### END ##############")
	table.dump(self._multiplayer_tracking ["end"] or { }, "MultiplayerRoundEnd", 2, Application.warning)
	Application.warning(" ")
	Application.warning("############# STRINGS ############")
	table.dump(self._multiplayer_tracking.string or { }, "Strings", 2, Application.warning)
	Application.warning(" ")
	Application.warning("##################################")
	Application.warning(" ")
end

function TransitionManager:_setup_world()
	local world = Managers.world:create_world(self._world_name, GameSettingsDevelopment.default_environment, nil, 991, Application.DISABLE_PHYSICS, Application.DISABLE_APEX_CLOTH)
	ScriptWorld.activate(world)
	self._loading_icon_viewport = ScriptWorld.create_viewport(world, "top_ingame_view_viewport", "overlay", 1)

	self._world = world

	self._gui = World.create_screen_gui(self._world, "material", "materials/fonts/gw_fonts", "immediate")
end

function TransitionManager:destroy()
	self._loading_icon_view:destroy()
	self._loading_icon_view = nil
	if self._disconnect_indicator_view then
		self._disconnect_indicator_view:destroy()
		self._disconnect_indicator_view = nil
	end

	if self._twitch_icon_view then
		self._twitch_icon_view:destroy()
	end
	self._twitch_icon_view = nil

	if self._watermark then
		self._watermark:destroy()
	end

	if self._transition_video then
		self._transition_video:destroy()
	end
	self._transition_video = nil

	Managers.world:destroy_world(self._world_name)

end

function TransitionManager:show_waiting_for_peers_message(enable)
	self._waiting_for_peers_message = enable
	self._waiting_for_peers_timer = Managers.time:time("main")
end

function TransitionManager:show_loading_icon(show_background)
	self._loading_icon_view:show_loading_icon()
	if show_background then
		self:show_icon_background()
	else
		self:hide_icon_background()
	end
end

function TransitionManager:show_video(show)
	if self._transition_video then
		self._transition_video:activate(show)
	end
end

function TransitionManager:is_video_done()
	if self._transition_video then
		return self._transition_video:completed()
	end
end

function TransitionManager:is_video_active()
	if self._transition_video then
		return self._transition_video:is_active()
	end
end

function TransitionManager:hide_loading_icon()
	self._loading_icon_view:hide_loading_icon()
end

function TransitionManager:show_icon_background()
	self._loading_icon_view:show_icon_background()
end

function TransitionManager:hide_icon_background()
	self._loading_icon_view:hide_icon_background()
end

function TransitionManager:loading_icon_active()
	return self._loading_icon_view and self._loading_icon_view:active()
end

function TransitionManager:fade_in(speed, callback)
	self._fade_state = "fade_in"
	self._fade_speed = speed
	self._callback = callback

	if script_data.debug_transition_manager then
		print("[TransitionManager:fade_in]", Script.callstack())
	end
end

function TransitionManager:fade_out(speed, callback)
	self._fade_state = "fade_out"
	self._fade_speed = -speed
	self._callback = callback

	if script_data.debug_transition_manager then
		print("[TransitionManager:fade_out]", Script.callstack())
	end
end

function TransitionManager:force_fade_in()
	self._fade_state = "in"
	self._fade_speed = 0
	self._fade = 1
	if self._callback then
		self._callback()
		self._callback = nil
	end
end

function TransitionManager:force_fade_out()
	self._fade_state = "out"
	self._fade_speed = 0
	self._fade = 0
	if self._callback then
		self._callback()
		self._callback = nil
	end
end

function TransitionManager:fade_state()
	return self._fade_state
end

function TransitionManager:in_fade_active()
	return self._fade ~= 0
end

function TransitionManager:fade_value()
	return self._fade
end

function TransitionManager:fade_in_completed()
	return self._fade_state == "in" and self._fade == 1
end

function TransitionManager:fade_out_completed()
	return self._fade_state == "out" and self._fade == 0
end

function TransitionManager:_render(dt)
	if DEDICATED_SERVER then
		return
	end

	local w, h = Application.resolution()

	local color = self._color:unbox()
	Gui.rect(self._gui, Vector3(0, 0, UILayer.transition), Vector2(w, h), Color(self._fade * 255, color.x, color.y, color.z))
end

local FONT_STYLE = { font_type = "hell_shark", font_size = 56 }




function TransitionManager:_render_waiting_message(dt)
	if not self._waiting_for_peers_message then
		return
	end

	if IS_WINDOWS or IS_LINUX then
		self:show_waiting_for_peers_message(false)
		return
	end

	if self._fade_state == "fade_out" or self._fade_state == "out" then
		self:show_waiting_for_peers_message(false)
		return
	end

	local w, h = Gui.resolution()
	local alpha = 192 + 63 * math.sin(self._waiting_for_peers_timer * 4)
	local text = Localize("matchmaking_status_waiting_for_other_players")
	local font, size_of_font = UIFontByResolution(FONT_STYLE)
	local font_name = font [1]
	local font_size = font [2]
	local font_material = font [3]
	local color = Color(255, alpha, alpha, alpha)

	local min, max = Gui.text_extents(self._gui, text, font_name, size_of_font)
	local text_width = max.x - min.x
	local position = Vector3(w * 0.5 - text_width * 0.5, h * 0.1, UILayer.transition + 1)

	Gui.text(self._gui, text, font_name, size_of_font, font_material, position, color)

	self._waiting_for_peers_timer = self._waiting_for_peers_timer + dt
end

function TransitionManager:force_render(dt)
	local is_loading_icon_active = self:loading_icon_active()
	if is_loading_icon_active and not Development.parameter("disable_loading_icon") then
		self._loading_icon_view:update(dt)
	end

	if script_data.honduras_demo then
		if not Development.parameter("disable_water_mark") then
			self._watermark:update(dt)
		end
		self._transition_video:update(dt)
	end

	self:_render()
end

function TransitionManager:update(dt)

	if Managers.eac ~= nil then
		Managers.eac:draw_panel(self._gui, dt)
	end

	if self._disconnect_indicator_view then
		self._disconnect_indicator_view:update(dt)
	end

	local is_loading_icon_active = self:loading_icon_active()
	if is_loading_icon_active and not Development.parameter("disable_loading_icon") then
		self._loading_icon_view:update(dt)
	end

	if self._twitch_icon_view then
		self._twitch_icon_view:update(dt)
	end

	self:_render_waiting_message(dt)

	if script_data.honduras_demo then
		if not Development.parameter("disable_water_mark") then
			self._watermark:update(dt)
		end
		self._transition_video:update(dt)
	end

	if self._fade_state == "out" then
		return
	end

	if self._fade_state == "in" then
		self:_render(dt)
		return
	end

	self._fade = math.clamp(self._fade + self._fade_speed * math.min(dt, 0.03333333333333333), 0, 1)

	if self._fade_state == "fade_in" and self._fade >= 1 then
		self._fade = 1
		self._fade_state = "in"

		if self._callback then
			local callback = self._callback
			self._callback = nil
			callback()
		end
	elseif self._fade_state == "fade_out" and self._fade <= 0 then
		self._fade = 0
		self._fade_state = "out"

		if self._callback then
			local callback = self._callback
			self._callback = nil
			callback()
		end
		return
	end

	if self._fade_state ~= "out" then
		self:_render(dt)
	end
end