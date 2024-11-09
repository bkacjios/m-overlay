-- SSX Tricky (NTSC v1.0)

local core = require("games.core")

local game = core.newGame()

local controllers = {
	[1] = 0x8072AEA5 + 0x80 * 0,
	[2] = 0x8072AEA5 + 0x80 * 1,
}

local controller_struct = {
	[0x00] = { type = "u8",		name = "controller.%d.plugged" },
	[0x03] = { type = "u32",	name = "controller.%d.buttons.pressed" },
	[0x07] = { type = "u32",	name = "controller.%d.buttons.instant" },
	[0x13] = { type = "float",	name = "controller.%d.joystick.x" },
	[0x17] = { type = "float",	name = "controller.%d.joystick.y" },
	[0x1B] = { type = "float",	name = "controller.%d.cstick.x" },
	[0x1F] = { type = "float",	name = "controller.%d.cstick.y" },
	[0x3D] = { type = "u8",		name = "controller.%d.analog.byte.l" },
	[0x3E] = { type = "u8",		name = "controller.%d.analog.byte.r" },
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