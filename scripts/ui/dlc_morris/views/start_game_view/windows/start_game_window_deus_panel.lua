



local definitions = local_require("scripts/ui/dlc_morris/views/start_game_view/windows/definitions/start_game_window_deus_panel_definitions")

StartGameWindowDeusPanel = class(StartGameWindowDeusPanel, StartGameWindowPanelConsole)
StartGameWindowDeusPanel.NAME = "StartGameWindowDeusPanel"

function StartGameWindowDeusPanel:_create_ui_elements(_, params, offset)
	return StartGameWindowDeusPanel.super._create_ui_elements(self, definitions, params, offset)
end