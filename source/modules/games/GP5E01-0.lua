-- Mario Party 5 (NTSC v1.0)

local core = require("games.core")

local game = core.newGame()

local addr = 0x802885F8

local controllers = {
	[1] = addr,
	[2] = addr + 1,
	[3] = addr + 2,
	[4] = addr + 3,
}

local controller_struct = {
	-- [0x00] = { type = "short",	name = "controller.%d.buttons.pressed" },
	[40] = { type = "sbyte",	name = "controller.%d.joystick.x" },
	[36] = { type = "sbyte",	name = "controller.%d.joystick.y" },
	[32] = { type = "sbyte",	name = "controller.%d.cstick.x" },
	[28] = { type = "sbyte",	name = "controller.%d.cstick.y" },
	[24] = { type = "byte",	    name = "controller.%d.analog.l" },
	[20] = { type = "byte", 	name = "controller.%d.analog.r" },
	[8] = { type = "u8",		name = "controller.%d.plugged" },
}

for port in ipairs(controllers) do
    game.memorymap[controllers[1] + (port - 1) * 2] = {
        type = "short",
        name = ("controller.%d.buttons.pressed"):format(port),
    }
end

for port, address in ipairs(controllers) do
	for offset, info in pairs(controller_struct) do
		game.memorymap[address + offset] = {
			type = info.type,
			debug = info.debug,
			name = info.name:format(port),
		}
	end
end

game.translateJoyStick = core.translateJoyStick
game.translateTriggers = core.translateTriggers

return game
