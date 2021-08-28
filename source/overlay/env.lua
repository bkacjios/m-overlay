-- This is the environment used when loading our custom skin classes

local perspective = require("perspective")
local overlay = require("overlay")
local color = require("util.color")
local memory = require("memory")
local melee = require("melee")
local gui = require("gui")

local env = {
	-- QOL Stuff
	graphics = love.graphics,
	timer = love.timer,
	audio = love.audio,
	filesystem = love.filesystem,
	window = love.window,

	-- Incase someone forgets to define these
	SKIN = {},

	color = color,

	memory = memory,
	melee = melee,

	perspective = perspective,

	SETTINGS = PANEL_SETTINGS,

	BUTTONS = {
		Z = 0x0010,
		R = 0x0020,
		L = 0x0040,
		A = 0x0100,
		B = 0x0200,
		X = 0x0400,
		Y = 0x0800,
		START = 0x1000,
	},

	DPAD = {
		DPAD_LEFT = 0x0001,
		DPAD_RIGHT = 0x0002,
		DPAD_DOWN = 0x0004,
		DPAD_UP = 0x0008,
	},

	overlay = overlay,
}

return env