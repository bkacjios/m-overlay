-- GOTCHA FORCE (PAL v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803D093C, game)
core.loadGenericControllerMap(0x803D096C, game)

return game
