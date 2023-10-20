require("scripts/helpers/deus_power_up_utils")
require("scripts/ui/dlc_morris/views/end_screen/deus_journey_presentation_ui")
require("scripts/ui/views/end_screens/base_end_screen_ui")

local definitions = local_require("scripts/ui/views/end_screens/deus_victory_end_screen_ui_definitions")

local states = { DONE = "DONE", WAITING_TO_START = "WAITING_TO_START", PRESENTING_JOURNEY = "PRESENTING_JOURNEY" }





DeusVictoryEndScreenUI = class(DeusVictoryEndScreenUI, BaseEndScreenUI)

function DeusVictoryEndScreenUI:init(ingame_ui_context, input_service, screen_context)
	DeusVictoryEndScreenUI.super.init(self, ingame_ui_context, input_service, definitions)

	fassert(screen_context.journey_name, "No journey_name set in screen_context")
	self._journey_name = screen_context.journey_name

	fassert(screen_context.profile_index, "No profile_index set in screen_context")
	self._profile_index = screen_context.profile_index

	fassert(screen_context.previous_completed_difficulty_index, "No previous_completed_difficulty_index set in screen_context")
	self._previous_completed_difficulty_index = screen_context.previous_completed_difficulty_index

	self._journey_presentation_ui = DeusJourneyPresentationUI:new(ingame_ui_context)

	self:_play_sound("play_gui_splash_victory")

	self._state = states.WAITING_TO_START
end

function DeusVictoryEndScreenUI:_destroy()
	if self._journey_presentation_ui then
		self._journey_presentation_ui:destroy()
		self._journey_presentation_ui = nil
	end
end

function DeusVictoryEndScreenUI:_start()
	local scenegraph_definition = definitions.scenegraph_definition
	local params = { draw_flags = self._draw_flags, wwise_world = self._wwise_world }

	self._victory_anim_id = self._ui_animator:start_animation("victory", self._widgets_by_name, scenegraph_definition, params)

	if self._journey_presentation_ui then
		self._journey_presentation_ui:start(self._journey_name, self._previous_completed_difficulty_index)

		self._state = states.PRESENTING_JOURNEY
	end
end

function DeusVictoryEndScreenUI:_update(dt)
	if self._completed then
		return
	end

	if self._victory_anim_id and
	self._ui_animator:is_animation_completed(self._victory_anim_id) then
		self._victory_anim_id = nil
	end


	if self._state == states.PRESENTING_JOURNEY then

		local journey_presentation_ui = self._journey_presentation_ui
		if journey_presentation_ui and journey_presentation_ui.active then
			journey_presentation_ui:update(dt)
		end

		local journey_presentation_done = not journey_presentation_ui or journey_presentation_ui:presentation_completed()

		if journey_presentation_done then

			self._state = states.DONE
		end

	elseif self._state == states.DONE and

	self._victory_anim_id == nil then
		self:_on_completed()
	end


end