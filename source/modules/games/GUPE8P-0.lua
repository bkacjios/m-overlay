--Shadow The Hedgehog (NTSC-U)

local core = require("games.core")

local game = core.newGame(0x805A5810)

local controllers = {
	[1] = 0x805A5810,
}

local controller_struct = {
		[0x0] = { type = "u16",		name = "controller.%d.buttons.pressed" },
		[0x2] = { type = "sbyte",	name = "controller.%d.joystick.x" },
		[0x3] = { type = "sbyte",	name = "controller.%d.joystick.y" },
		[0x4] = { type = "sbyte",	name = "controller.%d.cstick.x" },
		[0x5] = { type = "sbyte",	name = "controller.%d.cstick.y" },
		[0x6] = { type = "byte",	name = "controller.%d.analog.l" },
		[0x7] = { type = "byte",	name = "controller.%d.analog.r" },
	}

function game.translateJoyStick(x, y)
	--Left = 25 <- 127
	--Neutral = -128
	--Right = -127 -> -25
	if x > 0 
		then
			x = (math.abs(x)-127)/102
			x = math.min(x, 1)
		else 
			x = -(math.abs(x)-127)/102
			x = math.max(x,-1) 
	end
	if y > 0 
		then 
			y = (math.abs(y)-127)/102
			y = math.min(y, 1)
		else 
			y = -(math.abs(y)-127)/102
			y = math.max(y,-1) 
	end
	return x, y
end
 
game.translateCStick = game.translateJoyStick
 
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