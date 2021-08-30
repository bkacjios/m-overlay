-- Super Smash Bros. Melee (NTSC v1.2) / Dairantou Smash Brothers DX (Japan v1.2)

local game = {
	memorymap = {}
}

-- Controls/Saves the volume levels of the game
game.memorymap[0x8045C384] = { type = "s8", name = "volume.slider" } -- Scale is (-100 to 100)

-- You can change these values in real time to change the volume, but when opening the sound menu, it will readjust to the slider value above
game.memorymap[0x804D3887] = { type = "u8", name = "volume.music" } -- Scale is (0-127)
game.memorymap[0x804D388F] = { type = "u8", name = "volume.ui" } -- Scale is (0-127)

game.memorymap[0x80479D60] = { type = "u32", name = "frame" }
game.memorymap[0x8049E753] = { type = "u8", name = "stage" }

game.memorymap[0x80479D30] = { type = "u8", name = "scene.major", debug = true }
game.memorymap[0x80479D31] = { type = "u8", name = "scene.major2" }
game.memorymap[0x80479D32] = { type = "u8", name = "scene.major_prev" }
game.memorymap[0x80479D33] = { type = "u8", name = "scene.minor", debug = true }
game.memorymap[0x80479D34] = { type = "u8", name = "scene.minor_prev" }

game.memorymap[0x804D6598] = { type = "u8", name = "menu.player_one_port" } -- What port is currently acting as "Player 1" in single player games
game.memorymap[0x804807C8] = { type = "bool", name = "menu.teams" }

game.memorymap[0x804A04F0] = { type = "u8", name = "menu.id" }
game.memorymap[0x804A04F1] = { type = "u8", name = "menu.id_prev" }
game.memorymap[0x804A04F3] = { type = "u8", name = "menu.selection" }
game.memorymap[0x804A04F4] = { type = "u8", name = "menu.value" }

game.memorymap[0x8066A2DF] = { type = "data", len = 7, name = "romstring.akaneia" }
game.memorymap[0x8066A2C3] = { type = "data", len = 12, name = "romstring.beyondmelee" }

game.memorymap[0x804D5F90] = { type = "u32", name = "rng.seed" }

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
	[0x1C] = { type = "u8",		name = "controller.%d.analog.byte.l" },
	[0x1D] = { type = "u8",		name = "controller.%d.analog.byte.r" },
	[0x20] = { type = "float",	name = "controller.%d.joystick.x" },
	[0x24] = { type = "float",	name = "controller.%d.joystick.y" },
	[0x28] = { type = "float",	name = "controller.%d.cstick.x" },
	[0x2C] = { type = "float",	name = "controller.%d.cstick.y" },
	[0x30] = { type = "float",	name = "controller.%d.analog.l" },
	[0x34] = { type = "float",	name = "controller.%d.analog.r" },
	[0x41] = { type = "u8",		name = "controller.%d.plugged" },
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

local entity_pointer_offsets = {
	[0xB0] = "entity",
	[0xB4] = "partner", -- Partner entity (For sheik/zelda/iceclimbers)
}

local player_static_struct = {
	[0x004] = { type = "u32", name = "character" },
	[0x008] = { type = "u32", name = "mode" },
	[0x00C] = { type = "u16", name = "transformed" },
	[0x044] = { type = "u8", name = "skin" },
	--[0x045] = { type = "u8", name = "port" },
	[0x046] = { type = "u8", name = "color" },
	[0x047] = { type = "u8", name = "team" },
	--[0x048] = { type = "u8", name = "index" },
	--[0x049] = { type = "u8", name = "cpu_level", debug = true },
	--[0x04A] = { type = "u8", name = "cpu_type", debug = true }, -- 4 = 20XX, 22 = normalish, 19 = Alt Normal
}

for id, address in ipairs(player_static_addresses) do
	for offset, info in pairs(player_static_struct) do
		game.memorymap[address + offset] = {
			type = info.type,
			debug = info.debug,
			name = ("player.%i.%s"):format(id, info.name),
		}
	end

	for offset, name in pairs(entity_pointer_offsets) do
		game.memorymap[address + offset] = {
			type = "pointer",
			name = ("player.%i.%s"):format(id, name),
			struct = {
				[0x60 + 0x0004] = { type = "u32", name = "character" },
				--[0x60 + 0x000C] = { type = "u8", name = "port" },
				--[0x60 + 0x0618] = { type = "u8", name = "index" },
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

				--[[
				[0x60 + 0x1A94] = { type = "u32", name = "cpu_type" },
				[0x60 + 0x1A98] = { type = "u32", name = "cpu_level" },
				]]
			},
		}
	end
end

-- https://github.com/project-slippi/slippi-ssbm-asm/blob/9c36ffc5e4787c6caadfb12727c5fcff07d64642/Online/Online.s#L29
local CSSDT_BUF_ADDR = 0x80005614

game.memorymap[CSSDT_BUF_ADDR] = {
	type = "pointer",
	name = "slippi",
	debug = true,
	struct = {
		-- https://github.com/project-slippi/slippi-ssbm-asm/blob/9c36ffc5e4787c6caadfb12727c5fcff07d64642/Online/Online.s#L253
		[0x000] = {
			type = "pointer",
			--name = "slippi_ptr",
			debug = true,
			struct = {
				[0x00] = { type = "u8", name = "connection_state" },
				[0x01] = { type = "u8", name = "local_player.ready" },
				[0x02] = { type = "u8", name = "remote_player.ready" },
				[0x03] = { type = "u8", name = "local_player.index", debug = true },
				[0x04] = { type = "u8", name = "remote_player.index" },
				[0x05] = { type = "u32", name = "rng_offset" },
				[0x09] = { type = "u8", name = "delay_frames" },
				[0x0A] = { type = "u8", name = "local_player.chatmsg_id" },
				[0x0B] = { type = "u8", name = "opponent.chatmsg_id" },
				[0x0C] = { type = "u8", name = "chatmsg.index" },
				[0x0D] = { type = "u32", name = "vs.left_names" },
				[0x11] = { type = "u32", name = "vs.right_names" },
				[0x15] = { type = "data", len = 31, name = "local_player.name" },
				[0x34] = { type = "data", len = 31, name = "players.1.name" },
				[0x53] = { type = "data", len = 31, name = "players.2.name" },
				[0x72] = { type = "data", len = 31, name = "players.3.name" },
				[0x91] = { type = "data", len = 31, name = "players.4.name" },
				[0xB0] = { type = "data", len = 63, name = "opponent.name" },
				[0xEF] = { type = "data", len = 10, name = "players.1.code" },
				[0xF9] = { type = "data", len = 10, name = "players.2.code" },
				[0x103] = { type = "data", len = 10, name = "players.3.code" },
				[0x10D] = { type = "data", len = 10, name = "players.4.code" },
				[0x117] = { type = "data", len = 241, name = "error_msg" },
			}
		},
	}
}

-- https://github.com/project-slippi/slippi-ssbm-asm/blob/9c36ffc5e4787c6caadfb12727c5fcff07d64642/Online/Online.s#L10
local ONLINE_BUF_ADDR = 0x804D6CBC

game.memorymap[ONLINE_BUF_ADDR] = {
	type = "pointer",
	name = "online",
	debug = true,
	struct = {
		-- https://github.com/project-slippi/slippi-ssbm-asm/blob/9c36ffc5e4787c6caadfb12727c5fcff07d64642/Online/Online.s#L182-L225
		[0x07] = { type = "u32", name = "rng_offset" }
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
	[0x04] = "character",
	[0x05] = "skin",
}

for id, address in ipairs(player_select_external_addresses) do
	for offset, name in pairs(player_select_external) do
		game.memorymap[address + offset] = {
			type = "u8",
			name = ("player.%i.select.%s"):format(id, name),
		}
	end
end

local player_card_addresses = {
	0x803F0E06,
	0x803F0E2A,
	0x803F0E4E,
	0x803F0E72,
}

local player_card = {
	[0x00] = "team",
	[0x01] = "mode",
	--[0x02] = "mode", -- Duplicate?
	[0x03] = "skin",
	[0x04] = "character",
	[0x05] = "hovered",
}

for id, address in ipairs(player_card_addresses) do
	for offset, name in pairs(player_card) do
		game.memorymap[address + offset] = {
			type = "byte",
			name = ("player.%i.card.%s"):format(id, name),
		}
	end
end

local startmatch_addr = 0x80480530

local startmatch_struct = {
	[0x00] = { type = "u8", name = "match.flags.game" },
	[0x01] = { type = "u8", name = "match.flags.friendlyfire" },
	[0x02] = { type = "u8", name = "match.flags.other" },
	[0x07] = { type = "bool", name = "match.bombrain" },
	[0x08] = { type = "bool", name = "match.teams" },
	[0x0B] = { type = "s8", name = "match.settings.item_frequency" },
	[0x0C] = { type = "s8", name = "match.settings.self_destruct" },
	[0x0E] = { type = "short", name = "match.stage" },
}

for offset, info in pairs(startmatch_struct) do
	game.memorymap[startmatch_addr + offset] = info
end

-- https://github.com/akaneia/m-ex/blob/42362a6b63e8d3d7c5477e7647125ee27adb1a17/MexTK/include/match.h#L45-L154
game.memorymap[0x8046DB68] = { type = "u8", name = "match.flags.timer"}

game.memorymap[0x804D640F] = { type = "bool", name = "match.paused" }

local match_info = 0x8046B6A0
local match_info_struct = {
	[0x0005] = { type = "bool", name = "match.playing" },
	[0x0008] = { type = "u8", name = "match.result" },
	[0x000E] = { type = "bool", name = "match.finished" },
}

local player_cursors_pointers = {
	0x804A0BC0,
	0x804A0BC4,
	0x804A0BC8,
	0x804A0BCC,
}

local player_cursor_struct = {
	--[0x00] = { type = "u32", name = "unknown_ptr" },
	[0x05] = { type = "u8", name = "state" }, -- The state of the pointer (0 = in the bottom area, 1 = holding coin, 2 = empty hand)
	[0x0B] = { type = "u8", name = "b_frame_counter" }, -- How many frames the player is holding B for (At 32, it will forcibly exit back to the menus)
	[0x0C] = { type = "float", name = "position.x" },
	[0x10] = { type = "float", name = "position.y" },
}

for port, addr in pairs(player_cursors_pointers) do
	game.memorymap[addr] = { type = "pointer", name = ("player.%i.cursor"):format(port), struct = player_cursor_struct }
end

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