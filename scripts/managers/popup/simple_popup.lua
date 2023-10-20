









SimplePopup = class(SimplePopup)

function SimplePopup:init()
	self._tracked_popups = { }
end

function SimplePopup:queue_popup(text, topic, ...)
	local id = Managers.popup:queue_popup(text, topic, ...)
	self._tracked_popups [#self._tracked_popups + 1] = id
end

function SimplePopup:update(dt)
	local manager = Managers.popup


	local first = self._tracked_popups [1]
	if first and not manager:has_popup_with_id(first) then
		table.remove(self._tracked_popups, 1)
	end


	for i, v in ipairs(self._tracked_popups) do
		local result = manager:query_result(v)
		if result ~= nil then
			table.remove(self._tracked_popups, i)
		end
	end
end

function SimplePopup:destroy()
	return end