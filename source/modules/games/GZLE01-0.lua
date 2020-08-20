-- The Legend of Zelda: The Wind Waker (NTSC)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803ED818, game.memorymap)
game.translateAxis = core.translateAxis
game.translateTriggers = core.translateTriggers

return game