-- Mario Kart Wii (NTSC-U, v1.0) (Issue #17)

-- Code based on RSBE01-2.lua

local min = math.min

local core = require("games.core")

local game = {
	memorymap = {}
}

local ptr_addr = 0x809B8F4C --> addr + 0x08 -> addr + 0x0A -> the controller structs
local ptr_offset = 0x0A
local ctrl_offset = 0xB0

local controllers = {
	ctrl_offset * 0,
	ctrl_offset * 1,
	ctrl_offset * 2,
	ctrl_offset * 3,
}

local controller_struct = {
	[0x00] = { type = "short",	name = "controller.%d.buttons.pressed" },
	[0x02] = { type = "float",	name = "controller.%d.joystick.x" },
	[0x06] = { type = "float",	name = "controller.%d.joystick.y" },
	[0x96] = { type = "float",	name = "controller.%d.cstick.x" },
	[0x9A] = { type = "float",	name = "controller.%d.cstick.y" },
	[0x8C] = { type = "byte",	name = "controller.%d.analog.l" },
	[0x8D] = { type = "byte",	name = "controller.%d.analog.r" },
	[0x90] = { type = "byte",	name = "controller.%d.plugged" },
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

for port, address in ipairs(controllers) do
    for offset, info in pairs(controller_struct) do
        game.memorymap[ptr_addr].struct[0x08].struct[0x0A + address + offset] = {
            type = info.type;
            debug = info.debug;
            name = info.name:format(port);
        }
    end
end

game.translateAxis = function(x, y) return x, y end
game.translateTriggers = core.translateTriggers

return game
