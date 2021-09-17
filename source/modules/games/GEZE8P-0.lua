-- Billy Hatcher and the Giant Egg (NTSC-U v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

local addr = 0x80279822
local off = 0x40

local controllers = {
	[1] = addr + off * 0,
	[2] = addr + off * 1,
	[3] = addr + off * 2,
	[4] = addr + off * 3,
}

local controller_struct = {
	[0x00] = { type = "u16",	name = "controller.%d.buttons.pressed" },
	[0x16] = { type = "u16",	name = "controller.%d.analog.r" },
	[0x18] = { type = "u16",	name = "controller.%d.analog.l" },
	[0x1A] = { type = "u16",	name = "controller.%d.joystick.x" },
	[0x1C] = { type = "u16",	name = "controller.%d.joystick.y" },
	[0x1E] = { type = "u16",	name = "controller.%d.cstick.x" },
	[0x20] = { type = "u16",	name = "controller.%d.cstick.y" },
	[0x32] = { type = "byte",	name = "controller.%d.plugged" },
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

local function convertAxis(a)
	if a > 0xFF then
		a = a - 0xFFFF - 1
	end
	return a
end

game.translateJoyStick = function(x, y)
	x = convertAxis(x)
	y = convertAxis(y)
	return x/100, y/100
end

game.translateCStick = function(x, y)
	x = convertAxis(x)
	y = convertAxis(y)
	return x/44, y/44
end

game.translateTriggers = function(l, r) return l/127, r/127 end

return game