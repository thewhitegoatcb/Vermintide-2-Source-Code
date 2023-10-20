require("core/gwnav/lua/safe_require")
local NavTagVolume = safe_require_guard()

local NavClass = safe_require("core/gwnav/lua/runtime/navclass")
NavTagVolume = NavClass(NavTagVolume)

local GwNavTagVolume = stingray.GwNavTagVolume

function NavTagVolume:init(world, point_table, alt_min, alt_max, is_exclusive, color, layer_id, smartobject_id, user_data_id)
	self.nav_tagvolume = GwNavTagVolume.create(world, point_table, alt_min, alt_max, is_exclusive, color, layer_id, smartobject_id, user_data_id)
end

function NavTagVolume:shutdown()
	GwNavTagVolume.destroy(self.nav_tagvolume)
	self.nav_tagvolume = nil
end

function NavTagVolume:add_to_world()
	GwNavTagVolume.add_to_world(self.nav_tagvolume)
end

function NavTagVolume:remove_from_world()
	GwNavTagVolume.remove_from_world(self.nav_tagvolume)
end

return NavTagVolume