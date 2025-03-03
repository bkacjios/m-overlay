local core = {}

local GAME = {}
GAME.__index = GAME

function GAME:map(address, structure)
	self.memorymap[address] = structure
end

function core.newGame(...)
	local game = setmetatable({
		memorymap = {},
		translateJoyStick = core.translateJoyStick,
		translateCStick = core.translateCStick,
		translateTriggers = core.translateTriggers,
	}, GAME)

	local genericControllers = {...}

	if #genericControllers > 0 then
		for k, addr in ipairs(genericControllers) do
			core.loadGenericControllerMap(addr, game)
		end
	end

	return game
end

function core.loadGenericControllerMap(addr, game)
	local controllers = {
		[1] = addr + 0xC * 0,
		[2] = addr + 0xC * 1,
		[3] = addr + 0xC * 2,
		[4] = addr + 0xC * 3,
	}

	local controller_struct = {
		[0x0] = { type = "u16",	name = "controller.%d.buttons.pressed" },
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
end

local abs = math.abs

-- These functions seem to apply to many games

function core.translateJoyStick(x, y)
	x = x/72
	y = y/72

	local near = 1 - (abs(abs(x) - abs(y)))

	local angle = math.atan2(x, y)
	local mag = math.sqrt(x*x + y*y)

	-- Amplify the magnitute when x,y values are headed towards a diagonal
	return x + math.sin(angle) * mag * near * 0.25, y + math.cos(angle) * mag * near * 0.25
end

function core.translateCStick(x, y)
	x = x/59
	y = y/59

	local near = 1 - (abs(abs(x) - abs(y)))

	local angle = math.atan2(x, y)
	local mag = math.sqrt(x*x + y*y)

	-- Amplify the magnitute when x,y values are headed towards a diagonal
	return x + math.sin(angle) * mag * near * 0.25, y + math.cos(angle) * mag * near * 0.25
end

local min = math.min

function core.translateTriggers(l, r)
	return min(1, l/125), min(1, r/125)
end

return core