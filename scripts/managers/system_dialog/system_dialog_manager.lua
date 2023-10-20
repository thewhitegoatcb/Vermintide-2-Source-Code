SystemDialogManager = class(SystemDialogManager)

local function dprint(...)

	print("[SystemDialogManager]", ...)

end

function SystemDialogManager:init()
	self._dialogs = { }
	self._virtual_keyboards = { }
	self._virtual_keyboard_results = { }
	self._virtual_keyboard_index = 0
end

function SystemDialogManager:destroy()
	return end

function SystemDialogManager:update(dt)
	self:_handle_dialogs()
end

function SystemDialogManager:check_status(dialog_instance)
	local data = nil
	if #self._dialogs > 0 then
		data = self._dialogs [1]
	end

	local status = nil
	if data then
		status = self:_get_status(dialog_instance)
	end

	return status
end

function SystemDialogManager:_get_status(dialog_instance)
	local status = dialog_instance.update()
	return status
end

function SystemDialogManager:_initialize(dialog_instance)
	local result = dialog_instance.initialize()
	if result ~= PS4.SCE_OK then
		dprint("Failed to initialize " .. dialog_instance._name)
		return
	end
	return true
end

function SystemDialogManager:_terminate(dialog_instance)
	local result = dialog_instance.terminate()
	if result ~= PS4.SCE_OK then
		dprint("Failed to terminate " .. dialog_instance._name)
		return
	end
	return true
end

function SystemDialogManager:_handle_dialogs()
	local data = nil

	if #self._dialogs > 0 then
		data = self._dialogs [1]
	end

	if data then
		local dialog_instance = data.dialog_instance
		local status = self:_get_status(dialog_instance)

		self:_abort_virtual_keyboard()

		if status == dialog_instance.NONE then

			self:_initialize(dialog_instance)

		elseif status == dialog_instance.INITIALIZED then
			local result = data:open()

			if result then
				if result == PS4.SCE_OK then
					dprint("Opened dialog")
				else
					dprint("Failed to open dialog")
				end
			end
		elseif status == dialog_instance.RUNNING then --[[ Nothing --]]
		elseif status == dialog_instance.FINISHED then
			if data.callback then
				data.callback(status)
			end
			if self:_terminate(dialog_instance) then
				table.remove(self._dialogs, 1)
			end
		end
	end

	self:_handle_virtual_keyboards()
end

function SystemDialogManager:_handle_virtual_keyboards()
	local current_virtual_keyboard = self._virtual_keyboards [1]
	if current_virtual_keyboard then
		local activated = current_virtual_keyboard.activated
		if activated then
			if PS4ImeDialog.is_finished() then
				local result, text = PS4ImeDialog.close()
				local aborted = current_virtual_keyboard.aborted
				if aborted then
					current_virtual_keyboard.aborted = nil
					current_virtual_keyboard.activated = false
				else
					local index = current_virtual_keyboard.index
					local data = self._virtual_keyboard_results [index]
					if data then
						data.text = result == PS4ImeDialog.END_STATUS_OK and text or current_virtual_keyboard.text
						data.done = true
						data.success = result == PS4ImeDialog.END_STATUS_OK
					end

					table.remove(self._virtual_keyboards, 1)
				end
			end
		elseif not Managers.account:user_detached() and not self:has_open_dialogs() then
			table.dump(current_virtual_keyboard, "Virtual Keyboard", 3)
			PS4ImeDialog.show(current_virtual_keyboard)
			current_virtual_keyboard.activated = true
		end
	end
end

function SystemDialogManager:_abort_virtual_keyboard()
	local current_virtual_keyboard = self._virtual_keyboards [1]
	if
	current_virtual_keyboard and current_virtual_keyboard.activated then
		if PS4ImeDialog.is_showing() then
			PS4ImeDialog.abort()
		end
		current_virtual_keyboard.aborted = true
	end

end

function SystemDialogManager:open_system_dialog(message, user_id)
	local function open(data)
		local dialog_instance = data.dialog_instance
		dprint("open_system_dialog", unpack(data.params))
		return dialog_instance.open(unpack(data.params))
	end

	local params = { message, user_id }
	self._dialogs [#self._dialogs + 1] = { dialog_instance = MsgDialog, params = params, open = open }
end

function SystemDialogManager:open_save_dialog(required_blocks)
	local function open(data)
		local dialog_instance = data.dialog_instance
		dprint("open_save_dialog", data.required_blocks)
		return dialog_instance.open(data.required_blocks)
	end

	self._dialogs [#self._dialogs + 1] = { dialog_instance = SaveSystemDialog, required_blocks = required_blocks, open = open }
end

function SystemDialogManager:open_commerce_dialog(mode, user_id, targets)
	local function open(data)
		local dialog_instance = data.dialog_instance
		local targets = data.targets
		dprint("open_commerce_dialog", mode, user_id, targets and unpack(targets))
		return dialog_instance.open2(data.mode, data.user_id, targets and unpack(targets))
	end

	self._dialogs [#self._dialogs + 1] = { dialog_instance = NpCommerceDialog, mode = mode, user_id = user_id, targets = targets, open = open }
end

function SystemDialogManager:open_error_dialog(error_code, callback)
	local function open(data)
		local dialog_instance = data.dialog_instance
		dprint("open_error_dialog", data.error_code)
		return dialog_instance.open(data.error_code)
	end

	self._dialogs [#self._dialogs + 1] = { dialog_instance = ErrorDialog, error_code = error_code, open = open, callback = callback }
end

function SystemDialogManager:open_virtual_keyboard(user_id, optional_title, optional_prefilled_text, optional_position, optional_max_length)
	fassert(user_id, "[SystemDialogManager] You need to provide a user_id")

	self._virtual_keyboard_index = self._virtual_keyboard_index + 1
	self._virtual_keyboards [#self._virtual_keyboards + 1] = { activated = false,
		user_id = user_id,
		title = optional_title,
		text = optional_prefilled_text,
		x = optional_position and optional_position [1],
		y = optional_position and optional_position [2],
		max_length = optional_max_length,
		index = self._virtual_keyboard_index }


	self._virtual_keyboard_results [self._virtual_keyboard_index] = { success = false, done = false,


		text = optional_prefilled_text or "" }


	return self._virtual_keyboard_index
end

function SystemDialogManager:poll_virtual_keyboard(index)
	local data = self._virtual_keyboard_results [index]
	if data and data.done then
		self._virtual_keyboard_results [index] = nil

		return data.done, data.success, data.text
	end

	return false
end

function SystemDialogManager:has_open_dialogs()
	return #self._dialogs > 0
end