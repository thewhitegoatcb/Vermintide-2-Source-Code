





if not DLCUtils then
	DLCUtils = { check_dupes = true }
else
	DLCUtils.check_dupes = false
end




function DLCUtils.map(table_path, func)
	for dlc_name, dlc in pairs(DLCSettings) do
		local val = dlc [table_path]
		if val then
			func(dlc [table_path])
		end
	end
end




function DLCUtils.map_list(table_path, func)
	for dlc_name, dlc in pairs(DLCSettings) do
		local list = dlc [table_path]
		if list then
			for _, val in pairs(list) do
				func(val)
			end
		end
	end
end



function DLCUtils.require(table_path, force_local_require)
	return DLCUtils.map(table_path, force_local_require and local_require or require)
end



function DLCUtils.require_list(table_path, force_local_require)
	return DLCUtils.map_list(table_path, force_local_require and local_require or require)
end



function DLCUtils.dofile(table_path)
	return DLCUtils.map(table_path, dofile)
end



function DLCUtils.dofile_list(table_path)
	return DLCUtils.map_list(table_path, dofile)
end





function DLCUtils.append(table_path, dst, allow_dupes)
	local n = #dst

	for dlc_name, dlc in pairs(DLCSettings) do
		local val = dlc [table_path]
		if val then
			for i = 1, #val do






				n = n + 1
				dst [n] = val [i]
			end
		end
	end
end






function DLCUtils.merge(table_path, dst, allow_dupes)
	for dlc_name, dlc in pairs(DLCSettings) do
		local src = dlc [table_path]
		if src then









			table.merge_recursive(dst, src)
		end
	end
end