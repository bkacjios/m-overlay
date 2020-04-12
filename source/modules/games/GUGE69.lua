-- Need for Speed: Underground 2 (NTSC)

local game = {
	memorymap = {}
}

local controllers = {
	[1] = 0x803E642C + 0xC * 0,
	[2] = 0x803E642C + 0xC * 1,
	[3] = 0x803E642C + 0xC * 2,
	[4] = 0x803E642C + 0xC * 3,
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

local abs = math.abs

function game.translateAxis(x, y)
	x = x/72
	y = y/72

	local near = 1 - (abs(abs(x) - abs(y))) * 0.72

	local angle = math.atan2(x, y)
	local mag = math.sqrt(x*x + y*y)

	-- Amplify the magnitute when x,y values are headed towards a diagonal
	return x + math.sin(angle) * mag * near * 0.28, y + math.cos(angle) * mag * near * 0.28
end

local min = math.min

function game.translateTriggers(l, r)
	return min(1, l/125), min(1, r/125)
end

return game