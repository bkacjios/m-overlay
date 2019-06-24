function debug.trace()
	local level = 1
	Msg("\nTrace: \n")
	while true do
		local info = debug.getinfo(level, "Sln")
		if not info then break end
		if info.what == "C" then
			Msg(level, "\tC function\n")
		else
			Msg(string.format("\t%i: Line %d\t\"%s\"\t%s\n", level, info.currentline, (info.name or "(null)"), (info.short_src or "(null)")))
		end
		level = level + 1
	end
	Msg("\n\n")
end