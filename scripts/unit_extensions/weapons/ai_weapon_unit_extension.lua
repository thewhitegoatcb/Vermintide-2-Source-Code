
require("scripts/unit_extensions/weapons/ai_weapon_unit_templates")

AiWeaponUnitExtension = class(AiWeaponUnitExtension)

function AiWeaponUnitExtension:init(extension_init_context, unit, extension_init_data)
	local world = extension_init_context.world
	self.world = world
	self.unit = unit
	self.owner_unit = extension_init_data.owner_unit
	self.weapon_template = extension_init_data.weapon_template
	self.is_server = Managers.player.is_server

	self.data = { }
end

function AiWeaponUnitExtension:extensions_ready(world, unit)
	return end

function AiWeaponUnitExtension:destroy()
	local template = AiWeaponUnitTemplates.get_template(self.weapon_template)
	template.destroy(self.world, self.unit, self.data)
end

function AiWeaponUnitExtension:update(unit, input, dt, context, t)
	local template = AiWeaponUnitTemplates.get_template(self.weapon_template)
	template.update(self.world, self.unit, self.data, t, dt)
end

function AiWeaponUnitExtension:shoot_start(unit_owner, shoot_time)
	self.data.unit_owner = unit_owner
	local template = AiWeaponUnitTemplates.get_template(self.weapon_template)
	template.shoot_start(self.world, self.unit, self.data, shoot_time)
end

function AiWeaponUnitExtension:shoot(unit_owner)
	self.data.unit_owner = unit_owner
	local template = AiWeaponUnitTemplates.get_template(self.weapon_template)
	template.shoot(self.world, self.unit, self.data)
end

function AiWeaponUnitExtension:shoot_end(unit_owner)
	self.data.unit_owner = unit_owner
	local template = AiWeaponUnitTemplates.get_template(self.weapon_template)
	template.shoot_end(self.world, self.unit, self.data)
end

function AiWeaponUnitExtension:windup_start(unit_owner, windup_time)
	self.data.unit_owner = unit_owner
	local template = AiWeaponUnitTemplates.get_template(self.weapon_template)
	template.windup_start(self.world, self.unit, self.data, windup_time)
end

function AiWeaponUnitExtension:windup_end(unit_owner)
	self.data.unit_owner = unit_owner
	local template = AiWeaponUnitTemplates.get_template(self.weapon_template)
	template.windup_end(self.world, self.unit, self.data)
end