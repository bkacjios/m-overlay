-- Super Mario 64 (NTSC-U VC)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x809F38B8, game)

return game
