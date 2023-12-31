



local weapon_template = {
	actions = {
		action_career_hold = {
			default = { anim_end_event = "ability_finished", block_pickup = true, kind = "career_dummy", uninterruptible = true, anim_event = "veteran_ranger_ability_grenade",




				anim_end_event_condition_func = function (unit, end_reason)
					return end_reason ~= "new_interupting_action"
				end,

				total_time = math.huge,


				allowed_chain_actions = { { sub_action = "default", start_time = 0, action = "action_two", input = "action_two" },
					{ sub_action = "default", start_time = 0, action = "action_two", input = "weapon_reload" },
					{ sub_action = "default", start_time = 0.3, action = "action_career_release", input = "action_career_release" },
					{ sub_action = "default", start_time = 0.3, action = "action_career_release", input = "action_career_not_hold" },
					{ sub_action = "hold", start_time = 0.72, action = "action_career_hold", auto_chain = true } } },



			hold = { anim_end_event = "ability_finished", block_pickup = true, kind = "career_dummy", uninterruptible = true, anim_event = "veteran_ranger_ability_grenade_hold",




				anim_end_event_condition_func = function (unit, end_reason)
					return end_reason ~= "new_interupting_action"
				end,

				total_time = math.huge,


				allowed_chain_actions = { { sub_action = "default", start_time = 0, action = "action_two", input = "action_two" },
					{ sub_action = "default", start_time = 0, action = "action_two", input = "weapon_reload" },
					{ sub_action = "default", start_time = 0, action = "action_career_release", input = "action_career_release" },
					{ sub_action = "default", start_time = 0, action = "action_career_release", input = "action_career_not_hold" } } } },




		action_career_release = {
			default = { block_pickup = true, throw_time = 0.16, anim_end_event = "ability_finished", kind = "career_dr_three", uninterruptible = true, anim_event = "veteran_ranger_ability_grenade_throw", total_time = 0.25,




				anim_end_event_condition_func = function (unit, end_reason)
					return end_reason ~= "new_interupting_action"
				end,





				allowed_chain_actions = { } } },


		action_two = {
			default = { kind = "career_dummy", anim_end_event = "ability_finished", anim_event = "veteran_ranger_ability_grenade_cancel", total_time = 0.67,


				anim_end_event_condition_func = function (unit, end_reason)
					return end_reason ~= "new_interupting_action"
				end,


				allowed_chain_actions = { } } },


		action_inspect = ActionTemplates.action_inspect_right,
		action_wield = ActionTemplates.wield_right },


	right_hand_unit = "units/weapons/player/wpn_emp_grenade_02_t2/wpn_emp_grenade_02_t2",

	right_hand_attachment_node_linking = AttachmentNodeLinking.one_handed_melee_weapon.right,
	left_hand_unit = "units/weapons/player/wpn_emp_grenade_01_t1/wpn_emp_grenade_lighter_01_t1",
	left_hand_attachment_node_linking = AttachmentNodeLinking.one_handed_melee_weapon.left,
	wield_anim = "to_grenade",
	state_machine = "units/beings/player/first_person_base/state_machines/career/skill_ranger",
	load_state_machine = false,
	gui_texture = "hud_consumable_icon_grenade",
	crosshair_style = "default",
	max_fatigue_points = 4,
	dodge_count = 3,
	can_give_other = true,
	buffs = {
		change_dodge_distance = { external_optional_multiplier = 1 },
		change_dodge_speed = { external_optional_multiplier = 1 } } }


return { bardin_ranger_career_skill_weapon = table.clone(weapon_template) }