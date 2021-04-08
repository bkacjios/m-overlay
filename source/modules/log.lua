local LOG_FILE = "console.log"

love.filesystem.remove(LOG_FILE)

local log = {
	levels = {
		{ name = "trace", color = "\27[34m" },
		{ name = "debug", color = "\27[36m" },
		{ name = "info", color = "\27[32m" },
		{ name = "warn", color = "\27[33m" },
		{ name = "error", color = "\27[31m" },
		{ name = "fatal", color = "\27[35m" },
	},
	color = true,
	date = "%H:%M:%S",
	level = "trace",
	file = assert(love.filesystem.newFile(LOG_FILE, "a"))
}

function log.setColor(b)
	log.color = b
end

function log.setLevel(l)
	log.level = l
end

local format = string.format

for level, cfg in ipairs(log.levels) do
	local upname = cfg.name:upper()
	log[upname] = level

	log[cfg.name] = function(text, ...)
		if log[log.level:upper()] > log[upname] then return end

		if select("#", ...) > 0 then
			text = format(text, ...)
		end

		local date = os.date(log.date)
		local message = format("[%-5s - %s] %s", upname, date, text)

		if log.file then
			log.file:write(string.format("%s\r\n", message))
			log.file:flush()
		end

		if log.color then
			message = format("[%s%-5s\27[0m - %s] %s", cfg.color, upname, date, text)
		end

		print(message)
	end
end

return log