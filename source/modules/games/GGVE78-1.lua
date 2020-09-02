-- The SpongeBob SquarePants Movie (NTSC v1.1)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803A9760, game)

return game