


local push_radius = 2

local weapon_template = {

	actions = {
		action_one = {
			default = { anim_end_event = "attack_finished", kind = "throw", velocity_multiplier = 0.5, throw_time = 0.35, ammo_usage = 1, weapon_action_hand = "left", block_pickup = true, speed = 2.5, uninterruptible = true, anim_event = "attack_throw", total_time = 0.7,


				anim_end_event_condition_func = function (unit, end_reason)
					return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
				end,



				buff_data = {
					{ start_time = 0, external_multiplier = 0.5, end_time = 0.35, buff_name = "planted_fast_decrease_movement" } },









				allowed_chain_actions = { },




				angular_velocity = { 0, 200, -500 },
				throw_offset = { 0.3, 1, 0.3 },

				projectile_info = { use_dynamic_collision = false, collision_filter = "n/a", projectile_unit_template_name = "pickup_projectile_unit", pickup_name = "grain_sack", drop_on_player_destroyed = true, projectile_unit_name = "units/weapons/player/pup_sacks/pup_sacks_01" } } },












		action_two = {
			default = { damage_window_start = 0.05, anim_end_event = "attack_finished", outer_push_angle = 180, kind = "push_stagger", damage_profile_outer = "light_push", attack_template = "basic_sweep_push", push_angle = 100, hit_effect = "melee_hit_slashing", damage_window_end = 0.2, charge_value = "action_push", weapon_action_hand = "left", anim_event = "attack_push", damage_profile_inner = "medium_push", total_time = 0.8,


				anim_end_event_condition_func = function (unit, end_reason)
					return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
				end,


				allowed_chain_actions = { { sub_action = "default", start_time = 0.4, action = "action_one", end_time = 0.7, input = "action_one" } },


				push_radius = push_radius,












				condition_func = function (attacker_unit, input_extension)
					local status_extension = ScriptUnit.extension(attacker_unit, "status_system")

					return not status_extension:fatigued()
				end } },



		action_dropped = {
			default = { anim_end_event = "attack_finished", kind = "throw", velocity_multiplier = 0.5, throw_time = 0.35, ammo_usage = 1, weapon_action_hand = "left", block_pickup = true, speed = 2.5, uninterruptible = true, anim_event = "attack_throw", total_time = 0.7,


				anim_end_event_condition_func = function (unit, end_reason)
					return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
				end,



				buff_data = {
					{ start_time = 0, external_multiplier = 0.5, end_time = 0.35, buff_name = "planted_fast_decrease_movement" } },









				allowed_chain_actions = { },




				angular_velocity = { 0, 200, -500 },
				throw_offset = { 0.3, 1, 0.3 },

				projectile_info = { use_dynamic_collision = false, collision_filter = "n/a", projectile_unit_template_name = "pickup_projectile_unit", pickup_name = "grain_sack", drop_on_player_destroyed = true, projectile_unit_name = "units/weapons/player/pup_sacks/pup_sacks_01" } } },












		action_wield = ActionTemplates.wield_left },

	ammo_data = { ammo_hand = "left", destroy_when_out_of_ammo = true, max_ammo = 1, ammo_per_clip = 1, reload_time = 0 },






	pickup_data = { pickup_name = "grain_sack" },


	left_hand_unit = "units/weapons/player/wpn_sacks/wpn_sacks_01",
	left_hand_attachment_node_linking = AttachmentNodeLinking.sack,
	wield_anim = "to_sack",
	state_machine = "units/beings/player/first_person_base/state_machines/common",
	load_state_machine = false,
	block_wielding = true,
	max_fatigue_points = 3,
	dodge_count = 1,
	buffs = {
		sack_decrease_movement = { variable_value = 1 },
		change_dodge_distance = { external_optional_multiplier = 0.65 },
		change_dodge_speed = { external_optional_multiplier = 0.45 } } }








local sack = table.clone(weapon_template)
sack.actions.action_one.default.projectile_info.projectile_unit_name = "units/weapons/player/pup_sacks/pup_sacks_01"
sack.left_hand_unit = "units/weapons/player/wpn_sacks/wpn_sacks_01"
sack.wield_anim = "to_sack"

return { sack = sack }