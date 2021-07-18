-- Crazy Taxi (NTSC-U v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803F3820, game)
core.loadGenericControllerMap(0x803F3860, game)

return game