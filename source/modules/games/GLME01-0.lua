-- Luigi's Mansion (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x804CAFD0, game)

return game