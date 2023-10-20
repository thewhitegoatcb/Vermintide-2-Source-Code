



local format = string.format
local gsub = string.gsub
local sub = string.sub






function string.starts_with(str, start)
	return sub(str, 1, #start) == start
end






function string.ends_with(str, ending)
	return ending == "" or sub(str, -(#ending)) == ending
end






function string.insert(str1, str2, pos)
	return sub(str1, 1, pos) .. str2 .. sub(str1, pos + 1)
end


local _fields = nil
local function _split_helper(part)
	_fields [#_fields + 1] = part
end









function string.split(str, sep, dest)
	_fields = dest or { }
	local pattern = format("([^%s]+)", sep or " ")
	gsub(str, pattern, _split_helper)
	return _fields
end






function string.trim(str)
	return gsub(gsub(str, "^%s+", ""), "%s+$", "")
end






function string.remove(str, i, j)
	return sub(str, 1, i - 1) .. sub(str, j + 1)
end






function string.value_or_nil(str)
	if str == "" or str == false then
		do return nil end
	else
		return str
	end
end