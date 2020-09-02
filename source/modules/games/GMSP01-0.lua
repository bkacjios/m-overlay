-- Super Mario Sunshine (PAL v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803FBBF4, game)

return game
