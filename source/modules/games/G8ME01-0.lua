-- Paper Mario - The Thousand-Year Door (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803CA398, game)

return game