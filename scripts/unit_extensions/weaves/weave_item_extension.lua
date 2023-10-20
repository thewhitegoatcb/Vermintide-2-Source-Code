require("scripts/unit_extensions/weaves/weave_item_templates")

WeaveItemExtension = class(WeaveItemExtension)
WeaveItemExtension.NAME = "WeaveItemExtension"





function WeaveItemExtension:init(extension_init_context, unit, extension_init_data)
	self._extension_init_context = extension_init_context
	self._is_server = extension_init_context.is_server
	self._unit = unit
	self._score = 0
	self._objective_name = extension_init_data.objective_name
	self._weave_item_template_name = extension_init_data.weave_item_template_name
	self._weave_item_template = WeaveItemTemplates [self._weave_item_template_name]

	self._weave_item_template:init()
end

function WeaveItemExtension:get_objective_settings()
	return WeaveObjectiveSettings [WeaveItemExtension.NAME]
end

function WeaveItemExtension:score()
	return self._score
end

function WeaveItemExtension:objective_name()
	return self._objective_name
end

function WeaveItemExtension:weave_item_template_name()
	return self._weave_item_template_name
end

function WeaveItemExtension:update(dt, t)







	if self._is_server then
		self._weave_item_template:server_update(dt, t)
	else
		self._weave_item_template:client_update(dt, t)
	end
end

function WeaveItemExtension:activate(game_object_id, objective_data)
	if self._is_server then
		local game_object_data_table = { value = 100,
			go_type = NetworkLookup.go_types.weave_objective,
			objective_name = NetworkLookup.weave_objective_names [self._objective_name] }


		local callback = callback(self, "cb_game_session_disconnect")
		self._game_object_id = Managers.state.network:create_game_object("weave_objective", game_object_data_table, callback)
	else
		self._game_object_id = game_object_id
	end
end

function WeaveItemExtension:deactivate()

	return end

function WeaveItemExtension:cb_game_session_disconnect()

	return end