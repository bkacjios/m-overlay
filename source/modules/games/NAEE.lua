-- Paper Mario (NTSC-U VC)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x80A9BCE0, game)

return game
