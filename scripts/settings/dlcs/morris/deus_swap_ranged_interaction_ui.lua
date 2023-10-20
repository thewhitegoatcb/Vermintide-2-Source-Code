require("scripts/settings/dlcs/morris/deus_swap_weapon_interaction_ui")

DeusSwapRangedInteractionUI = class(DeusSwapRangedInteractionUI, DeusSwapWeaponInteractionUI)

DeusSwapRangedInteractionUI.TYPE = "swap_ranged"

function DeusSwapRangedInteractionUI:init(parent, ingame_ui_context)
	DeusSwapRangedInteractionUI.super.init(self, parent, ingame_ui_context)

	self._type = "ranged"
end

function DeusSwapRangedInteractionUI:chest_unlock_failed(chest_type)
	if chest_type == DeusSwapRangedInteractionUI.TYPE then
		self:_start_animation("chest_unlock_failed")
	end
end