-- This is the environment used when loading our custom Panel classes

local env = {
	-- QOL Stuff
	graphics = love.graphics,
	timer = love.timer,
	audio = love.audio,
	filesystem = love.filesystem,
	window = love.window,

	-- Incase someone forgets to define these
	PANEL = {},
	SKIN = {},

	gui = require("gui"),
	melee = require("smash.melee"),
}

return env