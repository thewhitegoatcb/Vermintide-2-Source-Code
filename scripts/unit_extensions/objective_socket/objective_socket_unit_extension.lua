ObjectiveSocketUnitExtension = class(ObjectiveSocketUnitExtension)



local ObjectiveSocketUnitExtensionSettings = {
	optional_color = { 0.02, 0.02, 0.1 } }


function ObjectiveSocketUnitExtension:init(extension_init_context, unit, extension_init_data, is_server)
	self.world = extension_init_context.world
	self.unit = unit

	self.is_server = is_server

	self.sockets = { }
	self.num_sockets = 0
	self.num_open_sockets = 0
	self.num_closed_sockets = 0
	self.distance = 10000
	self:setup_sockets(unit)

	self.use_game_object_id = extension_init_data.use_game_object_id

	self.pick_config = Unit.get_data(unit, "pick_config") or "ordered"

	POSITION_LOOKUP [unit] = Unit.world_position(unit, 0)

	self:_handle_optional_slots(unit)
end

function ObjectiveSocketUnitExtension:_handle_optional_slots(unit)
	if Unit.get_data(unit, "optional") then
		script_data.socket_unit = unit
		local color_table = ObjectiveSocketUnitExtensionSettings.optional_color
		local color = Vector3(color_table [1], color_table [2], color_table [3])
		local i = 0
		while Unit.has_data(unit, "optional_meshes", i) do
			local mesh_name = Unit.get_data(unit, "optional_meshes", i)
			local mesh = Unit.mesh(unit, mesh_name)
			local num_materials = Mesh.num_materials(mesh)
			for j = 0, num_materials - 1 do
				local material = Mesh.material(mesh, j)
				Material.set_vector3(material, "rgb", color)
			end

			i = i + 1
		end
	end
end

function ObjectiveSocketUnitExtension:destroy()
	POSITION_LOOKUP [self.unit] = nil
end

function ObjectiveSocketUnitExtension:setup_sockets(unit)
	local sockets = self.sockets
	local base = "socket_"
	local i = 1
	local socket_name = "socket_1"
	while Unit.has_node(unit, socket_name) do
		local node_index = Unit.node(unit, socket_name)
		sockets [i] = { open = true,
			socket_name = socket_name,
			node_index = node_index }



		i = i + 1
		socket_name = base .. i
	end

	fassert(i - 1 > 0, "No socket nodes in unit %q", unit)
	self.num_sockets = i - 1
end

function ObjectiveSocketUnitExtension:pick_socket_ordered(sockets)
	local num_sockets = self.num_sockets
	for i = 1, num_sockets do
		local socket = sockets [i]
		if socket.open then
			return socket, i
		end
	end

	print("[ObjectiveSocketUnitExtension]: No sockets open")
end

function ObjectiveSocketUnitExtension:pick_socket_closest(sockets, unit)
	local position = POSITION_LOOKUP [unit]
	local socket_unit = self.unit
	local num_sockets = self.num_sockets
	local closest_dsq = math.huge
	local closest_socket, closest_id = nil
	for i = 1, num_sockets do
		local socket = sockets [i]
		if socket.open then
			local socket_position = Unit.world_position(socket_unit, socket.node_index)
			local distance_squared = Vector3.distance_squared(position, socket_position)
			if distance_squared < closest_dsq then
				closest_dsq = distance_squared
				closest_socket = socket
				closest_id = i
			end
		end
	end

	if not closest_socket then
		print("[ObjectiveSocketUnitExtension]: No sockets open")
	end

	return closest_socket, closest_id
end

function ObjectiveSocketUnitExtension:pick_socket(unit)
	local socket, i = nil
	local pick_config = self.pick_config
	if pick_config == "ordered" then
		socket, i = self:pick_socket_ordered(self.sockets)
	elseif pick_config == "closest" then
		socket, i = self:pick_socket_closest(self.sockets, unit)
	else
		ferror("[ObjectiveSocketSystem] Unknown pick_config %q in unit %q", pick_config, self.unit)
	end
	return socket, i
end

function ObjectiveSocketUnitExtension:socket_from_id(socket_id)
	return self.sockets [socket_id]
end

function ObjectiveSocketUnitExtension:update(unit, input, dt, context, t)
















	return end