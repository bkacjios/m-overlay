-- Disney's Donald Duck Goin' Quackers (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x8029F8D8, game)

function game.translateAxis(x, y)
	x = x/80
	y = y/80
	return x, y
end

return game
