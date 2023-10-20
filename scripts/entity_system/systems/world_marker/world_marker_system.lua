require("scripts/unit_extensions/world_markers/player_equipment_world_marker_extension")
require("scripts/unit_extensions/world_markers/store_world_marker_extension")

WorldMarkerSystem = class(WorldMarkerSystem, ExtensionSystemBase)

local extensions = { "PlayerEquipmentWorldMarkerExtension", "StoreWorldMarkerExtension" }




function WorldMarkerSystem:init(entity_system_creation_context, system_name)
	self.super.init(self, entity_system_creation_context, system_name, extensions)
end

function WorldMarkerSystem:destroy()
	return end