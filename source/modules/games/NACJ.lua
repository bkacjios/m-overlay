-- The Legend of Zelda - Ocarina of Time (NTSC-J VC)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x809F6A88, game)

return game
