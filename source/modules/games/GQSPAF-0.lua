-- Tales of Symphonia (PAL-GB v1.0)

local core = require("games.core")

local game = core.newGame(0x802CBF38)

function game.translateJoyStick(x, y)
	x = x/100
	y = y/100
	return x,y
end

function game.translateCStick(x, y)
	x = x/100
	y = y/100
	return x,y
end

return game
