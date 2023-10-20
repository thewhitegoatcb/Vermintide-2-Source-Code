require("scripts/ui/reward_popup/reward_popup_ui")

local UNLOCK_MANAGER_POLL_INTERVAL = 1.5

GiftPopupUI = class(GiftPopupUI)

function GiftPopupUI:init(parent, ingame_ui_context)
	self._parent = parent
	self._is_in_inn = ingame_ui_context.is_in_inn

	local reward_popup = RewardPopupUI:new(ingame_ui_context)
	self._reward_popup = reward_popup
	reward_popup:set_input_manager(ingame_ui_context.input_manager)


	self._next_poll_time = 0
	self._presentation_queue = { }

	local event_manager = Managers.state.event
	event_manager:register(self, "level_start_local_player_spawned", "event_initialize_poll")
end

function GiftPopupUI:event_initialize_poll()
	self._poll_initialized = true
end

function GiftPopupUI:update(dt, t)

	return end

function GiftPopupUI:post_update(dt, t)
	local reward_popup = self._reward_popup
	local presentation_queue = self._presentation_queue

	if self._poll_initialized and self._is_in_inn then
		local next_poll_time = self._next_poll_time

		if next_poll_time <= t then
			self._next_poll_time = t + UNLOCK_MANAGER_POLL_INTERVAL

			while true do
				local reward_data = Managers.unlock:poll_rewards()
				if not reward_data then break end
				presentation_queue [#presentation_queue + 1] = self:_generate_presentation_data(reward_data)
			end
		end

		if #presentation_queue > 0 and self:_can_present_reward() then
			local presentation_data = table.remove(presentation_queue, 1)
			reward_popup:display_presentation(presentation_data)
		end

		reward_popup:update(dt)
	end
end

function GiftPopupUI:has_presentation_data()
	return #self._presentation_queue > 0 or self._reward_popup:is_presentation_active()
end

function GiftPopupUI:_can_present_reward()
	if self._reward_popup:is_presentation_active() then
		return false
	end

	local popup_manager = Managers.popup
	if popup_manager and popup_manager:has_popup() then
		return false
	end

	if not Managers.transition:fade_out_completed() then
		return false
	end

	return true
end

function GiftPopupUI:_generate_presentation_data(reward_data)
	local presentation_data = {




		{ { widget_type = "description",

				value = {
					Localize(reward_data.presentation_text),
					Localize("gift_popup_sub_title_halloween") } },


			{ widget_type = "item_list",

				value = reward_data.items } }, animation_data = { claim_button = true } }






















	return presentation_data
end

function GiftPopupUI:active()
	return self._reward_popup:is_presentation_active()
end

function GiftPopupUI:active_input_service()
	return self._reward_popup:input_service()
end

function GiftPopupUI:destroy()
	self._reward_popup:destroy()
	self._reward_popup = nil
	self._presentation_queue = nil
end