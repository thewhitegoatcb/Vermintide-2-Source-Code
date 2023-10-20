require("scripts/unit_extensions/generic/death_reactions")

GenericDeathExtension = class(GenericDeathExtension)

function GenericDeathExtension:init(extension_init_context, unit, extension_init_data)
	self.network_type = extension_init_data.is_husk


	local is_husk = extension_init_data.is_husk or not Managers.player.is_server
	self.is_husk = is_husk
	self.network_type = is_husk and "husk" or "unit"

	self.is_alive = true
	self.unit = unit
	self.extension_init_data = extension_init_data

	self.wall_nail_data = { }
	self.second_hit_ragdoll = not extension_init_data.disable_second_hit_ragdoll
end

function GenericDeathExtension:freeze()
	self.play_effect = nil
	self.despawn_after_time = nil
end

function GenericDeathExtension:override_death_behavior(despawn_after_time, play_effect)
	self.despawn_after_time = despawn_after_time
	self.play_effect = play_effect
end

function GenericDeathExtension:force_end()
	if not self.death_is_done and Unit.alive(self.unit) and not self.is_alive then
		Managers.state.unit_spawner:mark_for_deletion(self.unit)
		self.death_is_done = true
	end
end

function GenericDeathExtension:is_wall_nailed()
	return next(self.wall_nail_data) and true or false
end

function GenericDeathExtension:nailing_hit(hit_ragdoll_actor, attack_direction, hit_speed)
	fassert(Vector3.is_valid(attack_direction), "Attack direction is not valid.")
	local data = self.wall_nail_data
	data [hit_ragdoll_actor] = data [hit_ragdoll_actor] or { attack_direction = Vector3Box(attack_direction), hit_speed = hit_speed }
end

function GenericDeathExtension:enable_second_hit_ragdoll()
	self.second_hit_ragdoll = true
end

function GenericDeathExtension:second_hit_ragdoll_allowed()
	return self.second_hit_ragdoll
end

function GenericDeathExtension:has_death_started()
	return self.death_has_started
end