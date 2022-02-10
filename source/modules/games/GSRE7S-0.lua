-- Smuggler's Run - Warzones (NTSC-U v1.0)

local core = require("games.core")

local game = core.newGame(0x8037A5B0)

function game.translateJoyStick(x, y)
	x = x/100
	y = y/100
	return x, y
end

game.translateCStick = game.translateJoyStick

return game
