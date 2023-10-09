-- Mario Superstar Baseball (NTSC-U v1.0)

local core = require("games.core")

local game = core.newGame()

-- local controllers = {
-- 	[1] = 0x8026BB60 + 0x10 * 0,
-- 	[2] = 0x8026BB60 + 0x10 * 1,
-- 	[3] = 0x8026BB60 + 0x10 * 2,
-- 	[4] = 0x8026BB60 + 0x10 * 3,
-- }

local controllers = {
	[1] = 0x803C77B8 + 0x20 * 0,
	[2] = 0x803C77B8 + 0x20 * 1,
	[3] = 0x803C77B8 + 0x20 * 2,
	[4] = 0x803C77B8 + 0x20 * 3,
}

local controller_struct = {
	[0x00] = { type = "u16",	name = "controller.%d.buttons.pressed" },
	[0x02] = { type = "u16",	name = "controller.%d.buttons.instant" },
	[0x04] = { type = "u16",	name = "controller.%d.buttons.pressed_previous" },
	[0x08] = { type = "u8",		name = "controller.%d.plugged" },
	[0x10] = { type = "sbyte",	name = "controller.%d.joystick.x" },
	[0x11] = { type = "sbyte",	name = "controller.%d.joystick.y" },
	[0x12] = { type = "sbyte",	name = "controller.%d.cstick.x" },
	[0x13] = { type = "sbyte",	name = "controller.%d.cstick.y" },
	[0x14] = { type = "u8",		name = "controller.%d.analog.l" },
	[0x15] = { type = "u8",		name = "controller.%d.analog.r" },
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

game.translateJoyStick = function(x, y) return x/72, y/72 end
game.translateCStick = function(x, y) return x/59, y/59 end
game.translateTriggers = function(l, r) return l/150, r/150 end

return game
