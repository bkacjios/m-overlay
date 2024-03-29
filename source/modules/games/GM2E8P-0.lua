-- Super Monkey Ball 2 (NTSC v1.0)

local core = require("games.core")

local game = core.newGame()

local controllers = {
	[1] = 0x80145210 + 0x3C * 0,
	[2] = 0x80145210 + 0x3C * 1,
	[3] = 0x80145210 + 0x3C * 2,
	[4] = 0x80145210 + 0x3C * 3,
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

function game.translateJoyStick(x, y)
	x = x/100
	y = y/100
	return x,y
end

game.translateCStick = game.translateJoyStick

local min = math.min

function game.translateTriggers(l, r)
	return min(1, l/125), min(1, r/125)
end

return game
