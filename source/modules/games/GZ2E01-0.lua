-- The Legend of Zelda - Twilight Princess (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x804343F0, game)

return game
