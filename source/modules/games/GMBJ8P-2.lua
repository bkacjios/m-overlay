-- Super Monkey Ball (NTSC-J v1.2)

local core = require("games.core")

local game = core.newGame()

local addr = 0x801F10C0
local offset = 0x3C

local controllers = {
	[1] = addr + offset * 0,
	[2] = addr + offset * 1,
	[3] = addr + offset * 2,
	[4] = addr + offset * 3,
}

local controller_struct = {
	[0x0] = { type = "short",	name = "controller.%d.buttons.pressed" },
	[0x2] = { type = "sbyte",	name = "controller.%d.joystick.x" },
	[0x3] = { type = "sbyte",	name = "controller.%d.joystick.y" },
	[0x4] = { type = "sbyte",	name = "controller.%d.cstick.x" },
	[0x5] = { type = "sbyte",	name = "controller.%d.cstick.y" },
	[0x6] = { type = "byte",	name = "controller.%d.analog.l" },
	[0x7] = { type = "byte",	name = "controller.%d.analog.r" },
	[0xA] = { type = "byte",	name = "controller.%d.plugged" },
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

return game
