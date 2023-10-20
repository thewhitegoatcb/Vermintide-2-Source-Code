require("foundation/scripts/util/api_verification")
require("scripts/managers/blood/blood_manager")

BloodManagerDummy = class(BloodManagerDummy)

function BloodManagerDummy:init(world)
	return end

function BloodManagerDummy:update(dt, t)
	return end

function BloodManagerDummy:get_blood_enabled()
	return end

function BloodManagerDummy:despawn_blood_ball(unit)
	return end

function BloodManagerDummy:clear_blood_decals()
	return end

function BloodManagerDummy:clear_unit_decals(unit)
	return end

function BloodManagerDummy:clear_weapon_blood(attacker, weapon)
	return end

function BloodManagerDummy:add_blood_ball(position, direction, damage_type, hit_unit)
	return end

function BloodManagerDummy:add_weapon_blood(attacker, damage_type)
	return end

function BloodManagerDummy:add_enemy_blood(position, normal, actor)
	return end

function BloodManagerDummy:play_screen_space_blood(particle_name, position, optional_offset, option_rotation_offset, optional_scale)
	return end

function BloodManagerDummy:destroy()
	return end

function BloodManagerDummy:update_blood_enabled(blood_enabled)
	return end
function BloodManagerDummy:update_num_blood_decals(num_blood_decals)
	return end
function BloodManagerDummy:update_screen_blood_enabled(screen_blood_enabled)
	return end
function BloodManagerDummy:update_dismemberment_enabled(dismemberment_enabled)
	return end
function BloodManagerDummy:update_ragdoll_enabled(ragdoll_enabled)
	return end


ApiVerification.ensure_public_api(BloodManager, BloodManagerDummy)