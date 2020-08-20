-- Need for Speed: Underground (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x802F2A5C, game.memorymap)
game.translateAxis = core.translateAxis
game.translateTriggers = core.translateTriggers

return game