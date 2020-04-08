local graphics = love.graphics
local newImage = graphics.newImage
local newFont = graphics.newFont
local timer = love.timer

local log = require("log")

local notification = {
	messages = {},
	font = newFont("fonts/ultimate-bold.otf", 18),
	padding = 8,
}

local dummy = function(height, fade) end

function notification.add(height, length, fade, draw)
	height = height or 16
	length = length or 3
	fade = fade or 0.75

	local now = timer.getTime()

	table.insert(notification.messages, {
		time = now,
		length = length,
		fade = fade,
		finish = now + length + fade,

		height = height,

		draw = draw or dummy,

		lerp = {},
	})
end

function notification.update(x, y)
	local now = timer.getTime()

	local prevh = 0

	for k, message in pairs(notification.messages) do
		if (message.finish >= now) then
			x = x * 0.5 + (message.lerp.x or x) * 0.5
			y = y * 0.5 + (message.lerp.y or y) * 0.5
			y = y + prevh/2 + notification.padding/2

			message.lerp.x = x
			message.lerp.y = y

			prevh = message.height
		end
	end
	
	for k, message in pairs(notification.messages) do
		if (message.finish >= now) then
			return
		end
	end
	
	notification.messages = {}
end

function notification.draw()
	local now = timer.getTime()
	for k, message in pairs(notification.messages) do

		local fade = 1

		if now >= message.time + message.length then
			fade = 1-((now - message.time - message.length)/message.fade)
		end

		local x, y = message.lerp.x, message.lerp.y

		if x and y then
			graphics.push("transform")
			graphics.translate(x, y)
			graphics.setFont(notification.font)
			graphics.setColor(255, 255, 255, 255 * fade)
			local succ, ret = xpcall(message.draw, debug.traceback, message.height, fade)
			if not succ then
				log.error("notification error: %s", ret)
			end
			graphics.pop()
		end
	end
end

function notification.coloredMessage(...)
	local args = {...}
	notification.add(14, 5, 0.5, function(height, fade)
		graphics.setColor(0, 0, 0, 255 * fade)
		graphics.textOutline(args, 1, 1, 1)
		graphics.setColor(255, 255, 255, 255 * fade)
		graphics.print(args, 0, 0)
	end)
end

return notification