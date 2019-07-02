function string.parseArgs(line)
	local cmd, val = line:match("(%S-)%s-=%s+(.+)")
	if cmd and val then
		return {cmd:trim(), val:trim()}
	end
	local quote = line:sub(1,1) ~= '"'
	local ret = {}
	for chunk in string.gmatch(line, '[^"]+') do
		quote = not quote
		if quote then
			table.insert(ret,chunk)
		else
			for chunk in string.gmatch(chunk, "%S+") do -- changed %w to %S to allow all characters except space
				table.insert(ret, chunk)
			end
		end
	end
	return ret
end

function string.firstToUpper(str)
	return str:gsub("^%l", string.upper)
end

local pattern_escape_replacements = {
	["("] = "%(",
	[")"] = "%)",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["["] = "%[",
	["]"] = "%]",
	["^"] = "%^",
	["$"] = "%$",
	["\0"] = "%z"
}

function string.escapePattern(str)
	return str:gsub(".", pattern_escape_replacements)
end

local format = string.format

function string.toSize(size)
	size = tonumber(size) or 0

	if size <= 0 then return "0" end
	if size < 1024 then return format("%.2f Bytes", size) end
	if size < 1024 * 1024 then return format("%.2f KB", size / 1024) end
	if size < 1024 * 1024 * 1024 then return format("%.2f MB", size / (1024 * 1024)) end

	return format("%.2f GB", size / (1024 * 1024 * 1024))
end