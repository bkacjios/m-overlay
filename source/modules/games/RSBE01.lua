-- Super Smash Bros. Brawl (NTSC v1.01)

local map = {}

--[[
Brawl seems to have 4 addresses dedicated to controller input values, each address polling around 15fps.
If you poll all four addresses for the controller values, you get 60fps input!

Structure:
	Polling Address 1 [0x805BA480]
		Port 1 [0x805BA480 + 0x40 * 0]
		Port 2 [0x805BA480 + 0x40 * 1]
		Port 3 [0x805BA480 + 0x40 * 2]
		Port 4 [0x805BA480 + 0x40 * 3]
	Polling Address 2 [0x805BA680]
		Port 1 [0x805BA680 + 0x40 * 0]
		Port 2 [0x805BA680 + 0x40 * 1]
		Port 3 [0x805BA680 + 0x40 * 2]
		Port 4 [0x805BA680 + 0x40 * 3]
	Polling Address 3 [0x805BA880]
		Port 1 [0x805BA880 + 0x40 * 0]
		Port 2 [0x805BA880 + 0x40 * 1]
		Port 3 [0x805BA880 + 0x40 * 2]
		Port 4 [0x805BA880 + 0x40 * 3]
	Polling Address 4 [0x805BAA80]
		Port 1 [0x805BAA80 + 0x40 * 0]
		Port 2 [0x805BAA80 + 0x40 * 1]
		Port 3 [0x805BAA80 + 0x40 * 2]
		Port 4 [0x805BAA80 + 0x40 * 3]
]]

local polling_addresses = {
	0x805BA480,
	0x805BA680,
	0x805BA880,
	0x805BAA80,
}

local controllers = {
	[1] = 0x40 * 0,
	[2] = 0x40 * 1,
	[3] = 0x40 * 2,
	[4] = 0x40 * 3,
}

local controller_struct = {
	[0x04] = { type = "int",	name = "controller.%d.buttons.pressed" },
	[0x34] = { type = "sbyte",	name = "controller.%d.joystick.x" },
	[0x35] = { type = "sbyte",	name = "controller.%d.joystick.y" },
	[0x36] = { type = "sbyte",	name = "controller.%d.cstick.x" },
	[0x37] = { type = "sbyte",	name = "controller.%d.cstick.y" },
	[0x38] = { type = "byte",	name = "controller.%d.analog.l" },
	[0x39] = { type = "byte",	name = "controller.%d.analog.r" },
	[0x3C] = { type = "byte",	name = "controller.%d.plugged" },
}

for _, polling_addr in ipairs(polling_addresses) do
	-- For every polling address..
	for port, controller_addr in ipairs(controllers) do
		-- For every controller 
		for offset, info in pairs(controller_struct) do
			map[polling_addr + controller_addr + offset] = {
				type = info.type,
				debug = info.debug,
				name = info.name:format(port),
			}
		end
	end
end

return map