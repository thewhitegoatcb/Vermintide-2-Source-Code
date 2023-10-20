CrawlSpaceExtension = class(CrawlSpaceExtension)


function CrawlSpaceExtension:init(extension_init_context, unit, extension_init_data)
	self.unit = unit
	self.partner_unit = nil
	self.entrance_type = Unit.get_data(unit, "entrance_type")

	local pos = Unit.local_position(unit, 0)
	local rotation = Unit.local_rotation(unit, 0)

	if self.entrance_type == "manhole" or self.entrance_type == "well" then
		rotation = Quaternion.multiply(rotation, Quaternion.from_euler_angles_xyz(90, 0, 0))
	end

	local look_dir = Vector3.flat(Quaternion.forward(rotation))
	self.enter_rot = Vector3Box(look_dir)
	self.enter_pos = Vector3Box(pos - look_dir + Vector3.down())
	self.entrance_type = Unit.get_data(unit, "entrance_type")
	self.id = Unit.get_data(unit, "crawl_space_id")
	self.type = self.id == 0 and "spawner" or "tunnel"
end

function CrawlSpaceExtension:extensions_ready()
	if self.entrance_type == "chimney" then
		local interactable_extension = ScriptUnit.extension(self.unit, "interactable_system")
		interactable_extension:set_enabled(false)
	end
end

function CrawlSpaceExtension:update(unit, input, dt, context, t)
	return end

function CrawlSpaceExtension:hot_join_sync(sender)
	return end

function CrawlSpaceExtension:destroy()
	self.unit = nil
	self.partner_unit = nil
end