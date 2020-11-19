-- The Legend of Zelda - Majora's Mask (NTSC-U VC)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x80F1B5B0, game)

return game
