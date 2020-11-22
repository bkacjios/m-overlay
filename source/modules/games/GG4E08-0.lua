-- GOTCHA FORCE (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803C72FC, game)
core.loadGenericControllerMap(0x803C732C, game)

return game
