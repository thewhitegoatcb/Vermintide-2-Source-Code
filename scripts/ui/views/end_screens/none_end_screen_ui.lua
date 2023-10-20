require("scripts/ui/views/end_screens/base_end_screen_ui")
local definitions = local_require("scripts/ui/views/end_screens/none_end_screen_ui_definitions")

NoneEndScreenUI = class(NoneEndScreenUI, BaseEndScreenUI)

function NoneEndScreenUI:init(ingame_ui_context, input_service, screen_context, params)
	NoneEndScreenUI.super.init(self, ingame_ui_context, input_service, definitions, params)
end

function NoneEndScreenUI:_start()
	self:_on_completed()
end