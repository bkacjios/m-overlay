-- This is the environment used when loading our custom Panel classes

local color = require("util.color")

local env = {
	-- QOL Stuff
	audio	= love.audio,
	data	= love.data,
	event	= love.event,
	filesystem = love.filesystem,
	font = love.font,
	graphics = love.graphics,
	timer = love.timer,
	window = love.window,

	unpackcolor = unpackcolor,
	color = color,
	HSL = HSL,
	HSV = HSV,
	RGBToHSV = RGBToHSV,
	ColorToHSV = ColorToHSV,

	class = require("class"),
	gui = require("gui"),
}

return env