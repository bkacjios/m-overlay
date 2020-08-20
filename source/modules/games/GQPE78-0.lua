-- SpongeBob SquarePants: Battle for Bikini Bottom (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x80292620, game.memorymap)
game.translateAxis = core.translateAxis
game.translateTriggers = core.translateTriggers

return game
