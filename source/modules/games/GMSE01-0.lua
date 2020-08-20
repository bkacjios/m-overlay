-- Super Mario Sunshine (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x80404454, game.memorymap)
game.translateAxis = core.translateAxis
game.translateTriggers = core.translateTriggers

return game
