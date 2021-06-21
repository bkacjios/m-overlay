-- Luigi's Mansion (JP v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x80494778, game)

return game