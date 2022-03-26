-- Crash Bandicoot:The Wrath of Cortex (NTSC-U v1.0)

local core = require("games.core")

local game = core.newGame(0x803D2214)

function game.translateJoyStick(x, y)
	x = x/56
	y = y/56
	return x, y
end

function game.translateCStick(x, y)
	print(x)
	x = x/100
	y = y/100
	return x, y
end

return game
