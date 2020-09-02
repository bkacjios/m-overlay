-- Paper Mario - The Thousand-Year Door (JP v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803C6818, game)

return game