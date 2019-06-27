local floor = math.floor

local byte = string.byte
local char = string.char
local find = string.find
local format = string.format
local gmatch = string.gmatch
local gsub = string.gsub
local match = string.match
local reverse = string.reverse
local sub = string.sub
local upper = string.upper

local concat = table.concat
local insert = table.insert

-- remove trailing and leading whitespace from string.
function string.trim(s)
	return gsub(s, "^%s*(.-)%s*$", "%1")
end

local trim = string.trim

-- remove leading whitespace from string.
function string.ltrim(s)
	return gsub(s, "^%s*", "")
end

-- remove trailing whitespace from string.
function string.rtrim(s)
	local n = #s
	while n > 0 and find(s, "^%s", n) do n = n - 1 end
	return sub(s, 1, n)
end

function string.parseArgs(line)
	local cmd, val = match(line, "(%S-)%s-=%s+(.+)")
	if cmd and val then
		return {trim(cmd), trim(val)}
	end
	local quote = sub(line, 1,1) ~= '"'
	local ret = {}
	for chunk in gmatch(line, '[^"]+') do
		quote = not quote
		if quote then
			insert(ret,chunk)
		else
			for chunk in gmatch(chunk, "%S+") do -- changed %w to %S to allow all characters except space
				insert(ret, chunk)
			end
		end
	end
	return ret
end

function string.firstToUpper(str)
	return gsub(str, "^%l", upper)
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
	return gsub(str, ".", pattern_escape_replacements)
end

function string.toSize(size)
	size = tonumber(size) or 0

	if size <= 0 then return "0" end
	if size < 1024 then return format("%.2f Bytes", size) end
	if size < 1024 * 1024 then return format("%.2f KB", size / 1024) end
	if size < 1024 * 1024 * 1024 then return format("%.2f MB", size / (1024 * 1024)) end

	return format("%.2f GB", size / (1024 * 1024 * 1024))
end

function string.upperFirst(str)
	return upper(sub(str, 1,1)) .. sub(str, 2)
end

function string.addCommas(str)
	str = tostring(str)
	return reverse(gsub(gsub(reverse(str), "(...)", "%1,"), ",$", ""))
end

function string.niceNumber(num)
	return string.addCommas(format("%0.0f", num))
end

function string.singularOrMuliple(str, num)
	local fmt = format("%i %s", num, str)
	return num == 1 and fmt or (fmt .. "s")
end

function string.AOrAn(s)
	return match(s, "^h?[AaEeIiOoUu]") and "an" or "a"
end

function string.secondsToHuman(sec, accuracy)

	local accuracy = accuracy or 2

	local years = sec/31536000
	local yearsRemainder = sec%31536000
	local days = yearsRemainder/86400
	local daysRemainder = sec%86400
	local hours = daysRemainder/3600
	local hourRemainder = (sec - 86400)%3600
	local min = hourRemainder/60
	local sec = sec%60
	
	years = floor(years)
	days = floor(days)
	hours = floor(hours)
	min = floor(min)
	sec = floor(sec)
	
	local results = {}
	
	if years >= 1 then
		insert(results, string.singularOrMuliple("year", years))
	end
	if days >= 1 then
		insert(results, string.singularOrMuliple("day", days))
	end
	if hours >= 1 then
		insert(results, string.singularOrMuliple("hour", hours))
	end
	if min >= 1 then
		insert(results, string.singularOrMuliple("minute", min))
	end
	if sec >= 1 then
		insert(results, string.singularOrMuliple("second", sec))
	end
	
	local result = {}
	for i=1,accuracy do
		result[ i ] = results[ i ]
	end
	
	return concat(result, ", ")
end

function string.escapeURL(url)
	return gsub(url, "([^A-Za-z0-9_])", function(c)
		return format("%%%02x", byte(c))
	end)
end

function string.enescapeURL(url)
	return gsub(url, "%%(%x%x)", function(hex)
		return char(tonumber(hex, 16))
	end)
end