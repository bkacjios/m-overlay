-- The SpongeBob SquarePants Movie (PAL v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803A9760, game)

return game