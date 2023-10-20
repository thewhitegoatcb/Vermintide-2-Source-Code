local font_size = 26
local font = "arial"
local font_mtrl = "materials/fonts/" .. font

PlayerHud = class(PlayerHud)

function PlayerHud:init(extension_init_context, unit, extension_init_data)
	self.world = extension_init_context.world

	self.gui = World.create_screen_gui(self.world, "material", "materials/fonts/gw_fonts", "immediate")

	self.raycast_state = "waiting_to_raycast"
	self.raycast_target = nil

	local physics_world = World.get_data(extension_init_context.world, "physics_world")
	self.physics_world = physics_world

	self.current_location = nil
	self.picked_up_ammo = false

	self.hit_marker_data = { }
	self:reset()
end

function PlayerHud:extensions_ready(world, unit)
	return end

function PlayerHud:destroy()
	return end

function PlayerHud:reset()
	self.outline_timers = { }
end

local show_intensity = true

function PlayerHud:update(unit, input, dt, context, t)
	return end

function PlayerHud:draw_player_names(unit)
	local player_manager = Managers.player
	local players = player_manager:players()

	local viewport_name = "player_1"
	local viewport = ScriptWorld.viewport(self.world, viewport_name)
	local camera = ScriptViewport.camera(viewport)

	local res_x = RESOLUTION_LOOKUP.res_w local res_y = RESOLUTION_LOOKUP.res_h
	local viewport_center = Vector3(res_x / 2, res_y / 2, 0)
	local text_visibility_radius_sq = res_y / 3
	text_visibility_radius_sq = text_visibility_radius_sq * text_visibility_radius_sq

	local gui = self.gui
	local offset_vector = Vector3(0, 0, 0.925)
	for k, player in pairs(players) do
		local name = player:name()
		if player.player_unit and

		player.player_unit ~= unit then
			local player_world_pos_center = Unit.local_position(player.player_unit, 0) + offset_vector
			local player_world_pos_head = player_world_pos_center + offset_vector

			if Camera.inside_frustum(camera, player_world_pos_center) > 0 then
				local min, max = Gui.text_extents(gui, name, font_mtrl, font_size)
				local text_length = max.x - min.x

				local player_screen_pos_center = Camera.world_to_screen(camera, player_world_pos_center)
				player_screen_pos_center = Vector3(player_screen_pos_center.x, player_screen_pos_center.z, 0)

				local player_screen_pos_head = Camera.world_to_screen(camera, player_world_pos_head)
				local text_pos = Vector3(player_screen_pos_head.x - text_length / 2, player_screen_pos_head.z, 0)

				local distance_to_center_sq = Vector3.distance_squared(player_screen_pos_center, viewport_center)
				local delta = math.max(text_visibility_radius_sq - distance_to_center_sq, 0)
				local opacity = delta / text_visibility_radius_sq
				local color = Color(255 * opacity, 0, 200, 200)

				Gui.text(gui, name, font_mtrl, font_size, font, text_pos, color)
			end
		end
	end

end

function PlayerHud:set_current_location(location)
	self.current_location = location
end

function PlayerHud:block_current_location_ui(block_ui)
	self.location_ui_blocked = block_ui
end

function PlayerHud:gdc_intro_active(state)
	self.show_gdc_intro = true
end

function PlayerHud:set_picked_up_ammo(picked_up_ammo)
	self.picked_up_ammo = picked_up_ammo
end

function PlayerHud:get_picked_up_ammo()
	return self.picked_up_ammo
end