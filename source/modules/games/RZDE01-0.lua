-- The Legend of Zelda - Twilight Princess Wii (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x804C2F08, game)

return game
