-- Super Smash Bros. Melee (NTSC v1.02)

local game = {
	memorymap = {}
}

local controllers = {
	[1] = 0x804C1FAC + 0x44 * 0,
	[2] = 0x804C1FAC + 0x44 * 1,
	[3] = 0x804C1FAC + 0x44 * 2,
	[4] = 0x804C1FAC + 0x44 * 3,
}

local controller_struct = {
	[0x00] = { type = "int",	name = "controller.%d.buttons.pressed" },
	--[0x04] = { type = "int",	name = "controller.%d.buttons.pressed_previous" },
	--[0x08] = { type = "int",	name = "controller.%d.buttons.instant" },
	--[0x10] = { type = "int",	name = "controller.%d.buttons.released" },
	--[0x1C] = { type = "byte",	name = "controller.%d.analog.byte.l" },
	--[0x1D] = { type = "byte",	name = "controller.%d.analog.byte.r" },
	[0x20] = { type = "float",	name = "controller.%d.joystick.x" },
	[0x24] = { type = "float",	name = "controller.%d.joystick.y" },
	[0x28] = { type = "float",	name = "controller.%d.cstick.x" },
	[0x2C] = { type = "float",	name = "controller.%d.cstick.y" },
	[0x30] = { type = "float",	name = "controller.%d.analog.l" },
	[0x34] = { type = "float",	name = "controller.%d.analog.r" },
	[0x41] = { type = "byte",	name = "controller.%d.plugged" },
}

local player_static_addresses = {
	0x80453080, -- Player 1
	0x80453F10, -- Player 2
	0x80454DA0, -- Player 3
	0x80455C30, -- Player 4
}

local player_static_struct = {
	[0x004] = { type = "int", name = "character" },
	[0x00C] = { type = "short", name = "transformed" },
	[0x044] = { type = "byte", name = "skin" },
	[0x046] = { type = "byte", name = "color" },
	[0x047] = { type = "byte", name = "team" },
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
			debug = false,
			struct = {
				[0x60 + 0x0004] = { type = "float", name = "character" },
				[0x60 + 0x0619] = { type = "byte", name = "skin" },
				[0x60 + 0x061A] = { type = "byte", name = "color" },
				[0x60 + 0x061B] = { type = "byte", name = "team" },

				[0x60 + 0x0620] = { type = "float", name = "controller.joystick.x" },
				[0x60 + 0x0624] = { type = "float", name = "controller.joystick.y" },
				[0x60 + 0x0638] = { type = "float", name = "controller.cstick.x" },
				[0x60 + 0x063C] = { type = "float", name = "controller.cstick.y" },
				[0x60 + 0x0650] = { type = "float", name = "controller.analog.float" },
				[0x60 + 0x065C] = { type = "int",	name = "controller.buttons.pressed" },
			},
		}
	end
end

game.memorymap[0x80479D33] = { type = "byte", name = "menu" }
game.memorymap[0x804807C8] = { type = "bool", name = "teams" }

game.memorymap[0x80BDD44A] = {
	type = "data",
	len = 31,
	name = "slippi.player.1.name",
	debug = true
}

game.memorymap[0x80BDD469] = {
	type = "data",
	len = 31,
	name = "slippi.player.2.name",
	debug = true
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

function game.translateAxis(x, y)
	return x, y
end

function game.translateTriggers(l, r)
	return l, r
end

return game