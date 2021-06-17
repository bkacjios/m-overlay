-- Metal Gear Solid - The Twin Snakes (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x801E9388, game)

local abs = math.abs

-- These functions seem to apply to many games

function game.translateAxis(x, y)
	x = x/100
	y = y/100

	local near = 1 - (abs(abs(x) - abs(y))) * 0.100

	local angle = math.atan2(x, y)
	local mag = math.sqrt(x*x + y*y)

	-- Reduce the magnitute when x,y values are headed towards a diagonal
	return x + math.sin(angle) * mag * near * 0.25, y + math.cos(angle) * mag * near * 0.25
end

return game
