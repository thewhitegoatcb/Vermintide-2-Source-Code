require("core/gwnav/lua/safe_require")
local NavDefaultSmartObjectFollower = safe_require_guard()

local NavClass = safe_require("core/gwnav/lua/runtime/navclass")
NavDefaultSmartObjectFollower = NavClass(NavDefaultSmartObjectFollower)

local Math = stingray.Math
local Vector3 = stingray.Vector3
local Vector3Box = stingray.Vector3Box

local Unit = stingray.Unit
local Level = stingray.Level

local GwNavBot = stingray.GwNavBot
local GwNavSmartObjectInterval = stingray.GwNavSmartObjectInterval
local Mover = stingray.Mover

function NavDefaultSmartObjectFollower:init(navbot)
	self.navbot = navbot
	self.free_fall_acceleration = 9.81
	self.jump_start = Vector3Box(0, 0, 0)
	self.jump_target = Vector3Box(0, 0, 0)
	self.jump_height = 1
	self.jump_velocity = Vector3Box(0, 0, 0)
	self.jump_forward = Vector3Box(0, 0, 0)
end

function NavDefaultSmartObjectFollower:initial_jump_velocity()




	local A = self.jump_start:unbox()
	local B = self.jump_target:unbox()



















	local Az = Vector3.z(A)
	local Bz = Vector3.z(B)
	local Cz = math.max(Az, Bz) + self.jump_height
	local v0z = math.sqrt(2 * self.free_fall_acceleration * (Cz - Az))


















	local D = v0z * v0z + 2 * self.free_fall_acceleration * (Az - Bz)
	local tB = ( v0z + math.sqrt(D) ) / self.free_fall_acceleration

	local v0 = B - A
	Vector3.set_z(v0, 0)
	v0 = v0 / tB
	self.jump_forward:store(Vector3.normalize(v0))


	Vector3.set_z(v0, v0z)
	self.jump_velocity:store(v0)
end

function NavDefaultSmartObjectFollower:update_follow(dt)
	local approachingDistance = 0.5

	if Vector3.distance(self.jump_target:unbox(), self.navbot:get_position()) < approachingDistance then
		local exit_manualcontrol = GwNavBot.exit_manual_control(self.navbot.gwnavbot)
		if exit_manualcontrol == true then
			self.navbot.is_smartobject_driven = false
		end
	end
end

function NavDefaultSmartObjectFollower:move_unit(dt)
	local bot_position = self.navbot:get_position()
	local velocity = self.jump_velocity:unbox()
	local forward = self.jump_forward:unbox()
	self.navbot:update_pose(forward, bot_position + velocity * dt)
	self.jump_velocity:store(velocity - Vector3(0, 0, self.free_fall_acceleration) * dt)
end

function NavDefaultSmartObjectFollower:move_unit_with_mover(dt, mover)
	local bot_position = self.navbot:get_position()
	local velocity = self.jump_velocity:unbox()
	local forward = self.jump_forward:unbox()
	Mover.set_position(mover, bot_position + velocity * dt)
	self.navbot:update_pose(forward, Mover.position(mover))
	self.jump_velocity:store(velocity - Vector3(0, 0, self.free_fall_acceleration) * dt)
end

function NavDefaultSmartObjectFollower:get_smartobject_type(next_smartobject_interval)
	return self.navbot.navworld:get_smartobject_type(GwNavSmartObjectInterval.smartobject_id(next_smartobject_interval))
end

function NavDefaultSmartObjectFollower:handle_next_smartobject(botpos, next_smartobject_interval, entrance_pos, entrance_is_at_bot_progress_on_path, exit_pos, exit_is_at_the_end_of_path)
	local approachingDistance = 1

	local smartobject_type = self:get_smartobject_type(next_smartobject_interval)
	if smartobject_type == "Door" then
		self:manage_door_smartobject(botpos, next_smartobject_interval, entrance_pos, approachingDistance)
	elseif smartobject_type == "Jump" then
		self:manage_jump_smartobject(botpos, next_smartobject_interval, entrance_pos, exit_pos, approachingDistance)
	end
end

function NavDefaultSmartObjectFollower:manage_door_smartobject(botpos, next_smartobject_interval, entrance_pos, approachingDistance)
	if Vector3.distance(entrance_pos, botpos) < approachingDistance and

	GwNavSmartObjectInterval.can_traverse_smartobject(next_smartobject_interval) == false then
		self.navbot:repath()
	end



end

function NavDefaultSmartObjectFollower:start_follow(target_pos, start_follow_anim_event)
	self.navbot.is_smartobject_driven = true
	self.jump_start:store(self.navbot:get_position())
	self.jump_target:store(target_pos)
	Unit.animation_event(self.navbot.unit, start_follow_anim_event)
end

function NavDefaultSmartObjectFollower:manage_jump_smartobject(botpos, next_smartobject_interval, entrance_pos, exit_pos, approachingDistance)
	if Vector3.distance(entrance_pos, botpos) < approachingDistance then

		if self.navbot.is_smartobject_driven == false and GwNavSmartObjectInterval.can_traverse_smartobject(next_smartobject_interval) == false then
			self.navbot:repath()
		end


		if self.navbot.is_smartobject_driven == false then
			local in_manual_control = GwNavBot.enter_manual_control(self.navbot.gwnavbot, next_smartobject_interval)
			if in_manual_control == true then
				self:start_follow(exit_pos, "Jump")
				self:initial_jump_velocity()
			end
		end
	end
end

return NavDefaultSmartObjectFollower