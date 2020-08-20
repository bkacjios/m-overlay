-- Pikmin (NTSC v1.1)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x8039D400, game.memorymap)
game.translateAxis = core.translateAxis
game.translateTriggers = core.translateTriggers

return game