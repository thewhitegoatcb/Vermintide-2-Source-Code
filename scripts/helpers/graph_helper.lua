GraphHelper = GraphHelper or { }

GraphHelper._known_stats = GraphHelper._known_stats or { }
GraphHelper._known_graphs = GraphHelper._known_graphs or { }

local build = BUILD
local console_command = Application.console_command
local record_statistics = Profiler.record_statistics
if console_command == nil or build == "release" then
	function console_command() return end
end

if record_statistics == nil or build == "release" then
	function record_statistics() return end
end

function GraphHelper.create(graph_name, stat_names, stat_names_vector3)
	if GraphHelper._known_graphs [graph_name] ~= nil then
		return
	end

	console_command("graph", "make", graph_name)

	for i = 1, #(stat_names or { }) do
		local stat = stat_names [i]
		if GraphHelper._known_stats [stat] == nil then
			record_statistics(stat, 0)
			console_command("graph", "add", graph_name, stat)
			record_statistics(stat, 0)
			GraphHelper._known_stats [stat] = "number"
		end
	end

	for i = 1, #(stat_names_vector3 or { }) do
		local stat = stat_names_vector3 [i]
		if GraphHelper._known_stats [stat] == nil then
			record_statistics(stat, Vector3.zero())
			console_command("graph", "add_vector3", graph_name, stat)
			record_statistics(stat, Vector3.zero())
			GraphHelper._known_stats [stat] = "userdata"
		end
	end

	console_command("graph", "show", graph_name)
end

function GraphHelper.show(graph_name)
	console_command("graph", "show", graph_name)
end

function GraphHelper.hide(graph_name)
	console_command("graph", "hide", graph_name)
end

function GraphHelper.set_range(graph_name, min, max)
	console_command("graph", "range", graph_name, tostring(min), tostring(max))
end

function GraphHelper.update_range(graph_name)
	console_command("graph", "range", graph_name)
end

function GraphHelper.set_color(stat, color)
	console_command("graph", "color", color)
end

function GraphHelper.record_statistics(stat, value)


	assert(GraphHelper._known_stats [stat] == type(value))
	record_statistics(stat, value)
end