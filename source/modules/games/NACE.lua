-- The Legend of Zelda - Ocarina of Time (NTSC-U VC)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x809F6BA8, game)

return game
