
local PlayFabClientApi = require("PlayFab.PlayFabClientApi")

BackendInterfaceKeepDecorationsPlayFab = class(BackendInterfaceKeepDecorationsPlayFab)

function BackendInterfaceKeepDecorationsPlayFab:init(backend_mirror)
	self._backend_mirror = backend_mirror
	self._keep_decorations = { }

	local keep_decorations = backend_mirror:get_read_only_data("keep_decorations") or "{}"
	self._keep_decorations = cjson.decode(keep_decorations)

	self:_refresh()

	for slot_name, painting in pairs(self._keep_decorations) do
		if
		painting ~= "hidden" and painting ~= "hor_none" and not table.contains(self._unlocked_keep_decorations, painting) then
			self._keep_decorations [slot_name] = "hor_none"
		end
	end

end

function BackendInterfaceKeepDecorationsPlayFab:dirtify()
	self._dirty = true
end

function BackendInterfaceKeepDecorationsPlayFab:ready()
	return true
end

function BackendInterfaceKeepDecorationsPlayFab:_refresh()
	local mirror = self._backend_mirror
	local unlocked_keep_decorations = mirror:get_unlocked_keep_decorations()

	self._unlocked_keep_decorations = unlocked_keep_decorations

	local new_keep_decoration_ids = ItemHelper.get_new_keep_decoration_ids()
	if new_keep_decoration_ids then
		for keep_decoration_id, _ in pairs(new_keep_decoration_ids) do
			if not unlocked_keep_decorations [keep_decoration_id] then
				ItemHelper.unmark_keep_decoration_as_new(keep_decoration_id)
			end
		end
	end
end

function BackendInterfaceKeepDecorationsPlayFab:update(dt)
	return end

function BackendInterfaceKeepDecorationsPlayFab:get_decoration(slot_name)
	return self._keep_decorations [slot_name]
end

function BackendInterfaceKeepDecorationsPlayFab:set_decoration(slot_name, item_id)
	self._keep_decorations [slot_name] = item_id
end

function BackendInterfaceKeepDecorationsPlayFab:get_keep_decorations_json()
	return cjson.encode(self._keep_decorations)
end

function BackendInterfaceKeepDecorationsPlayFab:get_unlocked_keep_decorations()
	if self._dirty then
		self:_refresh()
	end

	return self._unlocked_keep_decorations
end