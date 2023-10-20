PerformanceManager = class(PerformanceManager)

function PerformanceManager:init(gui, is_server, level_key)
	self._gui = gui
	self._is_server = is_server
	self._tracked_ai_breeds = { skaven_plague_monk = true, chaos_raider = true, chaos_marauder = true, beastmen_bestigor = true, chaos_berzerker = true, skaven_clan_rat_with_shield = true, chaos_marauder_with_shield = true, chaos_fanatic = true, skaven_slave = true, skaven_clan_rat = true, beastmen_ungor = true, chaos_warrior = true, beastmen_ungor_archer = true, skaven_storm_vermin_commander = true, skaven_storm_vermin = true, beastmen_gor = true, skaven_storm_vermin_with_shield = true }




















	self._num_ai_spawned = 0
	self._num_ai_active = 0
	self._num_event_ai_spawned = 0
	self._num_event_ai_active = 0
	self._num_ai_string = "SPAWNED: %3i   ACTIVE: %3i   EVENT SPAWNED: %3i   EVENT SPAWNED ACTIVE: %3i"
	self._inactive_units = { }
	self._settings = {

		critical = { font = "materials/fonts/arial", distance_from_top = 60, size = 36, material = "arial",

			color = ColorBox(255, 255, 0, 0),
			color_to = ColorBox(255, 255, 255, 0),


			position = Vector3Box() },


		normal = { font = "materials/fonts/arial", distance_from_top = 30, size = 26, material = "arial",

			color = ColorBox(255, 0, 255, 0),


			position = Vector3Box() } }




	if not DEDICATED_SERVER then
		local w, h = Gui.resolution()
		for _, setting in pairs(self._settings) do
			local min, max = Gui.text_extents(gui, self._num_ai_string, setting.font, setting.size, setting.material)
			local x = math.floor(( w + min.x - max.x ) * 0.5)
			local y = h - setting.distance_from_top
			local z = 999
			setting.position:store(x, y, z)
		end
	end

	self._events = { ai_unit_activated = "event_ai_unit_activated", ai_unit_despawned = "event_ai_unit_despawned", ai_units_all_destroyed = "event_ai_units_all_destroyed", ai_unit_spawned = "event_ai_unit_spawned", ai_unit_deactivated = "event_ai_unit_deactivated" }







	local event_manager = Managers.state.event
	for event_name, cb_name in pairs(self._events) do
		event_manager:register(self, event_name, cb_name)
	end

	local level_settings = LevelSettings [level_key]
	local perf = level_settings and level_settings.performance

	self._allowed_active = perf and perf.allowed_active or 40
	self._allowed_spawned = perf and perf.allowed_spawned or 75
	self._activated_per_breed = { }
	for breed_name, breed in pairs(Breeds) do
		self._activated_per_breed [breed_name] = 0
	end
end

function PerformanceManager:update(dt, t)




































	return end

function PerformanceManager:event_ai_unit_spawned(unit, breed_name, active, event_spawned)
	if not self._tracked_ai_breeds [breed_name] then
		return
	end

	self._num_ai_spawned = self._num_ai_spawned + 1
	if active then
		self._num_ai_active = self._num_ai_active + 1
		self._activated_per_breed [breed_name] = self._activated_per_breed [breed_name] + 1
	else
		self._inactive_units [unit] = true
	end

	if event_spawned then
		self._num_event_ai_spawned = self._num_event_ai_spawned + 1
		if active then
			self._num_event_ai_active = self._num_event_ai_active + 1
		end
	end
end

function PerformanceManager:event_ai_units_all_destroyed()
	self._num_ai_spawned = 0
	self._num_event_ai_spawned = 0
	self._num_ai_active = 0
	self._num_event_ai_active = 0
	self._inactive_units = { }

	local activated_per_breed = self._activated_per_breed
	for breed_name, amount in pairs(activated_per_breed) do
		activated_per_breed [breed_name] = 0
	end
end


function PerformanceManager:event_ai_unit_activated(unit, breed_name, event_spawned)

	self._activated_per_breed [breed_name] = self._activated_per_breed [breed_name] + 1
	if not self._tracked_ai_breeds [breed_name] then
		return
	end

	self._num_ai_active = self._num_ai_active + 1
	self._inactive_units [unit] = nil

	if event_spawned then
		self._num_event_ai_active = self._num_event_ai_active + 1
	end
end


function PerformanceManager:event_ai_unit_deactivated(unit, breed_name)
	self._activated_per_breed [breed_name] = math.clamp(self._activated_per_breed [breed_name] - 1, 0, 999999)

	if not self._tracked_ai_breeds [breed_name] then
		return
	end

	self._inactive_units [unit] = true
	self._num_ai_active = math.max(self._num_ai_active - 1, 0)
end


function PerformanceManager:event_ai_unit_despawned(unit, breed_name, active, event_spawned)

	if active then
		self._activated_per_breed [breed_name] = self._activated_per_breed [breed_name] - 1
	end

	if not self._tracked_ai_breeds [breed_name] then
		return
	end

	self._num_ai_spawned = self._num_ai_spawned - 1
	if active then
		self._num_ai_active = self._num_ai_active - 1
	else
		self._inactive_units [unit] = nil
	end

	if event_spawned then
		self._num_event_ai_spawned = self._num_event_ai_spawned - 1
		if active then
			self._num_event_ai_active = self._num_event_ai_active - 1
		end
	end
end

function PerformanceManager:num_active_enemies()
	return self._num_ai_active
end

function PerformanceManager:num_active_enemies_of_breed(breed_name)
	return self._activated_per_breed [breed_name]
end

function PerformanceManager:activated_per_breed()
	return self._activated_per_breed
end

function PerformanceManager:destroy()
	local event_manager = Managers.state.event
	for event_name, cb_name in pairs(self._events) do
		event_manager:unregister(event_name, self)
	end
end