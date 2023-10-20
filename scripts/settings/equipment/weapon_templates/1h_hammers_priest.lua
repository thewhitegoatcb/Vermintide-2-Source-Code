


local push_radius = 2
local time_mod = 0.9

local weapon_template = { }
weapon_template.actions = {
	action_one = {
		default = { aim_assist_ramp_decay_delay = 0.1, anim_end_event = "attack_finished", kind = "melee_start", attack_hold_input = "action_one_hold", aim_assist_max_ramp_multiplier = 0.4, aim_assist_ramp_multiplier = 0.2, anim_event = "attack_swing_charge_left_diagonal",


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			total_time = math.huge,


			buff_data = {
				{ start_time = 0, external_multiplier = 0.25, buff_name = "planted_charging_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "light_attack_01", start_time = 0, action = "action_one", end_time = 0.3, input = "action_one_release" },
				{ sub_action = "heavy_attack_01", start_time = 0.5, action = "action_one", input = "action_one_release" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0, action = "action_wield", input = "action_wield" },
				{ start_time = 0.7, blocker = true, end_time = 1.2, input = "action_one_hold" },
				{ sub_action = "heavy_attack_01", start_time = 0.8, action = "action_one", auto_chain = true } } },






		default_02 = { aim_assist_ramp_decay_delay = 0.1, anim_end_event = "attack_finished", kind = "melee_start", aim_assist_max_ramp_multiplier = 0.4, aim_assist_ramp_multiplier = 0.2, anim_event = "attack_swing_charge_right_diagonal_pose",


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			total_time = math.huge,

			buff_data = {
				{ start_time = 0, external_multiplier = 0.25, buff_name = "planted_charging_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "light_attack_02", start_time = 0, action = "action_one", end_time = 0.3, input = "action_one_release" },
				{ sub_action = "heavy_attack_02", start_time = 0.5, action = "action_one", input = "action_one_release" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0, action = "action_wield", input = "action_wield" },
				{ start_time = 0.7, blocker = true, end_time = 1.2, input = "action_one_hold" },
				{ sub_action = "heavy_attack_02", start_time = 0.8, action = "action_one", auto_chain = true } } },






		default_03 = { aim_assist_ramp_decay_delay = 0.1, anim_end_event = "attack_finished", kind = "melee_start", aim_assist_max_ramp_multiplier = 0.4, aim_assist_ramp_multiplier = 0.2, anim_event = "attack_swing_charge_left_diagonal_pose",


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			total_time = math.huge,

			buff_data = {
				{ start_time = 0, external_multiplier = 0.25, buff_name = "planted_charging_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "light_attack_03", start_time = 0, action = "action_one", end_time = 0.3, input = "action_one_release" },
				{ sub_action = "heavy_attack_01", start_time = 0.5, action = "action_one", input = "action_one_release" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0, action = "action_wield", input = "action_wield" },
				{ start_time = 0.7, blocker = true, end_time = 1.2, input = "action_one_hold" },
				{ sub_action = "heavy_attack_01", start_time = 0.8, action = "action_one", auto_chain = true } } },






		default_04 = { aim_assist_ramp_decay_delay = 0.1, anim_end_event = "attack_finished", kind = "melee_start", aim_assist_max_ramp_multiplier = 0.4, aim_assist_ramp_multiplier = 0.2, anim_event = "attack_swing_charge_right_diagonal_pose",


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,
			total_time = math.huge,

			buff_data = {
				{ start_time = 0, external_multiplier = 0.25, buff_name = "planted_charging_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "light_attack_04", start_time = 0, action = "action_one", end_time = 0.3, input = "action_one_release" },
				{ sub_action = "heavy_attack_02", start_time = 0.5, action = "action_one", input = "action_one_release" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0, action = "action_wield", input = "action_wield" },
				{ start_time = 0.7, blocker = true, end_time = 1.2, input = "action_one_hold" },
				{ sub_action = "heavy_attack_02", start_time = 0.8, action = "action_one", auto_chain = true } } },







		heavy_attack_01 = { damage_window_start = 0.22, hit_armor_anim = "attack_hit", additional_critical_strike_chance = 0, kind = "sweep", first_person_hit_anim = "shake_hit", width_mod = 25, no_damage_impact_sound_event = "blunt_hit_armour", hit_shield_stop_anim = "attack_hit", use_precision_sweep = true, hit_effect = "melee_hit_hammers_1h", damage_profile = "medium_blunt_smiter_1h", aim_assist_ramp_multiplier = 0.4, damage_window_end = 0.32, impact_sound_event = "blunt_hit", charge_value = "heavy_attack", anim_end_event = "attack_finished", aim_assist_max_ramp_multiplier = 0.9, aim_assist_ramp_decay_delay = 0.1, reset_aim_on_attack = true, dedicated_target_range = 3, uninterruptible = true, anim_event = "attack_swing_heavy_down", total_time = 1.2,



			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,

			anim_time_scale = time_mod * 1.2,


			buff_data = {
				{ start_time = 0, external_multiplier = 1, end_time = 0.2, buff_name = "planted_charging_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default_02", start_time = 0.5, action = "action_one", release_required = "action_one_hold", input = "action_one" },
				{ sub_action = "default_02", start_time = 0.5, action = "action_one", release_required = "action_one_hold", input = "action_one_hold" },
				{ sub_action = "default", start_time = 0.4, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.5, action = "action_wield", input = "action_wield" } },


			enter_function = function (attacker_unit, input_extension)
				return input_extension:reset_release_input()
			end,

			critical_strike = { },



























			baked_sweep = { { 0.18666666666666668, 0.19051647186279297, 0.36061668395996094, 0.20305824279785156, -0.6018593311309814, -0.12416155636310577, 0.0244308989495039, -0.7885128259658813 },
				{ 0.21444444444444444, 0.1427445411682129, 0.53643798828125, 0.174041748046875, -0.31440839171409607, -0.11749488115310669, -0.026520555838942528, -0.941615104675293 },
				{ 0.24222222222222223, 0.0668487548828125, 0.7187013626098633, -0.0468754768371582, 0.214589923620224, -0.07287932932376862, -0.04244709387421608, -0.9730560183525085 },
				{ 0.27, -0.05629158020019531, 0.6958341598510742, -0.4509000778198242, 0.770781934261322, -0.0073905885219573975, -0.08794330805540085, -0.6309569478034973 },
				{ 0.2977777777777778, -0.10600805282592773, 0.4154014587402344, -0.718041181564331, 0.9609098434448242, -0.019633352756500244, -0.16517719626426697, -0.22132165729999542 },
				{ 0.3255555555555556, -0.07964944839477539, 0.10249042510986328, -0.7385938167572021, 0.9698923230171204, -0.036546677350997925, -0.20453011989593506, 0.12704594433307648 },
				{ 0.35333333333333333, -0.07324790954589844, -0.009373664855957031, -0.6999554634094238, 0.9412844181060791, -0.04748012498021126, -0.22240032255649567, 0.24953442811965942 } } },



		heavy_attack_02 = { damage_window_start = 0.2, hit_armor_anim = "attack_hit", additional_critical_strike_chance = 0, kind = "sweep", first_person_hit_anim = "shake_hit", width_mod = 25, no_damage_impact_sound_event = "blunt_hit_armour", hit_shield_stop_anim = "attack_hit", use_precision_sweep = true, hit_effect = "melee_hit_hammers_1h", damage_profile = "medium_blunt_smiter_1h", aim_assist_ramp_multiplier = 0.4, damage_window_end = 0.26, impact_sound_event = "blunt_hit", charge_value = "heavy_attack", anim_end_event = "attack_finished", aim_assist_max_ramp_multiplier = 0.9, aim_assist_ramp_decay_delay = 0.1, reset_aim_on_attack = true, dedicated_target_range = 3, uninterruptible = true, anim_event = "attack_swing_heavy_down_right", total_time = 1.2,



			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,

			anim_time_scale = time_mod * 1.2,


			buff_data = {
				{ start_time = 0, external_multiplier = 1, end_time = 0.2, buff_name = "planted_charging_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default_03", start_time = 0.5, action = "action_one", release_required = "action_one_hold", input = "action_one" },
				{ sub_action = "default_03", start_time = 0.5, action = "action_one", release_required = "action_one_hold", input = "action_one_hold" },
				{ sub_action = "default", start_time = 0.4, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.5, action = "action_wield", input = "action_wield" } },


			enter_function = function (attacker_unit, input_extension)
				return input_extension:reset_release_input()
			end,

			critical_strike = { },



























			baked_sweep = { { 0.16666666666666669, -0.21280956268310547, 0.3200458288192749, 0.17691993713378906, -0.7116137742996216, 0.23184987902641296, -0.20937302708625793, -0.6292968392372131 },
				{ 0.1877777777777778, -0.17109012603759766, 0.4236060380935669, 0.17266511917114258, -0.6162311434745789, 0.2480379194021225, -0.12307403981685638, -0.7372850179672241 },
				{ 0.2088888888888889, -0.10233211517333984, 0.5868263244628906, 0.10930275917053223, -0.3021904230117798, 0.2547839283943176, -0.08365737646818161, -0.9147499799728394 },
				{ 0.23, -0.03907012939453125, 0.6353282928466797, 0.014926552772521973, 0.12373876571655273, 0.17406484484672546, -0.018115168437361717, -0.976760983467102 },
				{ 0.2511111111111111, 0.11181354522705078, 0.7389034032821655, -0.42977583408355713, 0.6308553814888, 0.15983915328979492, 0.0682964026927948, -0.7561802864074707 },
				{ 0.27222222222222225, 0.3881826400756836, 0.5206271409988403, -0.6931085586547852, 0.7848485112190247, 0.1677180975675583, 0.18679384887218475, -0.566561222076416 },
				{ 0.29333333333333333, 0.691746711730957, 0.2174384593963623, -0.7537145614624023, 0.743034839630127, 0.3629452884197235, 0.38047996163368225, -0.4140108525753021 } } },




		light_attack_01 = { damage_window_start = 0.38, range_mod = 1.2, kind = "sweep", first_person_hit_anim = "shake_hit", no_damage_impact_sound_event = "blunt_hit_armour", use_precision_sweep = false, width_mod = 25, damage_profile = "light_blunt_tank_diag", hit_effect = "melee_hit_hammers_1h", damage_window_end = 0.52, impact_sound_event = "blunt_hit", anim_end_event = "attack_finished", dedicated_target_range = 2, anim_event = "attack_swing_left_diagonal", hit_stop_anim = "attack_hit", total_time = 1.5,


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,

			anim_time_scale = time_mod * 1,



			buff_data = {
				{ start_time = 0, external_multiplier = 0.9, end_time = 0.5, buff_name = "planted_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default_02", start_time = 0.55, action = "action_one", end_time = 1.25, input = "action_one" },
				{ sub_action = "default_02", start_time = 0.55, action = "action_one", end_time = 1.25, input = "action_one_hold" },
				{ sub_action = "default", start_time = 1.25, action = "action_one", input = "action_one" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.5, action = "action_wield", input = "action_wield" } },

















			hit_mass_count = TANK_HIT_MASS_COUNT,


			baked_sweep = { { 0.3466666666666667, 0.483884334564209, 0.47476673126220703, 0.0647430419921875, -0.6646059155464172, -0.2710193991661072, 0.1380850076675415, -0.6824808120727539 },
				{ 0.3811111111111111, 0.3907051086425781, 0.5844125747680664, 0.05847930908203125, -0.4977528750896454, -0.34602248668670654, 0.13695508241653442, -0.783424437046051 },
				{ 0.41555555555555557, 0.1707744598388672, 0.721766471862793, -0.039945125579833984, -0.1236281469464302, -0.40281978249549866, 0.018047966063022614, -0.9067119359970093 },
				{ 0.45, -0.19178485870361328, 0.6985616683959961, -0.2270984649658203, 0.5131164193153381, -0.2941576838493347, -0.26335909962654114, -0.7621186375617981 },
				{ 0.48444444444444446, -0.3852057456970215, 0.37096595764160156, -0.42032575607299805, 0.9000388979911804, -0.09327825158834457, -0.36778801679611206, -0.21438556909561157 },
				{ 0.518888888888889, -0.38056468963623047, 0.09614181518554688, -0.508418083190918, 0.937787652015686, -0.053429488092660904, -0.31316718459129333, 0.14009246230125427 },
				{ 0.5533333333333333, -0.3473825454711914, -0.019014358520507812, -0.4913487434387207, 0.9249515533447266, -0.043343961238861084, -0.27455076575279236, 0.2592447102069855 } } },




		light_attack_02 = { damage_window_start = 0.33, range_mod = 1.2, kind = "sweep", first_person_hit_anim = "shake_hit", no_damage_impact_sound_event = "blunt_hit_armour", use_precision_sweep = false, width_mod = 25, damage_profile = "light_blunt_tank_diag", hit_effect = "melee_hit_hammers_1h", damage_window_end = 0.47, impact_sound_event = "blunt_hit", anim_end_event = "attack_finished", dedicated_target_range = 2, anim_event = "attack_swing_right_diagonal", hit_stop_anim = "attack_hit", total_time = 1.5,


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,

			anim_time_scale = time_mod * 1,



			buff_data = {
				{ start_time = 0, external_multiplier = 0.9, end_time = 0.5, buff_name = "planted_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default_03", start_time = 0.5, action = "action_one", end_time = 1.25, input = "action_one" },
				{ sub_action = "default_03", start_time = 0.5, action = "action_one", end_time = 1.25, input = "action_one_hold" },
				{ sub_action = "default", start_time = 1.25, action = "action_one", input = "action_one" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.5, action = "action_wield", input = "action_wield" } },

















			hit_mass_count = TANK_HIT_MASS_COUNT,



			baked_sweep = { { 0.2966666666666667, -0.35729217529296875, 0.14952468872070312, 0.045088768005371094, 0.7994338274002075, -0.12080780416727066, 0.44008868932724, 0.39068272709846497 },
				{ 0.33111111111111113, -0.3022012710571289, 0.20639801025390625, 0.06453371047973633, 0.8166815638542175, -0.11303877830505371, 0.35718944668769836, 0.43894103169441223 },
				{ 0.3655555555555556, -0.2267475128173828, 0.3914222717285156, 0.06323957443237305, -0.7257636189460754, 0.24781136214733124, -0.17700500786304474, -0.6168678998947144 },
				{ 0.4, -0.09175348281860352, 0.6137304306030273, -0.005164146423339844, -0.3365127444267273, 0.40556076169013977, -0.0439031608402729, -0.8487356305122375 },
				{ 0.4344444444444444, 0.30226993560791016, 0.7146263122558594, -0.26445770263671875, 0.4230009913444519, 0.36118578910827637, 0.2954553961753845, -0.7767375111579895 },
				{ 0.4688888888888889, 0.7512049674987793, 0.4149360656738281, -0.5081214904785156, 0.6855685114860535, 0.28809845447540283, 0.4954129457473755, -0.4489556550979614 },
				{ 0.5033333333333333, 0.8567628860473633, 0.1673564910888672, -0.6101157665252686, 0.6303596496582031, 0.4466073513031006, 0.5304821133613586, -0.348966121673584 } } },




		light_attack_03 = { damage_window_start = 0.38, anim_end_event = "attack_finished", kind = "sweep", first_person_hit_anim = "shake_hit", range_mod = 1.2, use_precision_sweep = false, width_mod = 25, additional_critical_strike_chance = 0.1, damage_profile = "light_blunt_smiter", hit_effect = "melee_hit_hammers_1h", damage_window_end = 0.52, impact_sound_event = "blunt_hit", no_damage_impact_sound_event = "blunt_hit_armour", dedicated_target_range = 2, anim_event = "attack_swing_left_diagonal_last", total_time = 1.5,


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,

			anim_time_scale = time_mod * 1,



			buff_data = {
				{ start_time = 0.1, external_multiplier = 1.3, end_time = 0.4, buff_name = "planted_fast_decrease_movement" },






				{ start_time = 0.45, external_multiplier = 0.9, end_time = 0.9, buff_name = "planted_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default_04", start_time = 0.5, action = "action_one", end_time = 1.25, input = "action_one" },
				{ sub_action = "default_04", start_time = 0.5, action = "action_one", end_time = 1.25, input = "action_one_hold" },
				{ sub_action = "default", start_time = 1.25, action = "action_one", input = "action_one" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.5, action = "action_wield", input = "action_wield" } },


















			hit_mass_count = TANK_HIT_MASS_COUNT,




			baked_sweep = { { 0.3466666666666667, 0.4780702590942383, 0.4999532699584961, -0.4391322135925293, 0.22451664507389069, 0.8475393652915955, -0.31038641929626465, 0.3673277199268341 },
				{ 0.3811111111111111, 0.20599699020385742, 0.7151088714599609, -0.28249597549438477, -0.1226593628525734, 0.9244887828826904, -0.022318921983242035, 0.360245943069458 },
				{ 0.41555555555555557, -0.042040348052978516, 0.6796045303344727, -0.0020046234130859375, -0.13457554578781128, 0.7406970262527466, 0.6012316346168518, 0.2679139971733093 },
				{ 0.45, -0.20464468002319336, 0.5010671615600586, 0.20026063919067383, -0.19949780404567719, 0.4372595250606537, 0.8655558228492737, 0.14077605307102203 },
				{ 0.48444444444444446, -0.2892484664916992, 0.24627971649169922, 0.2871575355529785, -0.16494247317314148, 0.16612783074378967, 0.9334176778793335, 0.27189522981643677 },
				{ 0.518888888888889, -0.3249831199645996, -0.2036876678466797, 0.2527170181274414, -0.2769891023635864, 0.006954491138458252, 0.9197817444801331, 0.27790340781211853 },
				{ 0.5533333333333333, -0.2396841049194336, -0.46266746520996094, 0.15036869049072266, -0.3065393567085266, -0.05974752828478813, 0.918737530708313, 0.24163030087947845 } } },




		light_attack_04 = { damage_window_start = 0.35, range_mod = 1.3, kind = "sweep", first_person_hit_anim = "shake_hit", no_damage_impact_sound_event = "blunt_hit_armour", use_precision_sweep = true, width_mod = 25, damage_profile = "light_blunt_smiter", aim_assist_max_ramp_multiplier = 0.4, aim_assist_ramp_decay_delay = 0.1, hit_effect = "melee_hit_hammers_1h", damage_window_end = 0.45, impact_sound_event = "blunt_hit", anim_end_event = "attack_finished", dedicated_target_range = 2, aim_assist_ramp_multiplier = 0.2, anim_event = "attack_swing_down_right", hit_stop_anim = "attack_hit", total_time = 1.5,


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,

			anim_time_scale = time_mod * 1.35,



			buff_data = {
				{ start_time = 0, external_multiplier = 0.9, end_time = 0.5, buff_name = "planted_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default", start_time = 0.85, action = "action_one", end_time = 1.25, input = "action_one" },
				{ sub_action = "default", start_time = 0.85, action = "action_one", end_time = 1.25, input = "action_one_hold" },
				{ sub_action = "default", start_time = 1.25, action = "action_one", input = "action_one" },
				{ sub_action = "default", start_time = 0, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.5, action = "action_wield", input = "action_wield" } },
























			baked_sweep = { { 0.31666666666666665, -0.22872543334960938, 0.28882694244384766, 0.16430282592773438, -0.664970338344574, 0.2820165455341339, -0.31107330322265625, -0.617668628692627 },
				{ 0.34444444444444444, -0.21445143222808838, 0.2994270324707031, 0.17752838134765625, -0.7023525834083557, 0.2225172072649002, -0.24395546317100525, -0.6306129693984985 },
				{ 0.37222222222222223, -0.17972981929779053, 0.4503345489501953, 0.18200445175170898, -0.5845308303833008, 0.21713466942310333, -0.16134311258792877, -0.7649474740028381 },
				{ 0.4, -0.08943676948547363, 0.6562747955322266, 0.11636877059936523, -0.20325642824172974, 0.20186173915863037, -0.09140421450138092, -0.9537211060523987 },
				{ 0.42777777777777776, 0.03396475315093994, 0.7742929458618164, -0.15497064590454102, 0.4760753810405731, 0.11304154247045517, 0.053959399461746216, -0.8704379796981812 },
				{ 0.45555555555555555, 0.37826311588287354, 0.3421163558959961, -0.8149518966674805, 0.8426527976989746, 0.1876683235168457, 0.1232571080327034, -0.48941248655319214 },
				{ 0.48333333333333334, 0.7894637584686279, 0.2565927505493164, -0.6501116752624512, 0.6505768299102783, 0.4082399308681488, 0.4832175672054291, -0.4202270209789276 } } },




		light_attack_bopp = { damage_window_start = 0.33, range_mod = 1.2, kind = "sweep", first_person_hit_anim = "shake_hit", no_damage_impact_sound_event = "blunt_hit_armour", width_mod = 25, use_precision_sweep = false, damage_profile = "light_blunt_tank", hit_effect = "melee_hit_hammers_1h", damage_window_end = 0.47, impact_sound_event = "blunt_hit", anim_end_event = "attack_finished", dedicated_target_range = 2, anim_event = "attack_swing_right", hit_stop_anim = "attack_hit", total_time = 1.5,


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,

			anim_time_scale = time_mod * 1.2,



			buff_data = {
				{ start_time = 0, external_multiplier = 0.9, end_time = 0.5, buff_name = "planted_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default", start_time = 0.5, action = "action_one", end_time = 1.25, input = "action_one" },
				{ sub_action = "default", start_time = 0.5, action = "action_one", end_time = 1.25, input = "action_one_hold" },
				{ sub_action = "default", start_time = 1.25, action = "action_one", input = "action_one" },
				{ sub_action = "default", start_time = 0.5, action = "action_two", input = "action_two_hold" },
				{ sub_action = "default", start_time = 0.5, action = "action_wield", input = "action_wield" } },



			enter_function = function (attacker_unit, input_extension)
				return input_extension:reset_release_input()
			end,
















			hit_mass_count = TANK_HIT_MASS_COUNT,


			baked_sweep = { { 0.2966666666666667, -0.3996458053588867, 0.49522876739501953, -0.09734725952148438, -0.5046903491020203, 0.5505948662757874, -0.19880267977714539, -0.6345159411430359 },
				{ 0.33111111111111113, -0.2940654754638672, 0.6127462387084961, -0.09796524047851562, -0.3705276846885681, 0.6319636702537537, -0.13404719531536102, -0.6673548817634583 },
				{ 0.3655555555555556, -0.08524036407470703, 0.6984024047851562, -0.11264896392822266, -0.11474612355232239, 0.6942976117134094, 0.08300261199474335, -0.7056165933609009 },
				{ 0.4, 0.18744421005249023, 0.6697578430175781, -0.1335582733154297, 0.26509734988212585, 0.6017005443572998, 0.45074042677879333, -0.60374915599823 },
				{ 0.4344444444444444, 0.47224998474121094, 0.5395212173461914, -0.14186477661132812, 0.501652717590332, 0.38402730226516724, 0.6559701561927795, -0.41300228238105774 },
				{ 0.4688888888888889, 0.6287374496459961, 0.37209606170654297, -0.1568460464477539, 0.595258891582489, 0.3041270971298218, 0.7174966335296631, -0.1958882063627243 },
				{ 0.5033333333333333, 0.7189946174621582, 0.19403839111328125, -0.18490982055664062, 0.6328988075256348, 0.2740766406059265, 0.7237278819084167, -0.023218171671032906 } } },



		push = { damage_window_start = 0.05, anim_end_event = "attack_finished", outer_push_angle = 180, kind = "push_stagger", no_damage_impact_sound_event = "slashing_hit_armour", attack_template = "basic_sweep_push", damage_profile_outer = "light_push", weapon_action_hand = "right", push_angle = 100, hit_effect = "melee_hit_hammers_1h", damage_window_end = 0.2, impact_sound_event = "slashing_hit", charge_value = "action_push", dedicated_target_range = 2, anim_event = "attack_push", damage_profile_inner = "medium_push", total_time = 0.8,


			anim_end_event_condition_func = function (unit, end_reason)
				return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
			end,


			buff_data = {
				{ start_time = 0, external_multiplier = 1.25, end_time = 0.2, buff_name = "planted_fast_decrease_movement" } },








			allowed_chain_actions = { { sub_action = "default", start_time = 0.3, action = "action_one", release_required = "action_two_hold", input = "action_one" },
				{ sub_action = "default", start_time = 0.3, action = "action_one", release_required = "action_two_hold", doubleclick_window = 0, input = "action_one_hold" },
				{ sub_action = "light_attack_bopp", start_time = 0.3, action = "action_one", doubleclick_window = 0, end_time = 0.8, input = "action_one_hold",
					hold_required = { "action_two_hold", "action_one_hold" } }, { sub_action = "default", start_time = 0.3, action = "action_two", send_buffer = true, input = "action_two_hold" },
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








			allowed_chain_actions = { { sub_action = "default", start_time = 0.2, action = "action_wield", input = "action_wield" },
				{ sub_action = "push", start_time = 0.2, action = "action_one", doubleclick_window = 0, input = "action_one",
					hold_required = { "action_two_hold" } }, { sub_action = "default", start_time = 0.2, action = "action_one", release_required = "action_two_hold", doubleclick_window = 0, input = "action_one" } } } },





	action_inspect = ActionTemplates.action_inspect,
	action_wield = ActionTemplates.wield }


weapon_template.right_hand_unit = "units/weapons/player/wpn_empire_short_sword/wpn_empire_short_sword"
weapon_template.right_hand_attachment_node_linking = AttachmentNodeLinking.one_handed_melee_weapon.right
weapon_template.display_unit = "units/weapons/weapon_display/display_1h_axes"
weapon_template.wield_anim = "to_1h_hammer"
weapon_template.state_machine = "units/beings/player/first_person_base/state_machines/melee/1h_hammer"
weapon_template.buff_type = "MELEE_1H"
weapon_template.weapon_type = "MACE_1H"
weapon_template.max_fatigue_points = 9
weapon_template.dodge_count = 3
weapon_template.block_angle = 90
weapon_template.outer_block_angle = 360
weapon_template.block_fatigue_point_multiplier = 0.5
weapon_template.outer_block_fatigue_point_multiplier = 2
weapon_template.sound_event_block_within_arc = "weapon_foley_blunt_1h_block_wood"
weapon_template.buffs = {
	change_dodge_distance = { external_optional_multiplier = 1.2 },
	change_dodge_speed = { external_optional_multiplier = 1.2 } }



weapon_template.attack_meta_data = {
	tap_attack = { penetrating = false, arc = 2 },



	hold_attack = { penetrating = true, arc = 0 } }




weapon_template.aim_assist_settings = { max_range = 5, no_aim_input_multiplier = 0, vertical_only = true, base_multiplier = 0, effective_max_range = 4,





	breed_scalars = { skaven_storm_vermin = 1, skaven_clan_rat = 1, skaven_slave = 1 } }






weapon_template.weapon_diagram = {
	light_attack = {
		[DamageTypes.ARMOR_PIERCING] = 2,
		[DamageTypes.CLEAVE] = 3,
		[DamageTypes.SPEED] = 3,
		[DamageTypes.STAGGER] = 4,
		[DamageTypes.DAMAGE] = 2 },

	heavy_attack = {
		[DamageTypes.ARMOR_PIERCING] = 5,
		[DamageTypes.CLEAVE] = 0,
		[DamageTypes.SPEED] = 3,
		[DamageTypes.STAGGER] = 3,
		[DamageTypes.DAMAGE] = 4 } }



weapon_template.tooltip_keywords = { "weapon_keyword_fast_attacks", "weapon_keyword_wide_sweeps", "weapon_keyword_crowd_control" }





weapon_template.tooltip_compare = {
	light = { action_name = "action_one", sub_action_name = "light_attack_01" },



	heavy = { action_name = "action_one", sub_action_name = "heavy_attack_01" } }





weapon_template.tooltip_detail = {
	light = { action_name = "action_one", sub_action_name = "default" },



	heavy = { action_name = "action_one", sub_action_name = "default" },



	push = { action_name = "action_one", sub_action_name = "push" } }






weapon_template.wwise_dep_right_hand = { "wwise/one_handed_hammers" }





return { one_handed_hammer_priest_template = weapon_template }