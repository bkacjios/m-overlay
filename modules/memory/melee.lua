local map = {
	[0x80479D60] = { type = "int", name = "frame" },
}

-- 804B302C = PAL

local controllers = {
	[1] = 0x804C1FAC + 0x44 * 0,
	[2] = 0x804C1FAC + 0x44 * 1,
	[3] = 0x804C1FAC + 0x44 * 2,
	[4] = 0x804C1FAC + 0x44 * 3,
}

local controller_struct = {
	[0x00] = { type = "int",	name = "controller.%d.buttons.pressed" },
	[0x04] = { type = "int",	name = "controller.%d.buttons.pressed_previous" },
	[0x08] = { type = "int",	name = "controller.%d.buttons.instant" },
	[0x10] = { type = "int",	name = "controller.%d.buttons.released" },
	[0x1C] = { type = "byte",	name = "controller.%d.analog.byte.l" },
	[0x1D] = { type = "byte",	name = "controller.%d.analog.byte.r" },
	[0x20] = { type = "float",	name = "controller.%d.joystick.x" },
	[0x24] = { type = "float",	name = "controller.%d.joystick.y" },
	[0x28] = { type = "float",	name = "controller.%d.cstick.x" },
	[0x2C] = { type = "float",	name = "controller.%d.cstick.y" },
	[0x30] = { type = "float",	name = "controller.%d.analog.float.l" },
	[0x34] = { type = "float",	name = "controller.%d.analog.float.r" },
	[0x41] = { type = "byte",	name = "controller.%d.plugged" },
}

for port, address in ipairs(controllers) do
	for offset, info in pairs(controller_struct) do
		map[address + offset] = {
			type = info.type,
			debug = info.debug,
			name = info.name:format(port),
		}
	end
end

local entity_pointer_offsets = {
	[0xB0] = "entity",
	[0xB4] = "partner", -- Partner entity (For sheik/zelda/iceclimbers)
}

local player_static_addresses = {
	0x00453080, -- Player 1
	0x00453F10, -- Player 2
	0x00454DA0, -- Player 3
	0x00455C30, -- Player 4
}

for id, address in ipairs(player_static_addresses) do
	for offset, name in pairs(entity_pointer_offsets) do
		map[address + offset] = {
			type = "pointer",
			name = ("player.%i.%s"):format(id, name),
			debug = false,
			struct = {
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

return map