-- Metroid Prime 2: Echoes (NTSC v1.0)

local core = require("games.core")

local game = {
	memorymap = {}
}

-- Pointer to a struct that contains the controller data
local game_data_loc = 0x803C5AF8

local controller_struct = {
	[0x0] = { type = "short",	name = "%d.buttons.pressed" },
	[0x2] = { type = "sbyte",	name = "%d.joystick.x" },
	[0x3] = { type = "sbyte",	name = "%d.joystick.y" },
	[0x4] = { type = "sbyte",	name = "%d.cstick.x" },
	[0x5] = { type = "sbyte",	name = "%d.cstick.y" },
	[0x6] = { type = "byte",	name = "%d.analog.l" },
	[0x7] = { type = "byte",	name = "%d.analog.r" },
	[0xA] = { type = "byte",	name = "%d.plugged" },
}

local controller_ptr = {
	type = "pointer",
	name = "controller",
	struct = {}
}

for i=1,4 do
	for offset, info in pairs(controller_struct) do
		controller_ptr.struct[0x04 + (0xC * (i-1)) + offset] = {
			type = info.type,
			debug = info.debug,
			name = info.name:format(i),
		}
	end
end

game.memorymap[game_data_loc] = controller_ptr

game.translateJoyStick = core.translateJoyStick
game.translateTriggers = core.translateTriggers

return game
