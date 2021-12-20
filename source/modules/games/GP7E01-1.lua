-- Mario Party 7 (NTSC v1.1)

-- similar to MP6: this game also straight up doesn't use the d-pad

local core = require("games.core")

local game = core.newGame()

local addr = 0x802F2C90

local controllers = {
	[1] = addr,
	[2] = addr + 1,
	[3] = addr + 2,
	[4] = addr + 3,
}

local controller_struct = {
	-- [0x00] = { type = "short",	name = "controller.%d.buttons.pressed" },
	[44] = { type = "sbyte",	name = "controller.%d.joystick.x" },
	[40] = { type = "sbyte",	name = "controller.%d.joystick.y" },
	[36] = { type = "sbyte",	name = "controller.%d.cstick.x" },
	[32] = { type = "sbyte",	name = "controller.%d.cstick.y" },
	[28] = { type = "byte",	    name = "controller.%d.analog.l" },
	[24] = { type = "byte", 	name = "controller.%d.analog.r" },
	[8] = { type = "u8",		name = "controller.%d.plugged" }, -- similar to melee, where plugging in a controller sets a byte to 00 and unplugging does nothing
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

function game.translateJoyStick(x, y)
	x = x/56
	y = y/56
	return x, y
end

function game.translateCStick(x, y)
	x = x/44
	y = y/44
	return x, y
end

return game
