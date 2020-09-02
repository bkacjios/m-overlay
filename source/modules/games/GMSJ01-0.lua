-- Super Mario Sunshine (JP v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x80400D50, game)

return game
