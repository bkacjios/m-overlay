local LOG_FILE = "console.log"

love.filesystem.remove(LOG_FILE)

local log = {
	levels = {
		["trace"] = { priority = -1, color = "\27[34m" },
		["debug"] = { priority = 0, color = "\27[36m" },
		["info"] = { priority = 1, color = "\27[32m" },
		["warn"] = { priority = 2, color = "\27[33m" },
		["error"] = { priority = 3, color = "\27[31m" },
		["fatal"] = { priority = 4, color = "\27[35m" },
	},
	color = true,
	date_format = "%H:%M:%S",
	level = "debug",
	file = assert(love.filesystem.newFile(LOG_FILE, "a"))
}

function log.setColor(b)
	log.color = b
end

function log.setLevel(l)
	log.level = l
end

local format = string.format
local upper = string.upper

do
	local colorless
	function log.print(text, ...)
		if select("#", ...) > 0 then
			text = format(text, ...)
		end

		-- strip out unix colors
		colorless = text:gsub("\x1b%[[%d;]+m", "")

		if log.file then
			log.file:write(colorless)
		end

		-- write to stdout
		io.stdout:write(log.color and text or colorless)
	end
end

function log.flush()
	if log.file then
		log.file:flush()
	end
	io.stdout:flush()
end

for level, info in pairs(log.levels) do
	local filter = log.levels[log.level].priority
	local stamp = function()
		local date = os.date(log.date_format)
		log.print(format("[%s%-5s\27[0m - %s] ", info.color, level:upper(), date))
	end
	log[level] = function(text, ...)
		if info.priority < filter then return end
		stamp()
		log.print(format("%s\n", text), ...)
	end
	log[level .. "Stamp"] = stamp
	log[level .. "Enabled"] = function()
		return info.priority >= filter
	end
end

return log