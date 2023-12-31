BTConditions = BTConditions or { }

require("scripts/entity_system/systems/behaviour/nodes/bot/bt_bot_conditions")

local unit_alive = Unit.alive
local ScriptUnit = ScriptUnit

function BTConditions.always_true(blackboard)
	return true
end

function BTConditions.always_false(blackboard)
	return false
end



function BTConditions.spawn(blackboard)
	return blackboard.spawn
end

function BTConditions.blocked(blackboard)
	return blackboard.blocked
end


function BTConditions.start_or_continue(blackboard)
	return blackboard.attack_token == nil or blackboard.attack_token
end


function BTConditions.ask_target_before_attacking(blackboard, condition_args, action)
	if blackboard.attack_token then
		return blackboard.attack_token
	end

	local want_an_attack = true

	local target_unit = blackboard.target_unit
	local target_unit_attack_intensity_extension = ScriptUnit.has_extension(target_unit, "attack_intensity_system")

	if target_unit_attack_intensity_extension then





		local attack_type = action.attack_intensity_type or "normal"
		want_an_attack = target_unit_attack_intensity_extension:want_an_attack(attack_type)
	end

	return want_an_attack
end

function BTConditions.first_shots_fired(blackboard)
	return blackboard.first_shots_fired
end

function BTConditions.stagger(blackboard)
	if blackboard.stagger then
		if blackboard.stagger_prohibited then
			blackboard.stagger = false
		else
			return true
		end
	end
end

function BTConditions.grey_seer_stagger(blackboard)
	if blackboard.stagger then
		if blackboard.stagger_prohibited then
			blackboard.stagger = false
		else
			return not blackboard.about_to_mount
		end
	end
end

function BTConditions.reset_attack(blackboard)
	return blackboard.reset_attack
end

function BTConditions.lord_intro(blackboard)
	local t = Managers.time:time("game")

	return blackboard.intro_timer and t < blackboard.intro_timer
end

function BTConditions.warlord_jump_down(blackboard)
	return blackboard.jump_from_pos
end

function BTConditions.quick_teleport(blackboard)
	return blackboard.quick_teleport
end

function BTConditions.fling_skaven(blackboard)
	return blackboard.fling_skaven
end

function BTConditions.secondary_target(blackboard)
	return blackboard.secondary_target
end

function BTConditions.quick_jump(blackboard)
	return blackboard.high_ground_opportunity
end

function BTConditions.ninja_vanish(blackboard)
	return blackboard.ninja_vanish
end

function BTConditions.target_changed(blackboard)
	return blackboard.target_changed
end

function BTConditions.victim_grabbed(blackboard)
	return blackboard.has_grabbed_victim
end

function BTConditions.nurgling_spawned_by_altar(blackboard)
	return blackboard.nurgling_spawned_by_altar
end

function BTConditions.target_changed_and_distant(blackboard)
	if blackboard.target_changed then
		if blackboard.previous_target_unit == nil then
			do return true end
		elseif blackboard.target_dist and blackboard.target_dist > 15 then
			local t = Managers.time:time("game")
			do return blackboard.next_rage_time and blackboard.next_rage_time < t end
		else
			blackboard.target_changed = nil
		end
	end
	return false
end

function BTConditions.stormfiend_boss_rage(blackboard)
	return blackboard.intro_rage
end

function BTConditions.ratogre_target_reachable(blackboard)

	return blackboard.jump_slam_data or not blackboard.target_outside_navmesh or blackboard.target_dist and blackboard.target_dist <= blackboard.breed.reach_distance
end

function BTConditions.chaos_spawn_grabbed_combat(blackboard)
	return HEALTH_ALIVE [blackboard.victim_grabbed] and not AiUtils.unit_knocked_down(blackboard.victim_grabbed) and not blackboard.wants_to_throw
end

function BTConditions.chaos_spawn_grabbed_throw(blackboard)
	local knocked_down = AiUtils.unit_knocked_down(blackboard.victim_grabbed)
	return HEALTH_ALIVE [blackboard.victim_grabbed] and (knocked_down or blackboard.wants_to_throw)
end

function BTConditions.path_found(blackboard)
	return not blackboard.no_path_found
end

function BTConditions.ratogre_jump_dist(blackboard)
	return not blackboard.target_outside_navmesh and blackboard.target_dist and blackboard.target_dist <= 15
end

function BTConditions.ratogre_walking(blackboard)
	return blackboard.ratogre_walking
end

function BTConditions.escorting_rat_ogre(blackboard)
	return blackboard.escorting_rat_ogre
end

function BTConditions.in_vortex(blackboard)
	return blackboard.in_vortex
end

function BTConditions.in_gravity_well(blackboard)
	return blackboard.gravity_well_position
end

function BTConditions.at_smartobject(blackboard)
	local next_smart_object_data = blackboard.next_smart_object_data
	local smartobject_is_next = next_smart_object_data.next_smart_object_id ~= nil
	if not smartobject_is_next then
		return false
	end

	local is_smart_objecting = blackboard.is_smart_objecting
	local nav_graph_system = Managers.state.entity:system("nav_graph_system")
	local smart_object_unit = next_smart_object_data.smart_object_data and next_smart_object_data.smart_object_data.unit
	local has_nav_graph_extension, nav_graph_enabled = nav_graph_system:has_nav_graph(smart_object_unit)
	if has_nav_graph_extension and not nav_graph_enabled and not is_smart_objecting then
		return false
	end

	local is_in_smartobject_range = blackboard.is_in_smartobject_range
	local moving_state = blackboard.move_state == "moving"
	return is_in_smartobject_range and moving_state or is_smart_objecting
end

function BTConditions.gutter_runner_at_smartobject(blackboard)
	if blackboard.jump_data then
		return false
	end

	return BTConditions.at_smartobject(blackboard)
end

function BTConditions.ratogre_at_smartobject(blackboard)
	if blackboard.keep_target then
		return false
	end
	return BTConditions.at_smartobject(blackboard)
end

function BTConditions.stormfiend_boss_intro_jump_down(blackboard)
	local is_in_intro = blackboard.jump_down_intro
	return BTConditions.at_smartobject(blackboard) and is_in_intro
end


function BTConditions.at_teleport_smartobject(blackboard)
	local smart_object_type = blackboard.next_smart_object_data.smart_object_type
	local is_smart_object_teleporter = smart_object_type == "teleporters"
	local is_teleporting = blackboard.is_teleporting
	return is_smart_object_teleporter or is_teleporting
end

function BTConditions.vortex_at_climb_or_jump(blackboard)
	local at_climb = BTConditions.at_climb_smartobject(blackboard)
	local at_jump = BTConditions.at_jump_smartobject(blackboard)
	return at_climb or at_jump or blackboard.is_flying
end

function BTConditions.at_climb_smartobject(blackboard)
	local smart_object_type = blackboard.next_smart_object_data.smart_object_type
	local is_smart_object_ledge = smart_object_type == "ledges" or smart_object_type == "ledges_with_fence"
	local is_climbing = blackboard.is_climbing
	return is_smart_object_ledge or is_climbing
end

function BTConditions.at_jump_smartobject(blackboard)
	local is_smart_object_jump = blackboard.next_smart_object_data.smart_object_type == "jumps"
	local is_jumping = blackboard.is_jumping
	return is_smart_object_jump or is_jumping
end

function BTConditions.at_door_smartobject(blackboard)
	local smart_object_type = blackboard.next_smart_object_data.smart_object_type
	local is_smart_object_door = smart_object_type == "doors" or smart_object_type == "planks" or smart_object_type == "big_boy_destructible" or smart_object_type == "destructible_wall"
	local is_smashing_door = blackboard.is_smashing_door
	local is_scurrying_under_door = blackboard.is_scurrying_under_door
	return is_smart_object_door or is_smashing_door or is_scurrying_under_door
end

function BTConditions.at_smart_object_and_door(blackboard)
	return BTConditions.at_smartobject(blackboard) and BTConditions.at_door_smartobject(blackboard)
end

function BTConditions.has_destructible_as_target(blackboard)
	local target = blackboard.target_unit
	local is_destructible_static = not ScriptUnit.has_extension(target, "locomotion_system")
	return unit_alive(target) and blackboard.confirmed_player_sighting and is_destructible_static
end

function BTConditions.can_see_player(blackboard)
	return unit_alive(blackboard.target_unit)
end

function BTConditions.has_target(blackboard)
	return unit_alive(blackboard.target_unit)
end

function BTConditions.no_target(blackboard)
	return not unit_alive(blackboard.target_unit)
end

function BTConditions.tentacle_found_target(blackboard)
	return unit_alive(blackboard.target_unit) and not blackboard.tentacle_satisfied
end

function BTConditions.at_half_health(blackboard)
	return blackboard.current_health_percent <= 0.5
end

function BTConditions.at_one_third_health(blackboard)
	return blackboard.current_health_percent <= 0.33
end

function BTConditions.at_two_thirds_health(blackboard)
	return blackboard.current_health_percent <= 0.66
end

function BTConditions.at_one_fifth_health(blackboard)
	return blackboard.current_health_percent <= 0.2
end

function BTConditions.at_three_fifths_health(blackboard)
	return blackboard.current_health_percent <= 0.6
end

function BTConditions.less_than_one_health(blackboard)
	return blackboard.current_health <= 1
end
function BTConditions.can_transition_half_health(blackboard)
	return blackboard.current_health_percent <= 0.5 and not blackboard.half_transition_done
end

function BTConditions.can_transition_one_third_health(blackboard)
	return blackboard.current_health_percent <= 0.33 and not blackboard.one_third_transition_done
end

function BTConditions.dummy_not_escaped(blackboard)
	return not blackboard.anim_cb_escape_finished
end

function BTConditions.can_transition_two_thirds_health(blackboard)
	return blackboard.current_health_percent <= 0.66 and not blackboard.two_thirds_transition_done
end

function BTConditions.can_transition_one_fifth_health(blackboard)
	return blackboard.current_health_percent <= 0.2 and not blackboard.one_fifth_transition_done
end

function BTConditions.can_transition_three_fifths_health(blackboard)
	return blackboard.current_health_percent <= 0.6 and not blackboard.three_fifths_transition_done
end

function BTConditions.transitioned_half_health(blackboard)
	return blackboard.current_health_percent <= 0.5 and blackboard.half_transition_done
end

function BTConditions.transitioned_three_fifths_health(blackboard)
	return blackboard.current_health_percent <= 0.6 and blackboard.three_fifths_transition_done
end

function BTConditions.transitioned_one_fifth_health(blackboard)
	return blackboard.current_health_percent <= 0.2 and blackboard.one_fifth_transition_done
end

function BTConditions.transitioned_one_third_health(blackboard)
	return blackboard.current_health_percent <= 0.33 and blackboard.one_third_transition_done
end

function BTConditions.transitioned_two_thirds_health(blackboard)
	return blackboard.current_health_percent <= 0.66 and blackboard.two_thirds_transition_done
end

function BTConditions.sorcerer_allow_tricke_spawn(blackboard)
	return blackboard.sorcerer_allow_tricke_spawn
end

function BTConditions.spawned_allies_dead_or_time(blackboard)
	return blackboard.spawn_allies_horde and blackboard.spawn_allies_horde.is_dead or blackboard.defensive_phase_duration == 0
end

function BTConditions.first_ring_summon(blackboard)
	return blackboard.ring_summonings_finished == 0
end

function BTConditions.ready_to_summon_rings(blackboard)
	return blackboard.ring_cooldown == 0
end

function BTConditions.ready_to_charge(blackboard)
	return blackboard.charge_cooldown == 0
end

function BTConditions.ready_to_teleport(blackboard)
	return blackboard.teleport_cooldown == 0
end

function BTConditions.ready_to_summon_wave(blackboard)
	return blackboard.wave_cooldown == 0
end

function BTConditions.not_ready_to_summon_wave(blackboard)
	return not blackboard.ready_to_summon or not blackboard.summoning and not Unit.alive(blackboard.target_unit) or blackboard.wave_cooldown ~= 0
end


function BTConditions.ready_to_summon(blackboard)
	return blackboard.ready_to_summon and (blackboard.summoning or Unit.alive(blackboard.target_unit))
end

function BTConditions.ready_to_summon_vortex(blackboard)
	return blackboard.current_spell_name == "vortex"
end

function BTConditions.ready_to_summon_plague_wave(blackboard)
	return blackboard.current_spell_name == "plague_wave"
end

function BTConditions.ready_to_summon_tentacle(blackboard)
	return blackboard.current_spell_name == "tentacle"
end

function BTConditions.ready_to_cast_missile(blackboard)
	return blackboard.current_spell_name == "magic_missile"
end

function BTConditions.ready_to_cast_seeking_bomb_missile(blackboard)
	return blackboard.current_spell_name == "seeking_bomb_missile"
end

function BTConditions.sorcerer_in_defensive_mode(blackboard)
	return blackboard.mode == "defensive" and not blackboard.is_summoning
end

function BTConditions.sorcerer_in_setup_mode(blackboard)
	return blackboard.mode == "setup" and not blackboard.setup_done
end

function BTConditions.escape_teleport(blackboard)
	return blackboard.escape_teleport
end

function BTConditions.defensive_mode_starts(blackboard)
	return blackboard.phase == "defensive_starts"
end

function BTConditions.sorcerer_defensive_combat(blackboard)
	return blackboard.phase == "defensive_combat"
end

function BTConditions.defensive_mode_ends(blackboard)
	return blackboard.phase == "defensive_ends"
end


function BTConditions.ready_to_explode(blackboard)
	return blackboard.ready_to_summon
end

function BTConditions.player_spotted(blackboard)
	return unit_alive(blackboard.target_unit) and not blackboard.confirmed_player_sighting
end

function BTConditions.in_melee_range(blackboard)
	return unit_alive(blackboard.target_unit) and blackboard.in_melee_range
end

function BTConditions.approach_target(blackboard)
	return blackboard.approach_target
end

function BTConditions.comitted_to_target(blackboard)
	local t = Managers.time:time("game")
	local pounce_timer_is_finished = blackboard.initial_pounce_timer < t

	return ( blackboard.target_unit or blackboard.comitted_to_target ) and pounce_timer_is_finished
end

function BTConditions.in_sprint_dist(blackboard)
	return blackboard.closing or blackboard.target_dist > 7
end

function BTConditions.in_run_dist(blackboard)
	return blackboard.target_dist <= 7 or blackboard.movement_inited and blackboard.target_dist <= 8
end

function BTConditions.troll_downed(blackboard)
	return blackboard.can_get_downed and blackboard.downed_state
end

function BTConditions.needs_to_crouch(blackboard)
	return blackboard.needs_to_crouch and BTConditions.ratogre_target_reachable(blackboard)
end

function BTConditions.reset_utility(blackboard)
	return not blackboard.reset_utility
end

function BTConditions.is_alerted(blackboard)
	local alerted = unit_alive(blackboard.target_unit) and blackboard.is_alerted and (not blackboard.confirmed_player_sighting or blackboard.hesitating)
	local is_taunted = unit_alive(blackboard.taunt_unit)
	local taunt_hesitate = is_taunted and not blackboard.taunt_hesitate_finished and not blackboard.no_taunt_hesitate
	return alerted or taunt_hesitate
end

function BTConditions.confirmed_player_sighting(blackboard)
	return unit_alive(blackboard.target_unit) and blackboard.confirmed_player_sighting
end


function BTConditions.commander_disabled_or_resuming(blackboard)
	return ALIVE [blackboard.commander_unit] and ScriptUnit.extension(blackboard.commander_unit, "status_system"):is_disabled() or blackboard.disabled_resume_time and Managers.time:time("game") < blackboard.disabled_resume_time
end

function BTConditions.commander_disabled(blackboard)
	return ALIVE [blackboard.commander_unit] and ScriptUnit.extension(blackboard.commander_unit, "status_system"):is_disabled()
end

function BTConditions.has_commander_and_follow_node(blackboard)
	local commander_unit = Managers.state.entity:system("ai_commander_system"):get_commander_unit(blackboard.unit)
	return commander_unit and blackboard.is_navbot_following_path
end

function BTConditions.confirmed_enemy_sighting_within_commander(blackboard)
	return unit_alive(blackboard.target_unit) and
	blackboard.dist_to_commander and
	blackboard.target_dist + blackboard.dist_to_commander < blackboard.max_combat_range
end

function BTConditions.confirmed_enemy_sighting_within_commander_sticky(blackboard)
	return ALIVE [blackboard.target_unit] and blackboard.confirmed_enemy_sighting_within_commander or blackboard.attack_locked_in_t
end

function BTConditions.should_teleport_to_commander(blackboard)
	local controlled_unit = blackboard.unit
	local commander_unit = Managers.state.entity:system("ai_commander_system"):get_commander_unit(controlled_unit)
	if commander_unit then
		local max_commander_distance = blackboard.breed.max_commander_distance
		if max_commander_distance then
			local commander_position = POSITION_LOOKUP [commander_unit]
			local self_position = POSITION_LOOKUP [controlled_unit]
			local distance_sq = Vector3.distance_squared(commander_position, self_position)
			if distance_sq > max_commander_distance * max_commander_distance then
				return true
			end
		end
	end

	return false
end

function BTConditions.has_command_attack(blackboard)
	return blackboard.new_command_attack and (ALIVE [blackboard.target_unit] or blackboard.attack_locked_in_t)
end

function BTConditions.pet_skeleton_is_armored(blackboard)
	return blackboard.breed.name == "pet_skeleton_armored"
end

function BTConditions.pet_skeleton_is_dual_wield(blackboard)
	return blackboard.breed.name == "pet_skeleton_dual_wield"
end

function BTConditions.pet_skeleton_has_shield(blackboard)
	return blackboard.breed.name == "pet_skeleton_with_shield"
end

function BTConditions.pet_skeleton_default(blackboard)
	return blackboard.breed.name == "pet_skeleton"
end

function BTConditions.has_charge_target(blackboard)
	return blackboard.charge_target
end

function BTConditions.wants_stand_ground(blackboard)
	return blackboard.command_state == CommandStates.StandingGround
end

function BTConditions.necromancer_not_exploded(blackboard)
	return not blackboard.explosion_triggered
end


function BTConditions.suiciding_whilst_staggering(blackboard)
	return blackboard.stagger and blackboard.suicide_run ~= nil and blackboard.suicide_run.explosion_started
end

function BTConditions.has_goal_destination(blackboard)
	return blackboard.goal_destination ~= nil
end

function BTConditions.should_mount_unit(blackboard)
	return blackboard.should_mount_unit ~= nil
end

function BTConditions.is_falling(blackboard)
	return blackboard.is_falling or blackboard.fall_state ~= nil
end

function BTConditions.is_gutter_runner_falling(blackboard)

	return not blackboard.high_ground_opportunity and not blackboard.pouncing_target and (blackboard.is_falling or blackboard.fall_state ~= nil)
end

function BTConditions.pack_master_needs_hook(blackboard)
	return blackboard.needs_hook
end

function BTConditions.look_for_players(blackboard)
	return blackboard.look_for_players
end

function BTConditions.suicide_run(blackboard)
	return blackboard.current_health_percent < 0.7
end

function BTConditions.should_use_interest_point(blackboard)
	return not blackboard.ignore_interest_points and not blackboard.confirmed_player_sighting
end

function BTConditions.give_command(blackboard)
	return blackboard.give_command and unit_alive(blackboard.target_unit) and blackboard.confirmed_player_sighting
end

function BTConditions.is_fleeing(blackboard)
	return unit_alive(blackboard.target_unit) or blackboard.is_fleeing
end

function BTConditions.loot_rat_stagger(blackboard)
	return BTConditions.stagger(blackboard) and not blackboard.dodge_damage_success
end

function BTConditions.loot_rat_dodge(blackboard)


	return blackboard.dodge_vector or blackboard.is_dodging
end

function BTConditions.loot_rat_flee(blackboard)
	return BTConditions.confirmed_player_sighting(blackboard) or blackboard.is_fleeing
end

function BTConditions.defend(blackboard)
	return blackboard.defend
end

function BTConditions.defend_get_in_position(blackboard)
	return blackboard.defend_get_in_position
end

function BTConditions.can_trigger_move_to(blackboard)
	local t = Managers.time:time("game")
	local trigger_time = blackboard.trigger_time or 0
	return t > trigger_time and unit_alive(blackboard.target_unit)
end

function BTConditions.globadier_skulked_for_too_long(blackboard)
	local adv_data = blackboard.advance_towards_players
	local skulk_timeout = 15
	if adv_data then
		local t = Managers.time:time("game")
		local throw_globe_data = blackboard.throw_globe_data
		if throw_globe_data and throw_globe_data.next_throw_at then
			do return t > throw_globe_data.next_throw_at + skulk_timeout end
		else
			return adv_data.timer > adv_data.time_until_first_throw + skulk_timeout
		end
	end
	return false
end

function BTConditions.ratling_gunner_skulked_for_too_long(blackboard)
	if unit_alive(blackboard.target_unit) then

		local skulk_timeout = 15

		local pattern_data = blackboard.attack_pattern_data
		local last_fired = pattern_data and pattern_data.last_fired
		local t = Managers.time:time("game")
		local lurk_start = blackboard.lurk_start
		if last_fired then
			do return t > last_fired + skulk_timeout end
		elseif lurk_start then
			return t > lurk_start + skulk_timeout
		end
	end

	return false
end

function BTConditions.should_defensive_idle(blackboard)
	local t = Managers.time:time("game")
	local time_since_surrounding_players = t - blackboard.surrounding_players_last
	return blackboard.defensive_mode_duration and time_since_surrounding_players >= 3
end

function BTConditions.should_be_defensive(blackboard)
	return blackboard.defensive_mode_duration and unit_alive(blackboard.target_unit)
end

function BTConditions.boss_phase_two(blackboard)
	return blackboard.current_phase == 2
end

function BTConditions.warlord_dual_wielding(blackboard)
	return blackboard.dual_wield_mode
end

function BTConditions.warlord_halberding(blackboard)
	return not blackboard.dual_wield_mode
end


function BTConditions.switching_weapons(blackboard)
	return blackboard.switching_weapons and not blackboard.defensive_mode_duration
end

function BTConditions.warcamp_retaliation_aoe(blackboard)
	return Unit.alive(blackboard.target_unit) and blackboard.num_chain_stagger and blackboard.num_chain_stagger > 2
end



function BTConditions.is_mounted(blackboard)
	local mount_unit = blackboard.mounted_data.mount_unit
	return not blackboard.knocked_off_mount and HEALTH_ALIVE [mount_unit]
end

function BTConditions.knocked_off_mount(blackboard)
	return ( blackboard.knocked_off_mount or not HEALTH_ALIVE [blackboard.mounted_data.mount_unit] ) and HEALTH_ALIVE [blackboard.target_unit]
end

function BTConditions.ready_to_cast_spell(blackboard)
	return blackboard.ready_to_summon and not blackboard.about_to_mount and HEALTH_ALIVE [blackboard.target_unit]
end

function BTConditions.grey_seer_teleport_spell(blackboard)
	return blackboard.current_spell_name == "teleport" and blackboard.quick_teleport
end

function BTConditions.grey_seer_vermintide_spell(blackboard)
	return blackboard.current_spell_name == "vermintide"
end

function BTConditions.grey_seer_warp_lightning_spell(blackboard)
	return blackboard.current_spell_name == "warp_lightning"
end

function BTConditions.grey_seer_waiting_death(blackboard)
	return blackboard.current_phase == 6
end

function BTConditions.grey_seer_death(blackboard)
	return blackboard.current_phase == 5
end

function BTConditions.grey_seer_call_stormfiend(blackboard)
	return blackboard.call_stormfiend
end

function BTConditions.grey_seer_waiting_for_pickup(blackboard)
	return blackboard.waiting_for_pickup
end

function BTConditions.should_use_emote(blackboard)
	return blackboard.should_use_emote
end

function BTConditions.should_wait_idle(blackboard)
	if blackboard.idle_time then
		local t = Managers.time:time("game")
		local time_spent_in_idle = t - blackboard.idle_time
		do return time_spent_in_idle >= 3 end
	else
		return false
	end
end

function BTConditions.beastmen_standard_bearer_place_standard(blackboard)
	return unit_alive(blackboard.target_unit) and not blackboard.has_placed_standard
end

function BTConditions.beastmen_standard_bearer_pickup_standard(blackboard)
	if blackboard.ignore_standard_pickup then
		return false
	end

	local target_distance_to_standard = blackboard.target_distance_to_standard

	if blackboard.moving_to_pick_up_standard then
		do return true end
	else
		return blackboard.has_placed_standard and unit_alive(blackboard.target_unit) and HEALTH_ALIVE [blackboard.standard_unit] and target_distance_to_standard and blackboard.breed.pickup_standard_distance < target_distance_to_standard
	end
end


function BTConditions.beastmen_standard_bearer_move_and_place_standard(blackboard)
	local has_move_and_place_standard_position = blackboard.move_and_place_standard
	return has_move_and_place_standard_position
end

function BTConditions.ungor_archer_enter_melee_combat(blackboard)
	return blackboard.confirmed_player_sighting and unit_alive(blackboard.target_unit) and (blackboard.has_switched_weapons or blackboard.target_dist and blackboard.target_dist < 5)
end

function BTConditions.bestigor_at_smartobject(blackboard)
	local in_charge_action = blackboard.charge_state ~= nil
	local at_smartobject = not in_charge_action and BTConditions.at_smartobject(blackboard)
	return at_smartobject
end

function BTConditions.confirmed_player_sighting_standard_bearer(blackboard)
	return unit_alive(blackboard.target_unit) and blackboard.confirmed_player_sighting and blackboard.has_placed_standard
end

function BTConditions.standard_bearer_should_be_defensive(blackboard)
	local pickup_standard_distance = blackboard.breed.pickup_standard_distance
	local defensive_threshold_distance = blackboard.breed.defensive_threshold_distance

	local in_combat = unit_alive(blackboard.target_unit) and blackboard.confirmed_player_sighting and blackboard.has_placed_standard
	local target_distance_to_standard = blackboard.target_distance_to_standard
	local target_is_within_range = target_distance_to_standard and defensive_threshold_distance <= target_distance_to_standard and target_distance_to_standard <= pickup_standard_distance
	local not_attacking = blackboard.move_state ~= "attacking"
	return in_combat and target_is_within_range and not_attacking
end

function BTConditions.switch_to_melee_weapon(blackboard)
	return BTConditions.ungor_archer_enter_melee_combat(blackboard) and not blackboard.has_switched_weapons
end

function BTConditions.confirmed_player_sighting_and_has_switched_weapons(blackboard)
	return blackboard.confirmed_player_sighting and blackboard.has_switched_weapons
end


function BTConditions.player_controller_is_alive(blackboard)
	return blackboard.player_controller_unit and unit_alive(blackboard.player_controller_unit) and not blackboard.target_is_in_combat
end

function BTConditions.player_controller_is_in_combat(blackboard)
	return blackboard.player_controller_unit and blackboard.target_is_in_combat
end

function BTConditions.is_in_inn(blackboard)
	return blackboard.inn_idle_spots and global_is_inside_inn
end

function BTConditions.has_no_idle_spot(blackboard)
	return not blackboard.has_idle_spot
end

function BTConditions.is_transported(blackboard)
	return blackboard.is_transported
end