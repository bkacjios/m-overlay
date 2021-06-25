-- Luigi's Mansion (PAL v1.1)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x804B8590, game)

return game