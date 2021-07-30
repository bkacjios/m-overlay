-- This is the environment used when loading our custom Panel classes

local color = require("util.color")

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

	unpackcolor = unpackcolor,
	color = color,
	HSL = HSL,
	HSV = HSV,
	RGBToHSV = RGBToHSV,
	ColorToHSV = ColorToHSV,

	gui = require("gui"),
}

return env