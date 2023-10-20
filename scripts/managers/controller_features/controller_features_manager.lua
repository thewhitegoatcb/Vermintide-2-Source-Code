require("scripts/managers/controller_features/controller_features_implementation")
require("scripts/settings/controller_features_settings")

ControllerFeaturesManager = class(ControllerFeaturesManager)

function ControllerFeaturesManager:init(is_in_inn)
	if rawget(_G, "ControllerFeaturesImplementation") then
		self._impl = ControllerFeaturesImplementation:new(is_in_inn)
	end
end

function ControllerFeaturesManager:add_effect(effect_name, params, user_id)
	if self._impl then
		return self._impl:add_effect(effect_name, params, user_id)
	end
end

function ControllerFeaturesManager:stop_effect(effect_id)
	if self._impl then
		self._impl:stop_effect(effect_id)
	end
end

function ControllerFeaturesManager:update(dt, t)
	if self._impl then
		self._impl:update(dt, t)
	end
end

function ControllerFeaturesManager:destroy()
	if self._impl then
		self._impl:destroy()
	end
	self._impl = nil
end