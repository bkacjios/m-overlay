-- The Legend of Zelda: Collectors Edition (NTSC-U v1.0)

local core = require("games.core")

local controllerLocations = { -- these could be pointers, i'm not sure yet
	menu = 0x801337B8,
	oot = 0x80134C58,
	mm = 0x8013E1B8,
	z1 = 0x800AAF60,
	z2 = 0x800CA6A0,
}

local game = {
	memorymap = {
		[0x80BDA3CB] = { type = "u8", name = "oot.ucode" },
		[0x80CB033B] = { type = "u8", name = "mm.ucode" },
		[0x80080644] = { type = "u8", name = "z1.qfc"},
		[0x800A0544] = { type = "u8", name = "z2.qfc"},
	}
}

for gamename, addr in pairs(controllerLocations) do
	local controllers = {
		[1] = addr + 0xC * 0,
		[2] = addr + 0xC * 1,
		[3] = addr + 0xC * 2,
		[4] = addr + 0xC * 3,
	}

	local controller_struct = {
		[0x0] = { type = "short",	name = "controller.%s.%d.buttons.pressed" },
		[0x2] = { type = "sbyte",	name = "controller.%s.%d.joystick.x" },
		[0x3] = { type = "sbyte",	name = "controller.%s.%d.joystick.y" },
		[0x4] = { type = "sbyte",	name = "controller.%s.%d.cstick.x" },
		[0x5] = { type = "sbyte",	name = "controller.%s.%d.cstick.y" },
		[0x6] = { type = "byte",	name = "controller.%s.%d.analog.l" },
		[0x7] = { type = "byte",	name = "controller.%s.%d.analog.r" },
		[0xA] = { type = "byte",	name = "controller.%s.%d.plugged" },
	}

	for port, address in ipairs(controllers) do
		for offset, info in pairs(controller_struct) do
			game.memorymap[address + offset] = {
				type = info.type,
				debug = info.debug,
				name = info.name:format(gamename, port),
			}
		end
	end

	game.translateJoyStick = core.translateJoyStick
	game.translateTriggers = core.translateTriggers
end

return game
