-- Pikmin 2 (NTSC v1.0)

local core = require("games.core")
local memory = require("memory")

local version = memory.process:readUByte(0x80005426)

local game = {
	memorymap = {}
}

game.memorymap[0x80005426] = { type = "byte", name = "revision", debug = true }

local controller_addrs = {
	[0xC5] = 0x80506F48, -- Demo version
	[0xC6] = 0x80507008, -- Retail version
}

memory.hook("revision", "Pikmin 2 - Load Version Speicific Offsets", function(revision)
	local controller_map = {}

	local controller_addr = controller_addrs[revision]

	local controllers = {
		[1] = controller_addr + 0xC * 0,
		[2] = controller_addr + 0xC * 1,
		[3] = controller_addr + 0xC * 2,
		[4] = controller_addr + 0xC * 3,
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
			controller_map[address + offset] = {
				type = info.type,
				debug = info.debug,
				name = info.name:format(port),
			}
		end
	end

	memory.loadmap(controller_map)
end)

game.translateAxis = core.translateAxis
game.translateTriggers = core.translateTriggers

return game