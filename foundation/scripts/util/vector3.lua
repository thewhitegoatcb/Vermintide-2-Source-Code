function Vector3.flat(v)
	return Vector3(v [1], v [2], 0)
end

function Vector3.step(start, target, step_size)
	local offset = target - start
	local distance = Vector3.length(offset)

	if distance < step_size then
		do return target, true end
	else
		return start + Vector3.normalize(offset) * step_size, false
	end
end

function Vector3.smoothstep(t, v1, v2)
	local smoothstep = math.smoothstep(t, 0, 1)
	return Vector3.lerp(v1, v2, smoothstep)
end

function Vector3.flat_angle(v1, v2)
	local a1 = math.atan2(v1.y, v1.x)
	local a2 = math.atan2(v2.y, v2.x)

	return ( a2 - a1 + math.pi ) % (2 * math.pi) - math.pi
end

function Vector3.clamp(v, min, max)
	local x, y, z = Vector3.to_elements(v)
	local clamp = math.clamp

	return Vector3(clamp(x, min, max), clamp(y, min, max), clamp(z, min, max))
end


function Vector3.clamp_3d(v, min, max)
	local x, y, z = Vector3.to_elements(v)
	return Vector3(math.clamp(x, min [1], max [1]), math.clamp(y, min [2], max [2]), math.clamp(z, min [3], max [3]))
end

function Vector3.invalid_vector()
	return Vector3(math.huge, math.huge, math.huge)
end

function Vector3.copy(v)
	local x, y, z = Vector3.to_elements(v)
	return Vector3(x, y, z)
end


function Vector3.deprecated_copy(vector)
	return Vector3(vector [1], vector [2], vector [3])
end

function Vector3.project_on_plane(vector, normal)
	return vector - Vector3.dot(vector, normal) * normal
end


function Vector3.reflect(vector, surface_normal)
	return vector - 2 * Vector3.dot(vector, surface_normal) * surface_normal
end

function Vector3.rotate(vector, angle, optional_axis)
	optional_axis = optional_axis or Vector3.up()
	return Quaternion.rotate(Quaternion.axis_angle(optional_axis, angle), vector)
end

Vector3Aux = Vector3Aux or { }

function Vector3Aux.box(destination, vector_3)
	destination = destination or { }
	destination [1], destination [2], destination [3] = Vector3.to_elements(vector_3)
	return destination
end

function Vector3Aux.unbox(boxed_vector)
	return Vector3(boxed_vector [1], boxed_vector [2], boxed_vector [3])
end