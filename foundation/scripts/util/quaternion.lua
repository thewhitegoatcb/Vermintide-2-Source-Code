function Quaternion.yaw(q)
	local x, y, z, w = Quaternion.to_elements(q)
	return math.atan2(2 * (x * y + w * z), w * w + x * x - y * y - z * z)
end

function Quaternion.pitch(q)
	local x, y, z, w = Quaternion.to_elements(q)
	return math.atan2(2 * (y * z + w * x), w * w - x * x - y * y + z * z)
end

function Quaternion.roll(q)
	local x, y, z, w = Quaternion.to_elements(q)

	return math.asin(-2 * (x * z - w * y))
end

function Quaternion.flat_no_roll(q)
	return Quaternion.axis_angle(Vector3.up(), Quaternion.yaw(q))
end