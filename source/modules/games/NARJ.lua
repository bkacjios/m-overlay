-- The Legend of Zelda - Majora's Mask (NTSC-J VC)

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x80F20170, game)

return game
