DiceKeeper = class(DiceKeeper)

function DiceKeeper:init(num_normal)
	self._dice = { gold = 0, metal = 0, warpstone = 0,
		wood = num_normal }




	self._new_dice = { }

end

function DiceKeeper:register_rpcs(network_event_delegate)
	self._network_event_delegate = network_event_delegate
end

function DiceKeeper:unregister_rpc()
	self._network_event_delegate = nil
end

function DiceKeeper:get_dice()
	return self._dice
end

function DiceKeeper:num_dices(die_type)
	return self._dice [die_type]
end

function DiceKeeper:num_new_dices(die_type)
	return self._new_dice [die_type] or 0
end

function DiceKeeper:add_die(die_type, amount)
	Managers.state.debug_text:output_screen_text(string.format("Awarded %d extra die/dice of type %s", amount, die_type), 42, 5)
	self._dice [die_type] = self._dice [die_type] + amount
	self._dice.wood = self._dice.wood - amount
	self._new_dice [die_type] = ( self._new_dice [die_type] or 0 ) + 1
end

function DiceKeeper:bonus_dice_spawned()
	self._bonus_dice_spawned = self._bonus_dice_spawned and self._bonus_dice_spawned + 1 or 1
end

function DiceKeeper:num_bonus_dice_spawned()
	return self._bonus_dice_spawned or 0
end

function DiceKeeper:chest_loot_dice_chance()
	return self._chest_loot_dice_chance or 0.05
end

function DiceKeeper:calculcate_loot_die_chance_on_remaining_chests(percentage_chests_left)
	if percentage_chests_left > 0 then
		self._chest_loot_dice_chance = 0.05 * 1 / percentage_chests_left
	end
end