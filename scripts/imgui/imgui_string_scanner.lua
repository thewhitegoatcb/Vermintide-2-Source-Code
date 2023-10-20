
ImguiStringScanner = class(ImguiStringScanner)

function ImguiStringScanner:init()
	self._results = { }
	self._query = ""
end

function ImguiStringScanner:update(dt)
	return end

function ImguiStringScanner:draw()
	local do_close = Imgui.begin_window("String Scanner")

	if not rawget(Script, "string_scan") then
		Imgui.text("Required engine functionality is not available.")
		Imgui.end_window()
		return do_close
	end

	local query = Imgui.input_text("Query", self._query)
	self._query = query

	local results = self._results
	if Imgui.button("Run search") then
		local string_lut = Script.string_scan()
		table.clear(results)
		query = string.lower(query)
		for str, file in pairs(string_lut) do
			str = string.lower(str)
			if string.find(str, query) then
				results [#results + 1] = str .. "\t" .. file
			end
		end
		table.sort(results)
	end

	Imgui.begin_child_window("strings", 0, 0, true)
	Imgui.columns(2, true)
	for i = 1, #results do
		local str, file = string.match(results [i], "^([^\t]+)\t(.*)$")
		Imgui.text(str)
		Imgui.next_column()
		Imgui.text(file)
		Imgui.next_column()
	end
	Imgui.columns(1)
	Imgui.end_child_window()

	Imgui.end_window()
	return do_close
end

function ImguiStringScanner:is_persistent()
	return false
end