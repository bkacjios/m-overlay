-- Rayman 3: Hoodlum Havoc (NTSC-U v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x8042F5C8, game)

return game
