CurseCorruptorBeamExtension = class(CurseCorruptorBeamExtension, CorruptorBeamExtension)

function CurseCorruptorBeamExtension:_get_positions(dt, self_pos, real_target_position)
	return real_target_position, real_target_position
end