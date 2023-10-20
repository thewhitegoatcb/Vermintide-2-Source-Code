


local push_radius = 2.4
local time_mod = 0.85

local weapon_template = { }
weapon_template.actions = {
	action_one = {
		default = { kind = "melee_start", anim_end_event = "attack_finished", anim_event = "attack_swing_charge_right", attack_hold_input = "action_one_hold",


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			total_time = math.huge,


			buff_data = {
				{ start_time = 0, external_multiplier = 0.85, end_time = 0.4, buff_name = "planted_charging_decrease_movement" },






				{ start_time = 0.4, external_multiplier = 1.1, buff_name = "planted_fast_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "light_attack_left", start_time = 0, action = "action_one", end_time = 0.3, input = "action_one_release" },
				{ sub_action = "heavy_attack_left", start_time = 0.45, action = "action_one", force_release_input = "action_one_hold", input = "action_one_release" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0, action = "action_wield", input = "action_wield" },
				{ start_time = 0.3, blocker = true, end_time = 1.5, input = "action_one_hold" },
				{ sub_action = "heavy_attack_left", start_time = 0.6, action = "action_one", auto_chain = true } } },





































		default_left = { kind = "melee_start", anim_end_event = "attack_finished", anim_event = "attack_swing_charge_left",


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			total_time = math.huge,

			buff_data = {
				{ start_time = 0, external_multiplier = 0.85, end_time = 0.4, buff_name = "planted_charging_decrease_movement" },






				{ start_time = 0.4, external_multiplier = 1.1, buff_name = "planted_fast_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "light_attack_right", start_time = 0, action = "action_one", end_time = 0.3, input = "action_one_release" },
				{ sub_action = "heavy_attack_stab", start_time = 0.5, action = "action_one", force_release_input = "action_one_hold", input = "action_one_release" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0, action = "action_wield", input = "action_wield" },
				{ start_time = 0.3, blocker = true, end_time = 1.5, input = "action_one_hold" },
				{ sub_action = "heavy_attack_stab", start_time = 0.6, action = "action_one", auto_chain = true } } },



		default_last_1 = { kind = "melee_start", anim_end_event = "attack_finished", anim_event = "attack_swing_charge_left",


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			total_time = math.huge,

			buff_data = {
				{ start_time = 0, external_multiplier = 0.85, end_time = 0.4, buff_name = "planted_charging_decrease_movement" },






				{ start_time = 0.4, external_multiplier = 1.1, buff_name = "planted_fast_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "light_attack_stab_1", start_time = 0, action = "action_one", end_time = 0.3, input = "action_one_release" },
				{ sub_action = "heavy_attack_stab", start_time = 0.45, action = "action_one", force_release_input = "action_one_hold", input = "action_one_release" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0, action = "action_wield", input = "action_wield" },
				{ start_time = 0.3, blocker = true, end_time = 1.5, input = "action_one_hold" },
				{ sub_action = "heavy_attack_stab", start_time = 0.6, action = "action_one", auto_chain = true } } },



		default_last_2 = { kind = "melee_start", anim_end_event = "attack_finished", anim_event = "attack_swing_charge_left",


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			total_time = math.huge,

			buff_data = {
				{ start_time = 0, external_multiplier = 0.75, buff_name = "planted_charging_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "light_attack_stab_2", start_time = 0, action = "action_one", end_time = 0.3, input = "action_one_release" },
				{ sub_action = "heavy_attack_stab", start_time = 0.45, action = "action_one", force_release_input = "action_one_hold", input = "action_one_release" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0, action = "action_wield", input = "action_wield" },
				{ start_time = 0.3, blocker = true, end_time = 1.5, input = "action_one_hold" },
				{ sub_action = "heavy_attack_stab", start_time = 0.6, action = "action_one", auto_chain = true } } },































		heavy_attack_stab = { damage_window_start = 0.24, push_radius = 3, kind = "sweep", headshot_multiplier = 3, first_person_hit_anim = "hit_right_shake", range_mod = 1.35, sweep_z_offset = 0.1, width_mod = 20, range_mod_add = 0.25, hit_shield_stop_anim = "attack_hit", hit_effect = "melee_hit_sword_1h", damage_window_end = 0.33, impact_sound_event = "stab_hit", use_precision_sweep = true, anim_end_event = "attack_finished", damage_profile = "heavy_slashing_smiter_stab_polearm", additional_critical_strike_chance = 0, no_damage_impact_sound_event = "stab_hit_armour", dedicated_target_range = 2.8, anim_event = "attack_swing_heavy", height_mod = 4, total_time = 1.5,


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,

			anim_time_scale = time_mod * 1.1,






			buff_data = {
				{ start_time = 0, external_multiplier = 1.75, end_time = 0.3, buff_name = "planted_fast_decrease_movement" },






				{ start_time = 0.3, external_multiplier = 0.5, end_time = 0.75, buff_name = "planted_fast_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default", start_time = 0.5, action = "action_one", release_required = "action_one_hold", doubleclick_window = 0, input = "action_one" },
				{ sub_action = "default", start_time = 0.5, action = "action_one", release_required = "action_one_hold", doubleclick_window = 0, input = "action_one_hold" },
				{ sub_action = "default", start_time = 0.6, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0, action = "action_two", end_time = 0.15, input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.5, action = "action_wield", input = "action_wield" } },


			enter_function = function (attacker_unit, input_extension)
				return input_extension:reset_release_input()
			end,



			critical_strike = { critical_damage_attack_template = "heavy_stab_fencer" },















			hit_mass_count = LINESMAN_HIT_MASS_COUNT,










			baked_sweep = { { 0.20666666666666667, 0.6640157699584961, -0.6139602661132812, -0.1292133331298828, 0.38591229915618896, 0.5727239847183228, 0.5239814519882202, -0.49850010871887207 },
				{ 0.23277777777777778, 0.5969486236572266, -0.3921394348144531, -0.0670309066772461, 0.32414761185646057, 0.5968498587608337, 0.5862688422203064, -0.4415737986564636 },
				{ 0.2588888888888889, 0.42762279510498047, 0.20093154907226562, -0.037354469299316406, 0.2531930208206177, 0.6501590609550476, 0.6147286295890808, -0.3678250014781952 },
				{ 0.28500000000000003, 0.26378345489501953, 0.7913875579833984, -0.029598236083984375, 0.18234676122665405, 0.6773831844329834, 0.6448372006416321, -0.3034578263759613 },
				{ 0.3111111111111111, 0.21618270874023438, 0.9356460571289062, -0.03191375732421875, 0.1535339206457138, 0.68715900182724, 0.6532090306282043, -0.2784920930862427 },
				{ 0.3372222222222222, 0.21421337127685547, 0.9418239593505859, -0.03301239013671875, 0.15073946118354797, 0.6884053349494934, 0.6536492109298706, -0.27589577436447144 },
				{ 0.36333333333333334, 0.2183208465576172, 0.9343662261962891, -0.03255653381347656, 0.15242703258991241, 0.6875095367431641, 0.6538484692573547, -0.2767288088798523 } } },





		heavy_attack_left = { damage_window_start = 0.3, hit_armor_anim = "attack_hit", range_mod = 1.35, kind = "sweep", first_person_hit_anim = "hit_left_shake", sweep_z_offset = 0.05, width_mod = 25, hit_shield_stop_anim = "attack_hit", hit_effect = "melee_hit_sword_1h", additional_critical_strike_chance = 0, use_precision_sweep = false, damage_window_end = 0.41, impact_sound_event = "slashing_hit", charge_value = "heavy_attack", anim_end_event = "attack_finished", no_damage_impact_sound_event = "slashing_hit_armour", damage_profile = "heavy_slashing_linesman_polearm", dedicated_target_range = 2.8, weapon_up_offset_mod = 0.25, anim_event = "attack_swing_heavy_right", hit_stop_anim = "attack_hit", total_time = 1.5,


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,

			anim_time_scale = time_mod * 1.15,






			buff_data = {
				{ start_time = 0, external_multiplier = 1.85, end_time = 0.3, buff_name = "planted_fast_decrease_movement" },






				{ start_time = 0.3, external_multiplier = 0.5, end_time = 0.75, buff_name = "planted_fast_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default_last_1", start_time = 0.65, action = "action_one", release_required = "action_one_hold", doubleclick_window = 0, input = "action_one" },
				{ sub_action = "default_last_1", start_time = 0.65, action = "action_one", release_required = "action_one_hold", doubleclick_window = 0, input = "action_one_hold" },
				{ sub_action = "default", start_time = 1, action = "action_one", doubleclick_window = 0, input = "action_one" },
				{ sub_action = "default", start_time = 0.6, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0, action = "action_two", end_time = 0.15, input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.5, action = "action_wield", input = "action_wield" } },


			enter_function = function (attacker_unit, input_extension)
				return input_extension:reset_release_input()
			end,












			hit_mass_count = LINESMAN_HIT_MASS_COUNT,












			baked_sweep = { { 0.26666666666666666, -0.3899555206298828, 0.2435588836669922, 0.025786399841308594, -0.31145113706588745, 0.5430198907852173, -0.08020314574241638, -0.7756900787353516 },
				{ 0.2961111111111111, -0.36485767364501953, 0.29404449462890625, 0.013394355773925781, -0.23834790289402008, 0.557560384273529, -0.04864691197872162, -0.793694019317627 },
				{ 0.32555555555555554, -0.3208942413330078, 0.3782806396484375, 0.010013580322265625, -0.12837426364421844, 0.5619199872016907, 0.0045351553708314896, -0.8171569108963013 },
				{ 0.355, -0.0036525726318359375, 0.7270774841308594, -0.02929210662841797, 0.32776227593421936, 0.46352848410606384, 0.2344159334897995, -0.789152979850769 },
				{ 0.3844444444444444, 0.5070509910583496, 0.7142734527587891, -0.23909473419189453, 0.7075814008712769, 0.21253202855587006, 0.40954795479774475, -0.5351908802986145 },
				{ 0.41388888888888886, 0.6212005615234375, 0.6251735687255859, -0.30814266204833984, 0.7650994658470154, 0.14792923629283905, 0.43076932430267334, -0.45516759157180786 },
				{ 0.4433333333333333, 0.6146831512451172, 0.6164360046386719, -0.3172588348388672, 0.7526415586471558, 0.16598930954933167, 0.42473822832107544, -0.4749480187892914 } } },







		light_attack_left = { damage_window_start = 0.31, hit_armor_anim = "attack_hit", range_mod = 1.35, kind = "sweep", no_damage_impact_sound_event = "stab_hit_armour", sweep_z_offset = -0.05, width_mod = 20, hit_shield_stop_anim = "attack_hit", additional_critical_strike_chance = 0, hit_effect = "melee_hit_sword_1h", use_precision_sweep = true, damage_profile = "medium_slashing_smiter_stab_elf", damage_window_end = 0.35, impact_sound_event = "stab_hit", aim_assist_ramp_multiplier = 0.5, anim_end_event = "attack_finished", aim_assist_max_ramp_multiplier = 0.8, aim_assist_ramp_decay_delay = 0.1, dedicated_target_range = 2.8, range_mod_add = 0.25, uninterruptible = true, anim_event = "attack_swing_down_right", height_mod = 4, total_time = 2.5,



			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			anim_time_scale = time_mod * 1.05,







			buff_data = {
				{ start_time = 0, external_multiplier = 1.3, end_time = 0.25, buff_name = "planted_fast_decrease_movement" },






				{ start_time = 0.25, external_multiplier = 0.7, end_time = 0.5, buff_name = "planted_fast_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default_last_1", start_time = 0.45, action = "action_one", release_required = "action_one_hold", end_time = 1, input = "action_one" },
				{ sub_action = "default_last_1", start_time = 0.45, action = "action_one", release_required = "action_one_hold", end_time = 1, input = "action_one_hold" },
				{ sub_action = "default", start_time = 1, action = "action_one", input = "action_one" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.5, action = "action_wield", input = "action_wield" } },


















			hit_mass_count = LINESMAN_HIT_MASS_COUNT,











			baked_sweep = { { 0.27666666666666667, 0.44409847259521484, -1.1655235290527344, -0.012271881103515625, 0.4078168272972107, 0.6122485995292664, 0.5208154320716858, -0.4331148564815521 },
				{ 0.29444444444444445, 0.445401668548584, -1.0569114685058594, -0.011190414428710938, 0.40806323289871216, 0.6135261058807373, 0.5173808932304382, -0.43518638610839844 },
				{ 0.31222222222222223, 0.43065547943115234, -0.5486564636230469, 0.055171966552734375, 0.29946959018707275, 0.6782490611076355, 0.5717208981513977, -0.35132813453674316 },
				{ 0.32999999999999996, 0.38078880310058594, 0.14623260498046875, -0.004031181335449219, 0.26424843072891235, 0.693432092666626, 0.6076430678367615, -0.28300997614860535 },
				{ 0.34777777777777774, 0.17403793334960938, 0.7203407287597656, -0.018896102905273438, 0.11460612714290619, 0.6860437393188477, 0.6732889413833618, -0.2507818043231964 },
				{ 0.3655555555555555, 0.14225482940673828, 0.8543624877929688, -0.05120563507080078, 0.14402459561824799, 0.6783118844032288, 0.6833689212799072, -0.22837866842746735 },
				{ 0.3833333333333333, 0.15811920166015625, 0.7102775573730469, -0.0487518310546875, 0.13962219655513763, 0.6800352931022644, 0.6820015907287598, -0.23006828129291534 } } },






		light_attack_right = { damage_window_start = 0.25, hit_armor_anim = "attack_hit", kind = "sweep", range_mod = 1.35, hit_stop_anim = "attack_hit", sweep_z_offset = 0.05, width_mod = 20, hit_shield_stop_anim = "attack_hit", no_damage_impact_sound_event = "slashing_hit_armour", hit_effect = "melee_hit_sword_1h", additional_critical_strike_chance = 0, damage_window_end = 0.35, impact_sound_event = "slashing_hit", use_precision_sweep = false, anim_end_event = "attack_finished", damage_profile = "medium_slashing_linesman_spear", aim_assist_ramp_multiplier = 0.5, aim_assist_max_ramp_multiplier = 0.8, dedicated_target_range = 2.8, aim_assist_ramp_decay_delay = 0.1, weapon_up_offset_mod = 0.25, uninterruptible = true, anim_event = "attack_swing_down_left", height_mod = 4, total_time = 2.5,



			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			anim_time_scale = time_mod * 1.2,







			buff_data = {
				{ start_time = 0, external_multiplier = 1.3, end_time = 0.25, buff_name = "planted_fast_decrease_movement" },






				{ start_time = 0.25, external_multiplier = 0.7, end_time = 0.5, buff_name = "planted_fast_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default_last_2", start_time = 0.55, action = "action_one", release_required = "action_one_hold", end_time = 1.8, input = "action_one" },
				{ sub_action = "default_last_2", start_time = 0.55, action = "action_one", release_required = "action_one_hold", end_time = 1.8, input = "action_one_hold" },
				{ sub_action = "default", start_time = 1.8, action = "action_one", input = "action_one" },
				{ sub_action = "default", start_time = 0.4, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.4, action = "action_wield", input = "action_wield" } },


			enter_function = function (attacker_unit, input_extension)
				return input_extension:reset_release_input()
			end,

















			hit_mass_count = LINESMAN_HIT_MASS_COUNT,











			baked_sweep = { { 0.21666666666666667, -0.24227142333984375, 0.24955177307128906, -0.32523250579833984, -0.3265780508518219, 0.7591557502746582, -0.27207085490226746, -0.4929572343826294 },
				{ 0.24444444444444444, -0.2508831024169922, 0.3293743133544922, -0.3199272155761719, -0.22955787181854248, 0.800779402256012, -0.17664530873298645, -0.5242632627487183 },
				{ 0.2722222222222222, -0.013574600219726562, 0.6612224578857422, -0.19697952270507812, 0.06105572730302811, 0.8118216395378113, 0.26823198795318604, -0.5150431990623474 },
				{ 0.3, 0.26749467849731445, 0.7521095275878906, -0.04496288299560547, 0.2204701155424118, 0.683013379573822, 0.5257710814476013, -0.4565637707710266 },
				{ 0.3277777777777778, 0.5497579574584961, 0.7025299072265625, 0.07909393310546875, 0.3454209566116333, 0.5142987966537476, 0.7044057250022888, -0.3464011251926422 },
				{ 0.3555555555555555, 0.7812771797180176, 0.3126087188720703, 0.13938331604003906, 0.4742424786090851, 0.2292875200510025, 0.8282607793807983, -0.191063791513443 },
				{ 0.3833333333333333, 0.8180108070373535, 0.20461463928222656, 0.025803565979003906, 0.5458720326423645, 0.17919017374515533, 0.8019561767578125, -0.16364891827106476 } } },








































































		light_attack_stab_1 = { damage_window_start = 0.2, hit_armor_anim = "attack_hit", range_mod = 1.35, kind = "sweep", no_damage_impact_sound_event = "stab_hit_armour", additional_critical_strike_chance = 0, width_mod = 20, use_precision_sweep = true, hit_shield_stop_anim = "attack_hit", damage_profile = "medium_slashing_smiter_stab_elf", hit_effect = "melee_hit_sword_1h", aim_assist_ramp_multiplier = 0.5, aim_assist_max_ramp_multiplier = 0.8, damage_window_end = 0.3, impact_sound_event = "stab_hit", aim_assist_ramp_decay_delay = 0.1, anim_end_event = "attack_finished", dedicated_target_range = 2.8, range_mod_add = 0.25, uninterruptible = true, anim_event = "attack_swing_down_left_axe", height_mod = 4, total_time = 2.5,



			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			anim_time_scale = time_mod * 1.05,






			buff_data = {
				{ start_time = 0, external_multiplier = 1.3, end_time = 0.25, buff_name = "planted_fast_decrease_movement" },






				{ start_time = 0.25, external_multiplier = 0.7, end_time = 0.5, buff_name = "planted_fast_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default_left", start_time = 0.425, action = "action_one", release_required = "action_one_hold", end_time = 1, input = "action_one" },
				{ sub_action = "default_left", start_time = 0.425, action = "action_one", release_required = "action_one_hold", end_time = 1, input = "action_one_hold" },
				{ sub_action = "default", start_time = 1, action = "action_one", input = "action_one" },
				{ sub_action = "default", start_time = 0.35, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.35, action = "action_wield", input = "action_wield" } },































			baked_sweep = { { 0.16666666666666669, 0.23742055892944336, 0.21167564392089844, -0.2365579605102539, 0.3920941650867462, 0.5806900262832642, 0.4908711612224579, -0.5177903175354004 },
				{ 0.19444444444444445, 0.13166522979736328, 0.73309326171875, -0.22345638275146484, 0.39762982726097107, 0.5986071228981018, 0.5009585618972778, -0.4822867810726166 },
				{ 0.22222222222222224, 0.07783031463623047, 0.8244342803955078, -0.10752010345458984, 0.39718762040138245, 0.5312359929084778, 0.5513427257537842, -0.5060152411460876 },
				{ 0.25, 0.08059883117675781, 0.8185653686523438, -0.10806751251220703, 0.3986923098564148, 0.5301560759544373, 0.5524193048477173, -0.5047889351844788 },
				{ 0.2777777777777778, 0.08130645751953125, 0.8179225921630859, -0.1083669662475586, 0.404417484998703, 0.525874674320221, 0.5474934577941895, -0.5100521445274353 },
				{ 0.3055555555555556, 0.08179569244384766, 0.817169189453125, -0.10863399505615234, 0.42370089888572693, 0.5105394124984741, 0.5285259485244751, -0.5296106934547424 },
				{ 0.3333333333333333, 0.08291244506835938, 0.8152389526367188, -0.10933399200439453, 0.43068936467170715, 0.5048125386238098, 0.5219577550888062, -0.5359394550323486 } } },






		light_attack_stab_2 = { damage_window_start = 0.15, hit_armor_anim = "attack_hit", range_mod = 1.35, kind = "sweep", no_damage_impact_sound_event = "stab_hit_armour", additional_critical_strike_chance = 0, width_mod = 20, use_precision_sweep = true, hit_shield_stop_anim = "attack_hit", damage_profile = "medium_slashing_smiter_stab_elf", hit_effect = "melee_hit_sword_1h", aim_assist_ramp_multiplier = 0.5, aim_assist_max_ramp_multiplier = 0.8, damage_window_end = 0.3, impact_sound_event = "stab_hit", aim_assist_ramp_decay_delay = 0.1, anim_end_event = "attack_finished", dedicated_target_range = 2.8, range_mod_add = 0.25, uninterruptible = true, anim_event = "attack_swing_right", height_mod = 4, total_time = 2.5,



			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			anim_time_scale = time_mod * 1.15,






			buff_data = {
				{ start_time = 0, external_multiplier = 1.3, end_time = 0.25, buff_name = "planted_fast_decrease_movement" },






				{ start_time = 0.25, external_multiplier = 0.7, end_time = 0.5, buff_name = "planted_fast_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default", start_time = 0.34, action = "action_one", release_required = "action_one_hold", end_time = 1, input = "action_one" },
				{ sub_action = "default", start_time = 0.34, action = "action_one", release_required = "action_one_hold", end_time = 1, input = "action_one_hold" },
				{ sub_action = "default", start_time = 1, action = "action_one", input = "action_one" },
				{ sub_action = "default", start_time = 0.35, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.35, action = "action_wield", input = "action_wield" } },






























			baked_sweep = { { 0.11666666666666667, 0.21761322021484375, -0.5021438598632812, -0.36545848846435547, 0.46234118938446045, 0.6123386025428772, 0.4850865304470062, -0.4194915294647217 },
				{ 0.1527777777777778, 0.11975479125976562, 0.30142784118652344, -0.2497701644897461, 0.3819785714149475, 0.5424015522003174, 0.5822683572769165, -0.4699538052082062 },
				{ 0.18888888888888888, 0.015842437744140625, 0.8332405090332031, -0.17376422882080078, 0.5090974569320679, 0.3725377321243286, 0.4531781077384949, -0.6298134922981262 },
				{ 0.22499999999999998, 0.0014591217041015625, 0.8617515563964844, -0.1717061996459961, 0.5215185284614563, 0.36783134937286377, 0.4337868392467499, -0.6360405683517456 },
				{ 0.26111111111111107, -0.0037527084350585938, 0.8639335632324219, -0.17154216766357422, 0.5232082605361938, 0.3675221800804138, 0.4342666268348694, -0.6345022916793823 },
				{ 0.29722222222222217, -0.0031423568725585938, 0.8698444366455078, -0.17011547088623047, 0.52377849817276, 0.3666453957557678, 0.43229737877845764, -0.6358822584152222 },
				{ 0.3333333333333333, 0.0002994537353515625, 0.8725566864013672, -0.1692485809326172, 0.5236333012580872, 0.3650965690612793, 0.4298117458820343, -0.6385722756385803 } } },





		light_attack_bopp = { damage_window_start = 0.23, hit_armor_anim = "attack_hit", kind = "sweep", range_mod = 1.35, hit_stop_anim = "attack_hit", sweep_z_offset = 0.2, width_mod = 20, hit_shield_stop_anim = "attack_hit", no_damage_impact_sound_event = "slashing_hit_armour", hit_effect = "melee_hit_sword_1h", additional_critical_strike_chance = 0, damage_window_end = 0.35, impact_sound_event = "slashing_hit", damage_profile = "medium_slashing_linesman_spear", anim_end_event = "attack_finished", aim_assist_ramp_multiplier = 0.5, aim_assist_max_ramp_multiplier = 0.8, aim_assist_ramp_decay_delay = 0.1, dedicated_target_range = 2.8, weapon_up_offset_mod = 0.25, uninterruptible = true, anim_event = "push_stab", height_mod = 4, total_time = 2.5,



			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			anim_time_scale = time_mod * 1.2,







			buff_data = {
				{ start_time = 0, external_multiplier = 1.3, end_time = 0.25, buff_name = "planted_fast_decrease_movement" },






				{ start_time = 0.25, external_multiplier = 0.7, end_time = 0.5, buff_name = "planted_fast_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default_last_1", start_time = 0.5, action = "action_one", release_required = "action_two_hold", end_time = 1.8, input = "action_one" },
				{ sub_action = "default_last_1", start_time = 0.5, action = "action_one", release_required = "action_two_hold", end_time = 1.8, input = "action_one_hold" },
				{ sub_action = "default", start_time = 1.8, action = "action_one", input = "action_one" },
				{ sub_action = "default", start_time = 0.5, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.5, action = "action_wield", input = "action_wield" } },


			enter_function = function (attacker_unit, input_extension)
				return input_extension:reset_release_input()
			end,

















			hit_mass_count = LINESMAN_HIT_MASS_COUNT,











			baked_sweep = { { 0.19666666666666668, -0.23923015594482422, 0.225982666015625, -0.3086681365966797, -0.26112234592437744, 0.774448812007904, -0.35174429416656494, -0.45642104744911194 },
				{ 0.2277777777777778, -0.23633861541748047, 0.23248863220214844, -0.26551246643066406, -0.2068127691745758, 0.7530343532562256, -0.3568165898323059, -0.5126888155937195 },
				{ 0.2588888888888889, -0.279815673828125, 0.52386474609375, -0.1960306167602539, 0.049609698355197906, 0.7633028030395508, -0.05757541581988335, -0.6415550112724304 },
				{ 0.29, 0.16223526000976562, 0.7624187469482422, -0.037133216857910156, 0.2692733108997345, 0.650127649307251, 0.42858394980430603, -0.5666937232017517 },
				{ 0.3211111111111111, 0.4159111976623535, 0.7707347869873047, 0.027372360229492188, 0.34894436597824097, 0.5677924156188965, 0.5766633152961731, -0.4725559949874878 },
				{ 0.3522222222222222, 0.7910466194152832, 0.356536865234375, 0.009469032287597656, 0.5731239318847656, 0.23903325200080872, 0.7399589419364929, -0.2585591673851013 },
				{ 0.3833333333333333, 0.8228940963745117, 0.2178192138671875, -0.06193733215332031, 0.6025396585464478, 0.1422412246465683, 0.7480043768882751, -0.23917120695114136 } } },



		push = { damage_window_start = 0.05, anim_end_event = "attack_finished", outer_push_angle = 180, kind = "push_stagger", damage_profile_outer = "light_push", weapon_action_hand = "right", push_angle = 100, hit_effect = "melee_hit_sword_1h", damage_window_end = 0.2, impact_sound_event = "slashing_hit", charge_value = "action_push", no_damage_impact_sound_event = "slashing_hit_armour", dedicated_target_range = 2.8, anim_event = "attack_push", damage_profile_inner = "medium_push", total_time = 0.8,


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,


			buff_data = {
				{ start_time = 0, external_multiplier = 0.75, buff_name = "planted_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default", start_time = 0.25, action = "action_one", release_required = "action_two_hold", input = "action_one" },
				{ sub_action = "default", start_time = 0.25, action = "action_one", release_required = "action_two_hold", input = "action_one_hold" },
				{ sub_action = "light_attack_bopp", start_time = 0.25, action = "action_one", doubleclick_window = 0, end_time = 0.8, input = "action_one_hold",
					hold_required = { "action_two_hold", "action_one_hold" } }, { sub_action = "default", start_time = 0.4, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.4, action = "action_wield", input = "action_wield" } },


			push_radius = push_radius,











			chain_condition_func = function (attacker_unit, input_extension)
				local status_extension = ScriptUnit.extension(attacker_unit, "status_system")

				return not status_extension:fatigued()
			end } },








	action_two = {
		default = { cooldown = 0.15, minimum_hold_time = 0.2, anim_end_event = "parry_finished", kind = "block", hold_input = "action_two_hold", anim_event = "parry_pose",


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action"
			end,
			total_time = math.huge,




			enter_function = function (attacker_unit, input_extension, remaining_time)
				return input_extension:reset_release_input_with_delay(remaining_time)
			end,
			buff_data = {
				{ start_time = 0, external_multiplier = 0.8, buff_name = "planted_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "push", start_time = 0.2, action = "action_one", doubleclick_window = 0, input = "action_one",
					hold_required = { "action_two_hold" } }, { sub_action = "default", start_time = 0.2, action = "action_one", release_required = "action_two_hold", doubleclick_window = 0, input = "action_one" },
				{ sub_action = "default", start_time = 0.2, action = "action_wield", input = "action_wield" } } } },





	action_inspect = ActionTemplates.action_inspect,
	action_wield = ActionTemplates.wield }


weapon_template.right_hand_unit = "units/weapons/player/wpn_empire_short_sword/wpn_empire_short_sword"
weapon_template.right_hand_attachment_node_linking = AttachmentNodeLinking.polearm
weapon_template.display_unit = "units/weapons/weapon_display/display_2h_spears_wood_elf"
weapon_template.wield_anim = "to_spear"
weapon_template.state_machine = "units/beings/player/first_person_base/state_machines/melee/spear"
weapon_template.buff_type = "MELEE_2H"
weapon_template.weapon_type = "POLEARM"
weapon_template.max_fatigue_points = 6
weapon_template.dodge_count = 3
weapon_template.block_angle = 180
weapon_template.outer_block_angle = 360
weapon_template.block_fatigue_point_multiplier = 0.5
weapon_template.outer_block_fatigue_point_multiplier = 2
weapon_template.buffs = {
	change_dodge_distance = { external_optional_multiplier = 1.15 },
	change_dodge_speed = { external_optional_multiplier = 1.15 } }



weapon_template.attack_meta_data = {
	tap_attack = { penetrating = false, arc = 0 },



	hold_attack = { penetrating = true, arc = 2 } }




weapon_template.aim_assist_settings = { max_range = 5, no_aim_input_multiplier = 0, base_multiplier = 0, effective_max_range = 4,




	breed_scalars = { skaven_storm_vermin = 1, skaven_clan_rat = 0.5, skaven_slave = 0.5 } }






weapon_template.weapon_diagram = {
	light_attack = {
		[DamageTypes.ARMOR_PIERCING] = 1,
		[DamageTypes.CLEAVE] = 3,
		[DamageTypes.SPEED] = 4,
		[DamageTypes.STAGGER] = 1,
		[DamageTypes.DAMAGE] = 3 },

	heavy_attack = {
		[DamageTypes.ARMOR_PIERCING] = 3,
		[DamageTypes.CLEAVE] = 4,
		[DamageTypes.SPEED] = 2,
		[DamageTypes.STAGGER] = 2,
		[DamageTypes.DAMAGE] = 4 } }



weapon_template.tooltip_keywords = { "weapon_keyword_fast_attacks", "weapon_keyword_versatile", "weapon_keyword_high_agility" }





weapon_template.tooltip_compare = {
	light = { action_name = "action_one", sub_action_name = "light_attack_left" },



	heavy = { action_name = "action_one", sub_action_name = "heavy_attack_left" } }





weapon_template.tooltip_detail = {
	light = { action_name = "action_one", sub_action_name = "default" },



	heavy = { action_name = "action_one", sub_action_name = "default" },



	push = { action_name = "action_one", sub_action_name = "push" } }






weapon_template.wwise_dep_right_hand = { "wwise/two_handed_axes" }





return { two_handed_spears_elf_template_1 = table.clone(weapon_template) }