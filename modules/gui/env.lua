-- This is the environment used when loading our custon Panel classes
-- We don't really care if we're using unsafe functions to escape from the environment

local env = {
	arg = arg,

	print = print,

	module = module,
	require = require,
	dofile = dofile,
	load = load,
	loadile = loadfile,
	loadstring = loadstring,

	setfenv = setfenv,
	getfenv = setfenv,
	getmetatable = getmetatable,
	setmetatable = setmetatable,

	gcinfo = gcinfo,

	rawequal = rawequal,
	rawget = rawget,
	rawset = rawset,
	rawlen = rawlen,

	newproxy = newproxy,
	assert = assert,
	collectgarbage = collectgarbage,
	error = error,
	ipairs = ipairs,
	next = next,
	pairs = pairs,
	pcall = pcall,
	select = select,
	tonumber = tonumber,
	tostring = tostring,
	type = type,
	unpack = unpack,
	_VERSION = _VERSION,
	xpcall = xpcall,

	coroutine = coroutine,
	package = package,
	bit = bit,
	debug = debug,
	math = math,
	string = string,
	table = table,
	io = io,
	jit = jit,
	os = os,
	love = love,

	unpackcolor = unpackcolor,
	color = color,

	color_blank = color_blank,
	color_white = color_white,
	color_black = color_black,
	color_red = color_red,
	color_green = color_green,
	color_blue = color_blue,
	color_entity = color_entity,
	color_pink = color_pink,
	color_hotpink = color_hotpink,
	color_orange = color_orange,

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

	DOCK_NONE = DOCK_NONE,
	DOCK_TOP = DOCK_TOP,
	DOCK_LEFT = DOCK_LEFT,
	DOCK_BOTTOM = DOCK_BOTTOM,
	DOCK_RIGHT = DOCK_RIGHT,
	DOCK_FILL = DOCK_FILL,
}
env._G = env

return env