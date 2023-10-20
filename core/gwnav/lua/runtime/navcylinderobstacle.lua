require("core/gwnav/lua/safe_require")
local NavCylinderObstacle = safe_require_guard()

local NavClass = safe_require("core/gwnav/lua/runtime/navclass")
NavCylinderObstacle = NavClass(NavCylinderObstacle)

local NavHelpers = safe_require("core/gwnav/lua/runtime/navhelpers")

local Math = stingray.Math
local Vector3 = stingray.Vector3
local Vector3Box = stingray.Vector3Box
local Matrix4x4 = stingray.Matrix4x4
local Matrix4x4Box = stingray.Matrix4x4Box

local Unit = stingray.Unit

local GwNavWorld = stingray.GwNavWorld
local GwNavCylinderObstacle = stingray.GwNavCylinderObstacle

local _navcylinderobstacles = { }

function NavCylinderObstacle.get_navcylinderostacle(unit)
	return _navcylinderobstacles [unit]
end

function NavCylinderObstacle:init(navworld, unit)
	self.unit = unit
	self.navworld = navworld
	local radius = NavHelpers.unit_script_data(unit, 0.5, "GwNavCylinderObstacle", "radius")
	local height = NavHelpers.unit_script_data(unit, 2, "GwNavCylinderObstacle", "height")
	local is_exclusive, color, layer_id, smartobject_id, user_data_id = NavHelpers.get_layer_and_smartobject(unit, "GwNavCylinderObstacle")
	local position = Matrix4x4.transform(navworld.transform:unbox(), Unit.world_position(unit, 1))

	self.lastpos = Vector3Box(position)
	self.nav_cylinderobstacle = GwNavCylinderObstacle.create(self.navworld.gwnavworld, position, height, radius, is_exclusive, color, layer_id, smartobject_id, user_data_id)
	self.does_trigger_tag_volume = NavHelpers.unit_script_data(unit, false, "GwNavCylinderObstacle", "does_trigger_tag_volume")
	self:set_does_trigger_tagvolume(self.does_trigger_tag_volume)

	_navcylinderobstacles [self.unit] = self
end

function NavCylinderObstacle:set_does_trigger_tagvolume(does_trigger_tag_volume)
	GwNavCylinderObstacle.set_does_trigger_tagvolume(self.nav_cylinderobstacle, does_trigger_tag_volume)
end

function NavCylinderObstacle:set_next_update_config(position, velocity)
	GwNavCylinderObstacle.set_position(self.nav_cylinderobstacle, position)
	GwNavCylinderObstacle.set_velocity(self.nav_cylinderobstacle, velocity)
end

function NavCylinderObstacle:update(dt)
	local pos = Unit.world_position(self.unit, 1)
	local velocity = ( pos - self.lastpos:unbox() ) / dt
	self:set_does_trigger_tagvolume(does_trigger_tag_volume and Vector3.length(velocity) == 0)
	self:set_next_update_config(pos, velocity)
	self.lastpos:store(pos)
end

function NavCylinderObstacle:shutdown()
	self.navworld:remove_cylinderobstacle(self.unit)
	GwNavCylinderObstacle.destroy(self.nav_cylinderobstacle)
	self.nav_cylinderobstacle = nil
	_navcylinderobstacles [self.unit] = nil
end

function NavCylinderObstacle:add_to_world()
	GwNavCylinderObstacle.add_to_world(self.nav_cylinderobstacle)
end

function NavCylinderObstacle:remove_from_world()
	GwNavCylinderObstacle.remove_from_world(self.nav_cylinderobstacle)
end

return NavCylinderObstacle