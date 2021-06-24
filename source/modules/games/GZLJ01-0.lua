-- The Legend of Zelda: The Wind Waker (NTSC-J)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803E0CF8, game)

return game