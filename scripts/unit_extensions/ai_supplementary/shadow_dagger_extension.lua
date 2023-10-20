ShadowDaggerExtension = class(ShadowDaggerExtension)

local DAGGER_DURATION = 10

function ShadowDaggerExtension:init(extension_init_context, unit, extension_init_data)
	self._projectile_locomotion_extension = ScriptUnit.extension(unit, "projectile_locomotion_system")
end

function ShadowDaggerExtension:destroy()
	return end

function ShadowDaggerExtension:on_remove_extension(unit, extension_name)
	return end

function ShadowDaggerExtension:update(unit, input, dt, context, t)
	if self._done then
		return
	end

	local current_life_time = self._projectile_locomotion_extension.time_lived

	local unit_alive = Unit.alive(unit)

	if not unit_alive then
		self._done = true
	elseif DAGGER_DURATION < current_life_time then
		Managers.state.unit_spawner:mark_for_deletion(unit)
		self._done = true
	end
end