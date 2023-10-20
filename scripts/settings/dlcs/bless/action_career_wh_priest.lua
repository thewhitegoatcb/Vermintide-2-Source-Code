ActionCareerWHPriest = class(ActionCareerWHPriest, ActionBase)

local spell_data = { "victor_priest_activated_ability_invincibility", "victor_priest_activated_ability_nuke" }



local spell_data_improved = { "victor_priest_activated_ability_invincibility_improved", "victor_priest_activated_ability_nuke_improved", "victor_priest_activated_noclip_improved" }





function ActionCareerWHPriest:init(world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	ActionCareerWHPriest.super.init(self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	self.owner_unit = owner_unit
	self.career_extension = ScriptUnit.extension(owner_unit, "career_system")
	self.input_extension = ScriptUnit.extension(owner_unit, "input_system")
	self.inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	self.status_extension = ScriptUnit.extension(owner_unit, "status_system")
	self.first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")
	self.talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	self.world = world
end

function ActionCareerWHPriest:client_owner_start_action(new_action, t, chain_action_data, power_level, action_init_data)
	action_init_data = action_init_data or { }
	ActionCareerWHPriest.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)

	local spell_target = chain_action_data and chain_action_data.target
	if new_action.target_self and not self.is_bot then
		spell_target = self.owner_unit
	end
	if ALIVE [spell_target] then
		local current_spell = spell_data
		if self.talent_extension:has_talent("victor_priest_6_1") then
			current_spell = spell_data_improved
		end

		self:_cast_spells(current_spell, spell_target)
		self.career_extension:start_activated_ability_cooldown()

		CharacterStateHelper.play_animation_event(self.owner_unit, "witch_hunter_active_ability")
		self:_play_vo()
	end
end

function ActionCareerWHPriest:client_owner_post_update(dt, t, world, can_damage, current_time_in_action)
	return end

function ActionCareerWHPriest:finish(reason)
	ActionCareerWHPriest.super.finish(self, reason)
	self.inventory_extension:wield_previous_non_level_slot()
end

function ActionCareerWHPriest:_play_vo()
	local owner_unit = self.owner_unit
	local dialogue_input = ScriptUnit.extension_input(owner_unit, "dialogue_system")
	local event_data = FrameTable.alloc_table()
	dialogue_input:trigger_networked_dialogue_event("activate_ability", event_data)

	local first_person_extension = self.first_person_extension
	local audio_event = "career_ability_priest_cast_t3"
	first_person_extension:play_hud_sound_event(audio_event)
	first_person_extension:play_remote_unit_sound_event(audio_event, owner_unit, 0)
end

function ActionCareerWHPriest:_cast_spells(spell_data, target)
	local owner_unit = self.owner_unit
	local talent_extension = self.talent_extension

	self:_add_buffs_to_target(spell_data, target)

	if talent_extension:has_talent("victor_priest_6_2") then
		if target ~= owner_unit then
			self:_add_buffs_to_target(spell_data, owner_unit)
		else
			local side = Managers.state.side.side_by_unit [owner_unit]
			if not side then
				return
			end
			local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
			local num_units = #player_and_bot_units
			local current_min_dist = math.huge
			local current_target = nil
			local owner_position = POSITION_LOOKUP [owner_unit]
			for i = 1, num_units do
				local unit = player_and_bot_units [i]
				if ALIVE [unit] and unit ~= owner_unit then
					local unit_position = POSITION_LOOKUP [unit]
					local dist_squared = Vector3.distance_squared(owner_position, unit_position)
					if dist_squared < current_min_dist then
						current_min_dist = dist_squared
						current_target = unit
					end
				end
			end
			self:_add_buffs_to_target(spell_data, current_target)
		end
	end
end

function ActionCareerWHPriest:_add_buffs_to_target(buffs_to_add, target)
	if ALIVE [target] then
		local owner_unit = self.owner_unit
		local buff_system = Managers.state.entity:system("buff_system")
		for i = 1, #buffs_to_add do
			local buff_name = buffs_to_add [i]
			buff_system:add_buff(target, buff_name, owner_unit)
		end
	end
end