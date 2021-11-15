-- Pac-Man World 2 (NTSC v1.0)

local core = require("games.core")

local game = core.newGame(0x8037B3C0)

local abs = math.abs

function game.translateJoyStick(x, y)
	x = x/127
	y = y/127

	local near = 1 - (abs(abs(x) - abs(y))) * 0.100

	local angle = math.atan2(x, y)
	local mag = math.sqrt(x*x + y*y)

	-- Reduce the magnitute when x,y values are headed towards a diagonal
	return x + math.sin(angle) * mag * near * 0.25, y + math.cos(angle) * mag * near * 0.25
end

return game