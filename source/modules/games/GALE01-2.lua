-- Super Smash Bros. Melee (NTSC v1.02)

local game = {
	memorymap = {}
}

-- Controls/Saves the volume levels of the game
game.memorymap[0x8045C384] = { type = "s8", name = "volume.slider" } -- Scale is (-100 to 100)

-- You can change these values in real time to change the volume, but when opening the sound menu, it will readjust to the slider value above
game.memorymap[0x804D3887] = { type = "u8", name = "volume.music" } -- Scale is (0-127)
game.memorymap[0x804D388F] = { type = "u8", name = "volume.ui" } -- Scale is (0-127)

game.memorymap[0x80479D60] = { type = "u32", name = "frame" }
game.memorymap[0x8049E753] = { type = "u8", name = "stage", debug = true }
game.memorymap[0x80479D30] = { type = "u8", name = "menu.major", debug = true }
game.memorymap[0x80479D33] = { type = "u8", name = "menu.minor", debug = true }
game.memorymap[0x804D6598] = { type = "u8", name = "menu.player_one_port", debug = true } -- What port is currently acting as "Player 1" in single player games
game.memorymap[0x804807C8] = { type = "bool", name = "teams" }
   
local controllers = {
	[1] = 0x804C1FAC + 0x44 * 0,
	[2] = 0x804C1FAC + 0x44 * 1,
	[3] = 0x804C1FAC + 0x44 * 2,
	[4] = 0x804C1FAC + 0x44 * 3,
}

local controller_struct = {
	[0x00] = { type = "u32",	name = "controller.%d.buttons.pressed" },
	[0x04] = { type = "u32",	name = "controller.%d.buttons.pressed_previous" },
	[0x08] = { type = "u32",	name = "controller.%d.buttons.instant" },
	[0x10] = { type = "u32",	name = "controller.%d.buttons.released" },
	--[0x1C] = { type = "u8",	name = "controller.%d.analog.byte.l" },
	--[0x1D] = { type = "u8",	name = "controller.%d.analog.byte.r" },
	[0x20] = { type = "float",	name = "controller.%d.joystick.x" },
	[0x24] = { type = "float",	name = "controller.%d.joystick.y" },
	[0x28] = { type = "float",	name = "controller.%d.cstick.x" },
	[0x2C] = { type = "float",	name = "controller.%d.cstick.y" },
	[0x30] = { type = "float",	name = "controller.%d.analog.l" },
	[0x34] = { type = "float",	name = "controller.%d.analog.r" },
	[0x41] = { type = "u8",	name = "controller.%d.plugged" },
}

for port, address in ipairs(controllers) do
	for offset, info in pairs(controller_struct) do
		game.memorymap[address + offset] = {
			type = info.type,
			debug = info.debug,
			name = info.name:format(port),
		}
	end
end

local player_static_addresses = {
	0x80453080, -- Player 1
	0x80453F10, -- Player 2
	0x80454DA0, -- Player 3
	0x80455C30, -- Player 4
	0x80456AC0, -- Player 5
	0x80457950, -- Player 6
}

local player_static_struct = {
	[0x004] = { type = "u32", name = "character" },
	[0x00C] = { type = "u16", name = "transformed" },
	[0x044] = { type = "u8", name = "skin" },
	[0x046] = { type = "u8", name = "color" },
	[0x047] = { type = "u8", name = "team" },
}

for id, address in ipairs(player_static_addresses) do
	for offset, info in pairs(player_static_struct) do
		game.memorymap[address + offset] = {
			type = info.type,
			debug = info.debug,
			name = ("player.%i.%s"):format(id, info.name),
		}
	end
end

local entity_pointer_offsets = {
	[0xB0] = "entity",
	[0xB4] = "partner", -- Partner entity (For sheik/zelda/iceclimbers)
}

for id, address in ipairs(player_static_addresses) do
	for offset, name in pairs(entity_pointer_offsets) do
		game.memorymap[address + offset] = {
			type = "pointer",
			name = ("player.%i.%s"):format(id, name),
			struct = {
				[0x60 + 0x0004] = { type = "u32", name = "character" },
				[0x60 + 0x0619] = { type = "u8", name = "skin" },
				[0x60 + 0x061A] = { type = "u8", name = "color" },
				[0x60 + 0x061B] = { type = "u8", name = "team" },

				[0x60 + 0x0620] = { type = "float", name = "controller.joystick.x" },
				[0x60 + 0x0624] = { type = "float", name = "controller.joystick.y" },
				[0x60 + 0x0638] = { type = "float", name = "controller.cstick.x" },
				[0x60 + 0x063C] = { type = "float", name = "controller.cstick.y" },
				[0x60 + 0x0650] = { type = "float", name = "controller.analog.float" },
				[0x60 + 0x065C] = { type = "u32",	name = "controller.buttons.pressed" },
				[0x60 + 0x0660] = { type = "u32",	name = "controller.buttons.pressed_previous" },
			},
		}
	end
end

-- https://github.com/project-slippi/slippi-ssbm-asm/blob/67c395692a74c962497669473097a19d782d269d/Online/Online.s#L25
local CSSDT_BUF_ADDR = 0x80005614

game.memorymap[CSSDT_BUF_ADDR] = {
	type = "pointer",
	name = "slippi",
	struct = {
		-- https://github.com/project-slippi/slippi-ssbm-asm/blob/6e08a376dc9ca239d9b7312089d975e89fa37a5c/Online/Online.s#L217
		[0x000] = {
			type = "pointer",
			name = "thing",
			struct = {
				[0x4] = { type = "u8", name = "test_value", debug = true }
			}
		},
		[0x040] = { type = "u8", name = "connection_state" },
		[0x041] = { type = "u8", name = "local_player.ready" },
		[0x042] = { type = "u8", name = "remote_player.ready" },
		[0x043] = { type = "u8", name = "local_player.index", debug = true },
		[0x044] = { type = "u8", name = "remote_player.index", debug = true },
		[0x045] = { type = "u32", name = "rng_offset" },
		[0x049] = { type = "u8", name = "delay_frames" },
		--[0x04A] = { type = "data", size = 31, name = "player.1.name" },
		--[0x069] = { type = "data", size = 31, name = "player.2.name" },
		--[0x088] = { type = "data", size = 31, name = "opponent_name" },
		--[0x0A7] = { type = "data", size = 121, name = "error_message" },
	}
}

-- Where character ID's are stored in the CSS menu
local player_select_external_addresses = {
	0x8043208B,
	0x80432093,
	0x8043209B,
	0x804320A3,
}

local player_select_external = {
	--[0x00] = "unknown",
	[0x04] = "character",
	[0x05] = "skin",
	--[0x08] = "mode"
}

for id, address in ipairs(player_select_external_addresses) do
	for offset, name in pairs(player_select_external) do
		game.memorymap[address + offset] = {
			type = "u8",
			name = ("player.%i.select.%s"):format(id, name),
		}
	end
end

game.memorymap[0x804D640F] = { type = "bool", name = "match.paused" }

local match_info = 0x8046B6A0
local match_info_struct = {
	[0x0005] = { type = "bool", name = "match.playing", debug = true },
	[0x0008] = { type = "u8", name = "match.result", debug = true },
	[0x000E] = { type = "bool", name = "match.finished", debug = true },
}

for offset, info in pairs(match_info_struct) do
	game.memorymap[match_info + offset] = info
end

function game.translateAxis(x, y)
	return x, y
end

function game.translateTriggers(l, r)
	return l, r
end

return game