--[[
-- Clone table format
["CLONED GAME ID"] = {
	[CLONE REVISION] = { id = "ORIGINAL GAME ID", version = REVISION }
}
]]

return {
	["GTME01"] = {
		[2] = { id = "GALE01", version = 2 }, -- UnclePunch Training Mode
	},
	["MNCE02"] = {
		[2] = { id = "GALE01", version = 2 }, -- Melee Netplay Community Build
	},
	["SDRE32"] = {
		[3] = { id = "GALE01", version = 2 }, -- SSBM SD Remix
	},
	["RSBE01"] = {
		-- Brawl versions 1.0, 1.1 have the same memory locations for controller data as 1.2
		[0] = { id = "RSBE01", version = 2 }, -- Super Smash Bros. Brawl (v1.0)
		[1] = { id = "RSBE01", version = 2 }, -- Super Smash Bros. Brawl (v1.1)
	},
	["G2ME0R"] = {
		[0] = { id = "G2ME01", version = 0 }, -- Metroid Prime 2: Echoes Randomizer
	},
	["KHPE01"] = {
		[0] = { id = "GKYE01", version = 0 }, -- Kirby Air Ride Hack Pack
	},
	["GZLE99"] = {
		[0] = { id = "GZLE01", version = 0 }, -- The Legend of Zelda: The Wind Waker Randomizer
	},
	["GALJ01"] = {
		[0] = { id = "GALE01", version = 0 }, -- Dairantou Smash Brothers DX (Japan) (v1.0)
		[1] = { id = "GALE01", version = 1 }, -- Dairantou Smash Brothers DX (Japan) (v1.1)
		[2] = { id = "GALE01", version = 2 }, -- Dairantou Smash Brothers DX (Japan) (v1.2)
	},
}
