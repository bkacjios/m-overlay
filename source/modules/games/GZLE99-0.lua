-- The Legend of Zelda: The Wind Waker (NTSC) Randomizer

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803ED818, game)

return game