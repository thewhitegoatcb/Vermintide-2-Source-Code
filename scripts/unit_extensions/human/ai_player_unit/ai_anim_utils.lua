AiAnimUtils = AiAnimUtils or { }

local POSITION_LOOKUP = POSITION_LOOKUP

function AiAnimUtils.get_animation_rotation_scale(unit, target_pos, animation_name, anims_data)
	local unit_pos = POSITION_LOOKUP [unit]
	local unit_rot = Unit.local_rotation(unit, 0)
	local forward_dir = Quaternion.forward(unit_rot, 0)
	local target_dir = Vector3.normalize(target_pos - unit_pos)

	local unit_rot_radians = math.atan2(forward_dir.y, forward_dir.x)
	local target_rot_radians = math.atan2(target_dir.y, target_dir.x)

	local unit_to_target_rot_radians = target_rot_radians - unit_rot_radians
	local rotation_sign = anims_data [animation_name].dir
	unit_to_target_rot_radians = unit_to_target_rot_radians * rotation_sign


	if unit_to_target_rot_radians < 0 then
		unit_to_target_rot_radians = unit_to_target_rot_radians + 2 * math.pi
	end

	local animation_rot_radians = anims_data [animation_name].rad
	local rotation_scale = unit_to_target_rot_radians / animation_rot_radians

	return rotation_scale
end

local function randomize(event)
	if type(event) == "table" then
		do return event [Math.random(1, #event)] end
	else
		return event
	end
end

function AiAnimUtils.get_start_move_animation(unit, target_pos, anims_table)
	local animation_name = nil
	local current_pos = POSITION_LOOKUP [unit]

	local target_vector_flat = Vector3.normalize(Vector3.flat(target_pos - current_pos))

	local rotation = Unit.local_rotation(unit, 0)
	local forward_vector_flat = Vector3.normalize(Vector3.flat(Quaternion.forward(rotation)))

	local dot_product = Vector3.dot(forward_vector_flat, target_vector_flat)
	local inv_sqrt_2 = 0.707

	if dot_product >= inv_sqrt_2 then
		animation_name = anims_table.fwd
	elseif dot_product > -inv_sqrt_2 then
		local is_to_the_left = Vector3.cross(forward_vector_flat, target_vector_flat).z > 0
		animation_name = is_to_the_left and anims_table.left or anims_table.right
	else
		animation_name = anims_table.bwd
	end
	local final_animation_name = randomize(animation_name)
	return final_animation_name
end

function AiAnimUtils.set_idle_animation_merge(unit, blackboard)
	local breed = blackboard.breed
	local animation_merge_options = breed.animation_merge_options
	local idle_animation_merge_options = animation_merge_options and animation_merge_options.idle_animation_merge_options

	if idle_animation_merge_options then
		Unit.set_animation_merge_options(unit, unpack(idle_animation_merge_options))
	end






end

function AiAnimUtils.set_move_animation_merge(unit, blackboard)
	local breed = blackboard.breed
	local animation_merge_options = breed.animation_merge_options
	local move_animation_merge_options = animation_merge_options and animation_merge_options.move_animation_merge_options

	if move_animation_merge_options then
		Unit.set_animation_merge_options(unit, unpack(move_animation_merge_options))
	end






end

function AiAnimUtils.set_walk_animation_merge(unit, blackboard)
	local breed = blackboard.breed
	local animation_merge_options = breed.animation_merge_options
	local walk_animation_merge_options = animation_merge_options and animation_merge_options.walk_animation_merge_options

	if walk_animation_merge_options then
		Unit.set_animation_merge_options(unit, unpack(walk_animation_merge_options))
	end






end

function AiAnimUtils.set_interest_point_animation_merge(unit, blackboard)
	local breed = blackboard.breed
	local animation_merge_options = breed.animation_merge_options
	local interest_point_animation_merge_options = animation_merge_options and animation_merge_options.interest_point_animation_merge_options

	if interest_point_animation_merge_options then
		Unit.set_animation_merge_options(unit, unpack(interest_point_animation_merge_options))
	end






end

function AiAnimUtils.reset_animation_merge(unit)
	Unit.set_animation_merge_options(unit)





end

function AiAnimUtils._animation_merge_debug(unit, text)
	local category_name = "animation_merge"
	Managers.state.debug_text:clear_unit_text(unit, category_name)

	if text then
		local head_node = Unit.node(unit, "c_head")
		local viewport_name = "player_1"
		local color_vector = Vector3(25, 255, 25)
		local offset_vector = Vector3(0, 0, 1)
		local text_size = 0.5
		Managers.state.debug_text:output_unit_text(text, text_size, unit, head_node, offset_vector, nil, category_name, color_vector, viewport_name)
	end
end

local VEL_TO_NETWORK_SCALE = 10
local VEL_FROM_NETWORK_SCALE = 0.1
function AiAnimUtils.velocity_network_scale(velocity, is_sending)
	if is_sending then
		velocity = velocity * VEL_TO_NETWORK_SCALE
		local result = { math.round(velocity.x), math.round(velocity.y), math.round(velocity.z) }
		do return result end
	else
		local result = Vector3(velocity [1] * VEL_FROM_NETWORK_SCALE, velocity [2] * VEL_FROM_NETWORK_SCALE, velocity [3] * VEL_FROM_NETWORK_SCALE)
		return result
	end
end

local POS_TO_NETWORK_SCALE = 100
local POS_FROM_NETWORK_SCALE = 0.01
function AiAnimUtils.position_network_scale(position, is_sending)
	if is_sending then
		position = position * POS_TO_NETWORK_SCALE
		local result = { math.round(position.x), math.round(position.y), math.round(position.z) }
		do return result end
	else
		local result = Vector3(position [1] * POS_FROM_NETWORK_SCALE, position [2] * POS_FROM_NETWORK_SCALE, position [3] * POS_FROM_NETWORK_SCALE)
		return result
	end
end

local ROT_TO_NETWORK_SCALE = 100
local ROT_FROM_NETWORK_SCALE = 0.01
function AiAnimUtils.rotation_network_scale(rotation, is_sending)
	if is_sending then
		local x, y, z, w = Quaternion.to_elements(rotation)
		local result = { math.round(x * ROT_TO_NETWORK_SCALE), math.round(y * ROT_TO_NETWORK_SCALE), math.round(z * ROT_TO_NETWORK_SCALE), math.round(w * ROT_TO_NETWORK_SCALE) }
		do return result end
	else
		local result = Quaternion.from_elements(rotation [1] * ROT_FROM_NETWORK_SCALE, rotation [2] * ROT_FROM_NETWORK_SCALE, rotation [3] * ROT_FROM_NETWORK_SCALE, rotation [4] * ROT_FROM_NETWORK_SCALE)
		return result
	end
end

function AiAnimUtils.cycle_anims(blackboard, anims, blackboard_index_name)
	local num_anims = #anims
	local i = blackboard [blackboard_index_name] % num_anims + 1
	local anim_name = anims [i]
	blackboard [blackboard_index_name] = i
	return anim_name
end