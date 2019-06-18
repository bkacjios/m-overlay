local map = {
	[0x80479D60] = { type = "int", name = "frame" },
	[0x80479D33] = { type = "byte", name = "menu" },
}

-- 804B302C = PAL

local controllers = {
	[1] = 0x804C1FAC + 0x44 * 0,
	[2] = 0x804C1FAC + 0x44 * 1,
	[3] = 0x804C1FAC + 0x44 * 2,
	[4] = 0x804C1FAC + 0x44 * 3,
}

local controller_struct = {
	[0x00] = { type = "int",	name = "buttons.pressed" },
	[0x04] = { type = "int",	name = "buttons.pressed_previous" },
	[0x08] = { type = "int",	name = "buttons.instant" },
	[0x10] = { type = "int",	name = "buttons.released" },
	[0x1C] = { type = "byte",	name = "analog.byte.l" },
	[0x1D] = { type = "byte",	name = "analog.byte.r" },
	[0x20] = { type = "float",	name = "joystick.x" },
	[0x24] = { type = "float",	name = "joystick.y" },
	[0x28] = { type = "float",	name = "cstick.x" },
	[0x2C] = { type = "float",	name = "cstick.y" },
	[0x30] = { type = "float",	name = "analog.float.l" },
	[0x34] = { type = "float",	name = "analog.float.r" },
	[0x41] = { type = "byte",	name = "plugged" },
}

for port, address in ipairs(controllers) do
	for offset, info in pairs(controller_struct) do
		map[address + offset] = {
			type = info.type,
			debug = info.debug,
			name = string.format("controller.%d.%s", port, info.name),
		}
	end
end

local stage_info = 0x8049E6C8

local stage_info_struct = {
	[0x0000] = { type = "float", name = "camera.limit.left" },
	[0x0004] = { type = "float", name = "camera.limit.right" },
	[0x0008] = { type = "float", name = "camera.limit.top" },
	[0x000C] = { type = "float", name = "camera.limit.bottom" },
	
	[0x0010] = { type = "float", name = "stage.offset.x" },
	[0x0014] = { type = "float", name = "stage.offset.y" },

	[0x0074] = { type = "float", name = "stage.blastzone.left" },
	[0x0078] = { type = "float", name = "stage.blastzone.right" },
	[0x007C] = { type = "float", name = "stage.blastzone.top" },
	[0x0080] = { type = "float", name = "stage.blastzone.bottom" },
}

for offset, info in pairs(stage_info_struct) do
	map[stage_info + offset] = info
end

local player_static_addresses = {
	0x80453080, -- Player 1
	0x80453F10, -- Player 2
	0x80454DA0, -- Player 3
	0x80455C30, -- Player 4
}

local player_static_struct = {
	[0x000] = { type = "int", name = "state" },
	[0x004] = { type = "int", name = "character" },
	[0x008] = { type = "int", name = "mode" },
	[0x00C] = { type = "short", name = "transformed" },
	[0x010] = { type = "float", name = "position.x" },
	[0x014] = { type = "float", name = "position.y" },
	[0x018] = { type = "float", name = "position.z" },
	[0x01C] = { type = "float", name = "partner_position.x" },
	[0x020] = { type = "float", name = "partner_position.y" },
	[0x024] = { type = "float", name = "partner_position.z" },
	[0x040] = { type = "float", name = "facing" },
	[0x044] = { type = "byte", name = "skin" },
	[0x045] = { type = "byte", name = "port" },
	[0x046] = { type = "byte", name = "color" },
	[0x047] = { type = "byte", name = "team" },
	[0x048] = { type = "byte", name = "port" },
	[0x049] = { type = "byte", name = "cpu_level" },
	[0x04A] = { type = "byte", name = "cpu_type" }, -- 4 = 20XX, 22 = normalish, 19 = Alt Normal
	[0x054] = { type = "float", name = "attack_ratio" },
	[0x058] = { type = "float", name = "damage_ratio" },
	[0x060] = { type = "short", name = "percent" },
	[0x062] = { type = "short", name = "percent_starting" },
	[0x064] = { type = "short", name = "stamina" },
	[0x068] = { type = "int", name = "falls" },
	[0x070] = { type = "int", name = "kills.1" },
	[0x074] = { type = "int", name = "kills.2" },
	[0x078] = { type = "int", name = "kills.3" },
	[0x07C] = { type = "int", name = "kills.4" },
	[0x080] = { type = "int", name = "kills.5" },
	[0x084] = { type = "int", name = "kills.6" },
	[0x08C] = { type = "short", name = "suicides" },
	[0x08E] = { type = "byte", name = "stocks" },
	[0x090] = { type = "int", name = "coins" },
	[0x094] = { type = "int", name = "coins_total" },
	[0x0A8] = { type = "int", name = "name_tag" },

	[0x0E8] = { type = "int", name = "attacks_count" },
	[0x0F0] = { type = "int", name = "attacks_landed" },

	-- Define these as pointers below
	--[0x0B0] = { type = "int", name = "entity" }, -- Pointer to player entity -> 0x80453130
	--[0x0B4] = { type = "int", name = "partner" }, -- Pointer to partner entity -> 0x80453134

	[0xD1C] = { type = "float", name = "damage_taken" },
	[0xD20] = { type = "float", name = "damage_peak" },
	[0xD24] = { type = "int", name = "damage_recovered" },
	[0xD28] = { type = "float", name = "damage_given" },
	[0xD60] = { type = "int", name = "attacks_landed2" },
	[0xDDC] = { type = "int", name = "air_time" },
	[0xDE0] = { type = "int", name = "ground_time" },
}

for id, address in ipairs(player_static_addresses) do
	for offset, info in pairs(player_static_struct) do
		map[address + offset] = {
			type = info.type,
			debug = info.debug,
			name = ("player.%i.%s"):format(id, info.name),
		}
	end
end

local entity_pointer_offsets = {
	[0xB0] = "entity", -- The "main" controllable character
	[0xB4] = "partner", -- Partner entity (For sheik/zelda/iceclimbers)
}

for id, address in ipairs(player_static_addresses) do
	for offset, name in pairs(entity_pointer_offsets) do
		map[address + offset] = {
			type = "pointer", -- This struct moves around in memory each match, so we track where
			name = ("player.%i.%s"):format(id, name),
			struct = {
				--[0x60 + 0x0000] = { type = "pointer", name = "base_entity" },

				[0x60 + 0x0004] = { type = "int", name = "character" },
				[0x60 + 0x0008] = { type = "int", name = "spawns" },
				[0x60 + 0x000C] = { type = "byte", name = "port" },
				[0x60 + 0x0010] = { type = "int", name = "action_state" },
				[0x60 + 0x0014] = { type = "int", name = "animation_state" },
				[0x60 + 0x0018] = { type = "int", name = "action_id" },
				[0x60 + 0x002C] = { type = "float", name = "facing" },
				[0x60 + 0x00B0] = { type = "float", name = "position.x" },
				[0x60 + 0x00B4] = { type = "float", name = "position.y" },
				[0x60 + 0x00B8] = { type = "float", name = "position.z" },
				[0x60 + 0x0080] = { type = "float", name = "velocity.x" },
				[0x60 + 0x0084] = { type = "float", name = "velocity.y" },
				[0x60 + 0x0088] = { type = "float", name = "velocity.z" },

				--[0x60 + 0x04B8] = { type = "float", name = "color.r" },

				[0x60 + 0x0610] = { type = "byte", name = "subcolor.r" },
				[0x60 + 0x0611] = { type = "byte", name = "subcolor.g" },
				[0x60 + 0x0612] = { type = "byte", name = "subcolor.b" },
				[0x60 + 0x0613] = { type = "byte", name = "subcolor.a" },

				[0x60 + 0x0619] = { type = "byte", name = "skin" },
				[0x60 + 0x061A] = { type = "byte", name = "color" }, -- 00 = no sub color, 01 = light, 02 = dark, 03 = black, 04 = gray, 05 = red (need code so doesnt freeze)
				[0x60 + 0x061B] = { type = "byte", name = "team" },
				[0x60 + 0x0128] = { type = "float", name = "friction" },
				[0x60 + 0x0168] = { type = "int", name = "jumps" },
				[0x60 + 0x016C] = { type = "float", name = "gravity" },
				[0x60 + 0x0170] = { type = "float", name = "terminal_velocity" },
				[0x60 + 0x0184] = { type = "float", name = "fastfall_velocity" },
				[0x60 + 0x0198] = { type = "float", name = "weight" },
				[0x60 + 0x019C] = { type = "float", name = "scale" },

				[0x60 + 0x01F4] = { type = "float", name = "landing_lag.normal" },
				[0x60 + 0x01F8] = { type = "float", name = "landing_lag.nair" },
				[0x60 + 0x01FC] = { type = "float", name = "landing_lag.fair" },
				[0x60 + 0x0200] = { type = "float", name = "landing_lag.bair" },
				[0x60 + 0x0204] = { type = "float", name = "landing_lag.uair" },
				[0x60 + 0x0208] = { type = "float", name = "landing_lag.dair" },

				[0x60 + 0x18C4] = { type = "int", name = "attacker" },
				[0x60 + 0x1830] = { type = "float", name = "percent" },

				[0x60 + 0x184C] = { type = "int", name = "flinch_animation" }, -- flinch from 0=low , 1=mid , 2=high
				[0x60 + 0x18B0] = { type = "float", name = "knockback_resistance" }, -- 5 for Nana, 20 for Giga-Bowser, 0 on death

				[0x60 + 0x1838] = { type = "float", name = "add_percent" }, -- Setting this to a value will apply the value as damage the next frame
				[0x60 + 0x18F0] = { type = "int", name = "sub_percent" }, -- Setting this to a value will apply the value as a heal the next frame

				[0x60 + 0x1A94] = { type = "int", name = "cpu_type" },
				[0x60 + 0x1A98] = { type = "int", name = "cpu_level" },
			},
		}
	end
end

local match_info = 0x8046B6A0

local match_info_struct = {
	[0x0008] = { type = "byte", name = "match.winner" },
	[0x000D] = { type = "byte", name = "match.last_player_death" },
	[0x000E] = { type = "byte", name = "match.finished", debug = true },

	[0x0024] = { type = "int", name = "match.frame" },
	[0x0028] = { type = "int", name = "match.timer.seconds" },
	[0x002C] = { type = "short", name = "match.timer.millis" },

	[0x24D0] = { type = "byte", name = "match.teams" },
	[0x24D3] = { type = "byte", name = "match.item.frequency" },
	[0x24D4] = { type = "byte", name = "match.self_destruct" },
	[0x24E8] = { type = "int", name = "match.item.flags.1" },
	[0x24EC] = { type = "int", name = "match.item.flags.2" },
}

for offset, info in pairs(match_info_struct) do
	map[match_info + offset] = info
end

return map