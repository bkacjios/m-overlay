-- Kirby's Airride (NTSC-J v1.0)

local game = {
	memorymap = {}
}

local addr = 0x80585B64
local off = 0x44

local controllers = {
	[1] = addr + off * 0,
	[2] = addr + off * 1,
	[3] = addr + off * 2,
	[4] = addr + off * 3,
}

-- Notably similar addresses to Melee, which makes sense since both games are made by HAL.
local controller_struct = {
	[0x00] = { type = "int",	name = "controller.%d.buttons.pressed" },
	[0x20] = { type = "float",	name = "controller.%d.joystick.x" },
	[0x24] = { type = "float",	name = "controller.%d.joystick.y" },
	[0x28] = { type = "float",	name = "controller.%d.cstick.x" },
	[0x2C] = { type = "float",	name = "controller.%d.cstick.y" },
	[0x30] = { type = "float",	name = "controller.%d.analog.l" },
	[0x34] = { type = "float",	name = "controller.%d.analog.r" },
	[0x41] = { type = "byte",	name = "controller.%d.plugged" },

	-- A note about plugged:
	-- Byte 0x41 of each controller is set from 0x00 to 0x01 only after the 
	-- controller has been plugged in or the game was started with the 
	-- controller plugged in, however, the overlay does not seem to
	-- detect this behavior, therefore showing all controllers regardless
	-- of memory status as unplugged.

	-- Melee has a similar issue, but instead of setting byte 0x41 to 0x01,
	-- it starts as 0xFF and gets set to 0x00. 

	-- I've fixed this issue by detecting whether or not the current game is
	-- Kirby Air Ride and changing the number to compare against from 0x00 to
	-- 0x01 for Kirby Air Ride only.
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
game.translateTriggers = function(l, r) return l, r end

game.pluggedValue = 0x01 -- value the game sets the controller.plugged byte to

return game
