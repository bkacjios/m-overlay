-- Mario Golf - Toadstool Tour (JP v1.0)

local core = require("games.core")

local game = core.newGame()

local controllers = {
	[1] = 0x8026EF60 + 0x38 * 0,
	[2] = 0x8026EF60 + 0x38 * 1,
	[3] = 0x8026EF60 + 0x38 * 2,
	[4] = 0x8026EF60 + 0x38 * 3,
}

local controller_struct = {
	[0x00] = { type = "u16",	name = "controller.%d.buttons.pressed" },
	[0x02] = { type = "u16",	name = "controller.%d.buttons.pressed_previous" },
	[0x04] = { type = "u16",	name = "controller.%d.buttons.instant" },
	[0x06] = { type = "u16",	name = "controller.%d.buttons.released" },
	[0x1B] = { type = "u8",		name = "controller.%d.analog.byte.l" },
	[0x1C] = { type = "u8",		name = "controller.%d.analog.byte.r" },
	[0x1D] = { type = "u8",		name = "controller.%d.plugged" },
	[0x20] = { type = "float",	name = "controller.%d.joystick.x" },
	[0x24] = { type = "float",	name = "controller.%d.joystick.y" },
	[0x28] = { type = "float",	name = "controller.%d.cstick.x" },
	[0x2C] = { type = "float",	name = "controller.%d.cstick.y" },
	[0x30] = { type = "float",	name = "controller.%d.analog.l" },
	[0x34] = { type = "float",	name = "controller.%d.analog.r" },
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

game.translateJoyStick = function(x, y) return x, y end
game.translateCStick = function(x, y) return x, y end
game.translateTriggers = function(l, r) return l, r end

return game