-- GOTCHA FORCE (JAP v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803C643C, game)
core.loadGenericControllerMap(0x803C646C, game)

return game
