-- Ed, Edd n Eddy - The Mis-Edventures (NTSC-U v1.0)

local core = require("games.core")

local game = core.newGame(0x8038B2B4)

function game.translateJoyStick(x, y)
	x = x/56
	y = y/56
	return x, y
end

function game.translateCStick(x, y)
	x = x/44
	y = y/44
	return x, y
end

return game
