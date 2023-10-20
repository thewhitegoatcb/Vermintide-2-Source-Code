








































table_trap = table_trap or { }

function table_trap.print(operation, key, value)
	print(table_trap._trap_information(operation, key, value))
end




function table_trap.callstack(operation, key, value)
	print(table_trap._trap_information(operation, key, value) .. "\n" .. Script.callstack())
end



function table_trap.crash(operation, key, value)
	print(table_trap._trap_information(operation, key, value))
	error("Table trap crash")
end



function table_trap.noop()
	return end









function table_trap.trap_key(table_to_debug, key_to_inspect, read_func, write_func)

	if read_func == nil then
		read_func = table_trap.noop
	end
	if write_func == nil then
		write_func = table_trap.noop
	end


	local data_table = { }


	local old_metatable = getmetatable(table_to_debug)
	setmetatable(table_to_debug, nil)




	for k, v in pairs(table_to_debug) do
		data_table [k] = v
		table_to_debug [k] = nil
	end



	setmetatable(data_table, old_metatable)



	local new_metatable = { }
	table_trap._add_forwarding_metafunctions(new_metatable, data_table)


	function new_metatable.__index(t, key)
		local value = data_table [key]
		if key == key_to_inspect then
			read_func("read", key, value)
		end
		return value
	end


	function new_metatable.__newindex(t, key, value)
		if key == key_to_inspect then
			write_func("write", key, value)
		end
		data_table [key] = value
	end


	setmetatable(table_to_debug, new_metatable)
end








function table_trap.trap_keys(table_to_debug, read_func, write_func)

	if read_func == nil then
		read_func = table_trap.noop
	end
	if write_func == nil then
		write_func = table_trap.noop
	end


	local data_table = { }


	local old_metatable = getmetatable(table_to_debug)
	setmetatable(table_to_debug, nil)




	for k, v in pairs(table_to_debug) do
		data_table [k] = v
		table_to_debug [k] = nil
	end



	setmetatable(data_table, old_metatable)



	local new_metatable = { }
	table_trap._add_forwarding_metafunctions(new_metatable, data_table)


	function new_metatable.__index(t, key)
		local value = data_table [key]
		read_func("read", key, value)
		return value
	end


	function new_metatable.__newindex(t, key, value)
		write_func("write", key, value)
		data_table [key] = value
	end


	setmetatable(table_to_debug, new_metatable)
end


function table_trap._trap_information(operation, key, value)
	if operation == "read" then
		return string.format("Trap %s '%s':'%s'", operation, tostring(key), tostring(value))
	elseif operation == "write" then
		return string.format("Trap %s '%s'='%s'", operation, tostring(key), tostring(value))
	end
end



function table_trap._add_forwarding_metafunctions(metatable, data_table)

	function metatable.__unm(t)
		return -data_table
	end
	function metatable.__add(lhs, rhs)
		local a, b = table_trap._replace_with_data_if_metatable_matches(lhs, rhs, metatable, data_table)
		return a + b
	end
	function metatable.__sub(lhs, rhs)
		local a, b = table_trap._replace_with_data_if_metatable_matches(lhs, rhs, metatable, data_table)
		return a - b
	end
	function metatable.__mul(lhs, rhs)
		local a, b = table_trap._replace_with_data_if_metatable_matches(lhs, rhs, metatable, data_table)
		return a * b
	end
	function metatable.__div(lhs, rhs)
		local a, b = table_trap._replace_with_data_if_metatable_matches(lhs, rhs, metatable, data_table)
		return a / b
	end
	function metatable.__mod(lhs, rhs)
		local a, b = table_trap._replace_with_data_if_metatable_matches(lhs, rhs, metatable, data_table)
		return a % b
	end
	function metatable.__pow(lhs, rhs)
		local a, b = table_trap._replace_with_data_if_metatable_matches(lhs, rhs, metatable, data_table)
		return a ^ b
	end
	function metatable.__concat(lhs, rhs)
		local a, b = table_trap._replace_with_data_if_metatable_matches(lhs, rhs, metatable, data_table)
		return a .. b
	end


	function metatable.__eq(lhs, rhs)
		assert(false)
	end
	function metatable.__lt(lhs, rhs)
		assert(false)
	end
	function metatable.__le(lhs, rhs)
		assert(false)
	end

	function metatable.__len(t)

		return #data_table
	end

	function metatable.__call(f, ...)
		data_table(f, ...)
	end

	function metatable.__tostring(s)
		return tostring(data_table)
	end
end




function table_trap._replace_with_data_if_metatable_matches(lhs, rhs, metatable, data)
	local redir_lhs, redir_rhs = nil

	if getmetatable(lhs) == metatable then
		redir_lhs = data
	else
		redir_lhs = lhs
	end
	if getmetatable(rhs) == metatable then
		redir_rhs = data
	else
		redir_rhs = rhs
	end
	return redir_lhs, redir_rhs
end