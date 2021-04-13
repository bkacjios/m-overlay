-- Mario Kart Double Dash! (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x803A4D6C, game)

return game