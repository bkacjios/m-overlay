-- The Legend of Zelda - Twilight Princess (PAL v1.0)

-- The motivation behind adding PAL version support is that most
-- speedrunners run on the PAL version of the game, since German
-- is the fastest language.

local core = require("games.core")

local game = {
	memorymap = {}
}

core.loadGenericControllerMap(0x804363B0, game)

return game
