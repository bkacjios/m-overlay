-- Format ["CLONED GAME ID"] = { id = "ORIGINAL GAME ID", version = REVISION NUMBER }

return {
	--[string.char(0x47, 0x41, 0x02, 0x21, 0x21, 0x31)] = { id = "GALE01", version = 2 }, -- Slippi netplay
	--[string.char(0x47, 0x41, 0x14, 0x21, 0x21, 0x31)] = { id = "GALE01", version = 2 }, -- Slippi netplay
	["GTME01"] = { id = "GALE01", version = 2 }, -- UnclePunch Training Mode
	["MNCE02"] = { id = "GALE01", version = 2 }, -- Melee Netplay Community Build
	["SDRE32"] = { id = "GALE01", version = 2 }, -- SSBM SD Remix
	["RSBE01"] = { id = "RSBE01", version = 2 }, -- Super Smash Bros. Brawl
	["G2ME0R"] = { id = "G2ME01", version = 0 }, -- Metroid Prime 2: Echoes Randomizer
}
