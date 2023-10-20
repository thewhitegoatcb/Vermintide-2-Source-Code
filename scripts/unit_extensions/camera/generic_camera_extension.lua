GenericCameraExtension = class(GenericCameraExtension)

function GenericCameraExtension:init(extension_init_context, unit, extension_init_data)
	self.unit = unit
	self.player = extension_init_data.player
	self.viewport_name = self.player.viewport_name

	self.idle_position = Vector3Box(0, 0, 0)
	self.idle_rotation = QuaternionBox(Quaternion.identity())

	self.external_state_change = nil
	self.external_state_change_params = nil
	self.observed_player_id = nil
end

function GenericCameraExtension:extensions_ready()

	return end

function GenericCameraExtension:update(unit, input, dt, context, t)
	return end

function GenericCameraExtension:get_observed_player_id()
	return self.observed_player_id
end

function GenericCameraExtension:set_observed_player_id(observed_player_id)
	self.observed_player_id = observed_player_id
end

function GenericCameraExtension:set_external_state_change(state, params)
	self.external_state_change = state
	self.external_state_change_params = params
end

function GenericCameraExtension:set_idle_position(position)
	local viewport_name = self.viewport_name
	assert(Vector3.is_valid(position), "Trying to set invalid camera position")
	self.idle_position:store(position)
end

function GenericCameraExtension:set_idle_rotation(rotation)
	local viewport_name = self.viewport_name

	self.idle_rotation:store(rotation)
end

function GenericCameraExtension:get_idle_position()
	return self.idle_position:unbox()
end

function GenericCameraExtension:get_idle_rotation()
	return self.idle_rotation:unbox()
end

function GenericCameraExtension:set_follow_unit(follow_unit, follow_node)

	self.override_follow_unit = follow_unit
	self.override_follow_node = follow_node and Unit.node(follow_unit, follow_node) or nil
end

function GenericCameraExtension:get_follow_data()
	local player = self.player
	local player_unit = player.player_unit
	local first_person_unit, node = nil


	if player.respawning then
		return
	end

	if self.override_follow_unit then
		do return self.override_follow_unit, self.override_follow_node end
	elseif player_unit and ScriptUnit.has_extension(player_unit, "first_person_system") then
		local first_person_extension = ScriptUnit.extension(player_unit, "first_person_system")
		first_person_unit = first_person_extension:get_first_person_unit()
		node = Unit.node(first_person_unit, "camera_node")
	end

	return first_person_unit, node
end

function GenericCameraExtension:destroy()
	return end