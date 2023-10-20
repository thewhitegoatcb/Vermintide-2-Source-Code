ScriptCamera = ScriptCamera or { }

function ScriptCamera.position(camera)
	local camera_unit = Camera.get_data(camera, "unit")
	return Unit.local_position(camera_unit, 0)
end

function ScriptCamera.rotation(camera)
	local camera_unit = Camera.get_data(camera, "unit")
	return Unit.local_rotation(camera_unit, 0)
end

function ScriptCamera.pose(camera)
	local camera_unit = Camera.get_data(camera, "unit")
	return Unit.local_pose(camera_unit, 0)
end

function ScriptCamera.set_local_position(camera, position)
	local camera_unit = Camera.get_data(camera, "unit")
	Camera.set_local_position(camera, camera_unit, position)
end

function ScriptCamera.set_local_rotation(camera, rotation)
	local camera_unit = Camera.get_data(camera, "unit")
	Camera.set_local_rotation(camera, camera_unit, rotation)
end

function ScriptCamera.set_local_pose(camera, pose)
	local camera_unit = Camera.get_data(camera, "unit")
	Camera.set_local_pose(camera, camera_unit, pose)
end

function ScriptCamera.force_update(world, camera)
	local camera_unit = Camera.get_data(camera, "unit")
	World.update_unit(world, camera_unit)
end