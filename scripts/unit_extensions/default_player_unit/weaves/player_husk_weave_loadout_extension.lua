PlayerHuskWeaveLoadoutExtension = class(PlayerHuskWeaveLoadoutExtension)

function PlayerHuskWeaveLoadoutExtension:init(extension_init_context, unit, extension_init_data)
	self._unit = unit
	self._synced_buff_params = nil
end

function PlayerHuskWeaveLoadoutExtension:destroy()
	self._unit = nil
	self._synced_buff_params = nil
end

function PlayerHuskWeaveLoadoutExtension:add_buffs(num_buffs, buff_ids, buff_data_type_ids, buff_values)
	self._synced_buff_params = { num_buffs, buff_ids, buff_data_type_ids, buff_values }

	local buffs = BuffUtils.buffs_from_rpc_params(num_buffs, buff_ids, buff_data_type_ids, buff_values)
	self:_apply_buffs(buffs)
end

function PlayerHuskWeaveLoadoutExtension:_apply_buffs(buffs)
	local buff_extension = ScriptUnit.extension(self._unit, "buff_system")

	for buff_name, variable_data in pairs(buffs) do
		local params = { }
		for data_type, data_value in pairs(variable_data) do
			params [data_type] = data_value
		end
		buff_extension:add_buff(buff_name, params)
	end
end

function PlayerHuskWeaveLoadoutExtension:hot_join_sync(sender)
	local rpc_params = self._synced_buff_params
	if rpc_params then
		local unit_go_id = Managers.state.unit_storage:go_id(self._unit)
		local channel_id = PEER_ID_TO_CHANNEL [sender]
		RPC.rpc_add_weave_buffs(channel_id, unit_go_id, unpack(rpc_params))
	end
end