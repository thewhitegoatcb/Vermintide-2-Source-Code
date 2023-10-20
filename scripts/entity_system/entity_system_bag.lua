EntitySystemBag = class()

function EntitySystemBag:init()
	self.systems = { }
	self.num_systems = 0
	self.systems_update = { }
	self.systems_pre_update = { }
	self.systems_post_update = { }
	self.systems_physics_async_update = { }
end

function EntitySystemBag:destroy()
	local systems = self.systems
	for i = 1, #systems do
		local system = systems [i]
		system:destroy()
		table.clear(system)
	end
	self.systems = nil
	self.systems_update = nil
	self.systems_pre_update = nil
	self.systems_post_update = nil
	self.systems_physics_async_update = nil
end

function EntitySystemBag:add_system(system, block_pre_update, block_post_update)
	self.systems [#self.systems + 1] = system
	if system.update then
		self.systems_update [#self.systems_update + 1] = system
	end
	if system.pre_update and not block_pre_update then
		self.systems_pre_update [#self.systems_pre_update + 1] = system
	end
	if system.post_update and not block_post_update then
		self.systems_post_update [#self.systems_post_update + 1] = system
	end
	if system.physics_async_update then
		self.systems_physics_async_update [#self.systems_physics_async_update + 1] = system
	end
end

local list_name_by_function = { pre_update = "systems_pre_update", update = "systems_update", physics_async_update = "systems_physics_async_update", post_update = "systems_post_update" }






function EntitySystemBag:update(entity_system_update_context, update_function)
	local update_function_list_name = list_name_by_function [update_function]
	local update_list = self [update_function_list_name]
	local t = entity_system_update_context.t
	for i = 1, #update_list do
		local system = update_list [i]

		system [update_function](system, entity_system_update_context, t)
	end

end

function EntitySystemBag:hot_join_sync(peer_id)

	for i, system in ipairs(self.systems) do
		if system.hot_join_sync then

			system:hot_join_sync(peer_id)
		end
	end


end