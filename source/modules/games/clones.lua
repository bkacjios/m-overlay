--[[
-- Clone table format
["CLONED_GAME_ID"] = {
	[CLONE_REVISION] = { id = "ORIGINAL_GAME_ID", version = ORIGINAL_REVISION }
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
		-- Brawl versions 1.0, 1.1 have the same memory locations for controller data as 1.0
		[1] = { id = "RSBE01", version = 0 }, -- Super Smash Bros. Brawl (NTSC-U v1.1)
		[2] = { id = "RSBE01", version = 0 }, -- Super Smash Bros. Brawl (NTSC-U v1.2)
	},
	["RSBP01"] = {
		-- Brawl versions 1.0, 1.1 have the same memory locations for controller data as 1.0
		[1] = { id = "RSBP01", version = 0 }, -- Super Smash Bros. Brawl (PAL v1.1)
		[2] = { id = "RSBP01", version = 0 }, -- Super Smash Bros. Brawl (PAL v1.2)
	},
	["G2ME0R"] = {
		[0] = { id = "G2ME01", version = 0 }, -- Metroid Prime 2: Echoes Randomizer
	},
	["G2ME1R"] = {
		[0] = { id = "G2ME01", version = 0 }, -- Metroid Prime 2: Echoes Randomizer (Menu Mod)
	},
	["G2MP0R"] = {
		[0] = { id = "G2MP01", version = 0 }, -- Metroid Prime 2: Echoes Randomizer
	},
	["G2MP1R"] = {
		[0] = { id = "G2MP01", version = 0 }, -- Metroid Prime 2: Echoes Randomizer (Menu Mod)
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
	["PIKE25"] = {
		[0] = { id = "GPVE01", version = 0 }, -- Pikmin 251
	},
    ["GM2EGD"] = {
        [0] = { id = "GM2E8P", version = 0 }, -- Super Monkey Ball Gaiden
    }
}
