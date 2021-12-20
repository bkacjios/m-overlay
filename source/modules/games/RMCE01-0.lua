-- Mario Kart Wii (NTSC-U, v1.0) (Issue #17)

-- Code based on RSBE01-2.lua

local core = require("games.core")

local game = core.newGame()

local ptr_addr = 0x809B8F4C --> addr + 0x08 -> addr + 0x0A -> the controller structs
local ctrl_offset = 0xB0

local controllers = { -- TODO: fix port issues
	ctrl_offset * 0,
	ctrl_offset * 1,
	ctrl_offset * 2,
	ctrl_offset * 3,
}

local controller_struct = {
	[0x00] = { type = "short",	name = "%d.buttons.pressed" },
	[0x02] = { type = "float",	name = "%d.joystick.x" },
	[0x06] = { type = "float",	name = "%d.joystick.y" },
	[0x96] = { type = "float",	name = "%d.cstick.x" },
	[0x9A] = { type = "float",	name = "%d.cstick.y" },
	[0x8C] = { type = "byte",	name = "%d.analog.l" },
	[0x8D] = { type = "byte",	name = "%d.analog.r" },
	[0x90] = { type = "byte",	name = "%d.plugged" },
}

game.memorymap[ptr_addr] = {
	type = "pointer";
	name = "controller";
	struct = {
		[0x08] = {
			type = "pointer";
			struct = {}
		}
	}
}

local ptr_offset = 0x0A
local controller_ptr = game.memorymap[ptr_addr].struct[0x08].struct

for port, address in ipairs(controllers) do
	for offset, info in pairs(controller_struct) do
		controller_ptr[ptr_offset + address + offset] = {
            type = info.type;
            debug = info.debug;
            name = info.name:format(port);
        }
    end
end

game.translateJoyStick = function(x, y) return x, y end
game.translateCStick = function(x, y) return x, y end

return game
