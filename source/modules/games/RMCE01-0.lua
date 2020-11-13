-- Mario Kart Wii (NTSC-U, v1.0) (Issue #17)

-- Code based on RSBE01-2.lua

local min = math.min

local core = require("games.core")

local game = {
	memorymap = {}
}

local addr = 0x9037CDBA
local offset = 0xB0

local controllers = {
	[1] = addr + offset * 0,
	[2] = addr + offset * 1,
	[3] = addr + offset * 2,
	[4] = addr + offset * 3,
}

local controller_struct = {
	[0x00] = { type = "short",	name = "controller.%d.buttons.pressed" },
	[0x02] = { type = "float",	name = "controller.%d.joystick.x" },
	[0x06] = { type = "float",	name = "controller.%d.joystick.y" },
	[0x96] = { type = "float",	name = "controller.%d.cstick.x" },
	[0x9A] = { type = "float",	name = "controller.%d.cstick.y" },
	[0x8C] = { type = "byte",	name = "controller.%d.analog.l" },
	[0x8D] = { type = "byte",	name = "controller.%d.analog.r" },
	[0x90] = { type = "byte",	name = "controller.%d.plugged" },
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

game.translateTriggers = core.translateTriggers

return game
