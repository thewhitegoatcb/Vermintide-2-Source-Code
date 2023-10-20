










require("scripts/ui/dlc_upsell/common_popup_settings")
require("scripts/ui/dlc_upsell/unlock_reminder_popup")
require("scripts/ui/dlc_upsell/upsell_popup")

CommonPopupHandler = class(CommonPopupHandler)


function CommonPopupHandler:init(context)
	self._context = context
	self._popups = { }
	self._n_popups = 0
	self._popup_ids = 0

	local menu_active = context.ingame_ui.menu_active or
	context.ingame_ui.current_view or
	context.ingame_ui._transition_fade_data

	self._menu_active = menu_active
	Managers.state.event:register(self, "ui_show_popup", "ui_show_popup")
end


function CommonPopupHandler:destroy()
	Managers.state.event:unregister("ui_show_popup", self)
	for i = 1, self._n_popups do
		local popup = self._popups [i]
		if popup then
			popup:destroy()
			self._popups [i] = nil
		end
	end
end


function CommonPopupHandler:update(dt, t)
	local popup = self._popups [self._n_popups]
	if not popup then return
	end
	local managers_state = Managers.state
	if managers_state and managers_state.voting:vote_in_progress() and Managers.popup:has_popup() then
		popup:hide()
		return
	end

	local current_menu_active = self:_is_menu_active()
	if self._menu_active ~= current_menu_active and popup:is_popup_showing() then
		self._menu_active = current_menu_active
		popup:hide()
		return
	end

	popup:update(dt)

	if popup:exit_done() then
		popup:delete()
		self._popups [self._n_popups] = nil
		self._n_popups = self._n_popups - 1
	end
end

function CommonPopupHandler:queue_popup(ui_popup)
	local n_popups = self._n_popups local popups = self._popups
	n_popups = n_popups + 1
	self._n_popups = n_popups

	self._popup_ids = self._popup_ids + 1
	local popup_id = tostring(self._popup_ids)
	ui_popup.popup_id = popup_id




	if n_popups > 1 then
		local previous_popup_showing = popups [n_popups - 1]:is_popup_showing()
		if previous_popup_showing then
			table.insert(popups, 1, ui_popup)
			self._popups = popups
			return popup_id
		end
	end

	popups [n_popups] = ui_popup
	self._popups = popups
	return popup_id
end

function CommonPopupHandler:ui_show_popup(dlc_name, type)

	local popup_settings = CommonPopupSettings [dlc_name]
	if not popup_settings then
		printf("No popup settings for DLC %q", dlc_name)
		return
	end

	if popup_settings.popup_type == type then
		self:new_popup(dlc_name, popup_settings)
		return
	end
end

function CommonPopupHandler:new_popup(dlc_name, popup_settings)
	local popup_class = rawget(_G, popup_settings.class_name)
	local popup = popup_class:new(self._context, dlc_name, popup_settings)
	self:queue_popup(popup)
end

function CommonPopupHandler:_is_menu_active()
	return self._context.ingame_ui.menu_active or
	self._context.ingame_ui.current_view or
	self._context.ingame_ui._transition_fade_data
end