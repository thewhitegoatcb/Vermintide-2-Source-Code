
CameraStateFollowThirdPersonOverShoulder = class(CameraStateFollowThirdPersonOverShoulder, CameraState)

function CameraStateFollowThirdPersonOverShoulder:init(camera_state_init_context)
	CameraState.init(self, camera_state_init_context, "follow_third_person_over_shoulder")

	self._follow_unit = nil
	self._follow_node = 0
end

function CameraStateFollowThirdPersonOverShoulder:on_enter(unit, input, dt, context, t, previous_state, params)
	local camera_extension = self.camera_extension
	local follow_unit, follow_node = camera_extension:get_follow_data()
	local viewport_name = camera_extension.viewport_name

	self._follow_unit = follow_unit
	self._follow_node = follow_node

	local camera_manager = Managers.state.camera
	local root_look_dir = Vector3.normalize(Vector3.flat(Quaternion.forward(Unit.local_rotation(follow_unit, 0))))
	local yaw = math.atan2(root_look_dir.y, root_look_dir.x)

	camera_manager:set_pitch_yaw(viewport_name, -0.6, yaw)
	Unit.set_data(unit, "camera", "settings_node", "over_shoulder")
end

function CameraStateFollowThirdPersonOverShoulder:on_exit(unit, input, dt, context, t, next_state)
	self._follow_unit = nil
end

function CameraStateFollowThirdPersonOverShoulder:refresh_follow_unit(follow_unit, follow_node)
	self._follow_unit = follow_unit
	self._follow_node = follow_node
end

function CameraStateFollowThirdPersonOverShoulder:update(unit, input, dt, context, t)
	local csm = self.csm
	local unit = self.unit
	local camera_extension = self.camera_extension
	local follow_unit = self._follow_unit
	local follow_node = self._follow_node

	if not Unit.alive(follow_unit) then
		csm:change_state("idle")
		return
	end

	local external_state_change = camera_extension.external_state_change
	local external_state_change_params = camera_extension.external_state_change_params
	if external_state_change and external_state_change ~= self.name then
		csm:change_state(external_state_change, external_state_change_params)
		camera_extension:set_external_state_change(nil)
		return
	end

	CameraStateHelper.set_local_pose(unit, follow_unit, follow_node)
end