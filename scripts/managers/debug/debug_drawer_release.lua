

DebugDrawerRelease = class(DebugDrawerRelease)

function DebugDrawerRelease:init(line_object, mode)
	self._line_object = line_object
	self._mode = mode
end

function DebugDrawerRelease:reset()
	return end

function DebugDrawerRelease:line_object()
	return self._line_object
end

function DebugDrawerRelease:line(from, to, color)
	return end

function DebugDrawerRelease:sphere(center, radius, color, segments, parts)
	return end

function DebugDrawerRelease:capsule_overlap(position, size, rotation, color)
	return end

function DebugDrawerRelease:box_sweep(pose, extents, movement_vector, color1, color2)
	return end

function DebugDrawerRelease:capsule(from, to, radius, color)
	return end

function DebugDrawerRelease:actor(actor, color, camera_pose)
	return end

function DebugDrawerRelease:box(pose, extents, color)
	return end

function DebugDrawerRelease:cone(from, to, radius, color, segements, bars)
	return end

function DebugDrawerRelease:circle(center, radius, normal, color, segments)
	return end

function DebugDrawerRelease:arrow_2d(from, to, color)
	return end

function DebugDrawerRelease:cylinder(pos1, pos2, radius, color, segments)
	return end

function DebugDrawerRelease:vector(position, vector, color)
	return end

function DebugDrawerRelease:quaternion(position, quaternion, scale)
	return end

function DebugDrawerRelease:matrix4x4(matrix, scale)
	return end

function DebugDrawerRelease:unit(unit, color)
	return end

function DebugDrawerRelease:navigation_mesh_search(mesh)
	return end

function DebugDrawerRelease:update(world)
	return end