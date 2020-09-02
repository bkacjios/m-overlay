-- Need for Speed: Underground 2 (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803E642C, game)

return game