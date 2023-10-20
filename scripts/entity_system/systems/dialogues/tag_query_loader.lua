local OP = nil
if rawget(_G, "RuleDatabase") then
	RuleDatabase.initialize_static_values()
	local operator_string_lookup = { GT = "GT", LT = "LT", NEQ = "NEQ", LTEQ = "LTEQ", GTEQ = "GTEQ", TIMEDIFF = "TIMEDIFF", EQ = "EQ", NOT = "NOT",






		TIMESET = TagQuery.OP.TIMESET,
		ADD = TagQuery.OP.ADD,
		SUB = TagQuery.OP.SUB,
		NUMSET = TagQuery.OP.NUMSET }




	OP = operator_string_lookup
else
	OP = TagQuery.OP
end

local function tprint(format, ...)
	if script_data.dialogue_debug_queries then
		print(string.format("[TagQueryLoader] " .. format, ...))
	end
end

TagQueryLoader = class(TagQueryLoader)



function TagQueryLoader:init(tagquery_database, dialogues_destination_table)
	self.loaded_files = { }


	self.file_environment = {
		OP = OP,
		math = math,
		define_rule = function (rule_definition)
			tagquery_database:define_rule(rule_definition)
		end,
		add_dialogues = function (dialogues)
			for name, dialogue in pairs(dialogues) do
				dialogue.category = dialogue.category or "default"
				dialogues_destination_table [name] = dialogue
			end
		end }

	self.tagquery_database = tagquery_database
end

function tag_query_errorfunc(arg)
	return arg .. "\n" .. debug.traceback()
end

function TagQueryLoader:load_file(filename)
	local file_function = require(filename)
	setfenv(file_function, self.file_environment)
	local num_rules_before = self.tagquery_database.rules_n
	file_function()

	local rules_read = self.tagquery_database.rules_n - num_rules_before
	tprint("Loaded file %s. Read %d rules.", filename, rules_read)

end










function TagQueryLoader:unload_files()
	for _, filename in ipairs(self.loaded_files) do
		if package.loaded [filename] then

			local load_order = package.load_order
			local n_load_order = #load_order
			local found_file = nil
			for i = n_load_order, 1, -1 do
				if load_order [i] == filename then
					found_file = true
					package.loaded [filename] = nil
					table.remove(load_order, i)
					break
				end
			end
			fassert(found_file)
			tprint("TagQueryLoader: Unloaded file: " .. tostring(filename))
		else
			tprint("TagQueryLoader: Could not unload file: " .. tostring(filename))
		end
	end
	self.file_environment = nil
	self.loaded_files = nil
	self.tagquery_database = nil
end