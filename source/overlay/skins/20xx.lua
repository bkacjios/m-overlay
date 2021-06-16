local SKIN = {}

local grey = color(100, 100, 100, 225)

local function draw20XXShadow(x, y, w, h, c)
	graphics.setColor(c.r/4, c.g/4, c.b/4, 75)
	graphics.rectangle("fill", x, y, w, 8)
	graphics.rectangle("fill", x, y + 8, 12, h - 8)
end

local function draw20XXBox(x, y, w, h, c)
	graphics.setColor(c.r, c.g, c.b, c.a)
	graphics.rectangle("fill", x, y, w, h)

	draw20XXShadow(x, y, w, h, c)
end

local function draw20XXButton(x, y, w, h, c, controller, flag)
	draw20XXBox(x, y, w, h, c)
	if bit.band(controller.buttons.pressed, flag) == flag then
		graphics.setColor(255, 255, 255, 255)
		graphics.rectangle("fill", x, y, w, h)
	end
end

local function draw20XXAnalog(x, y, w, h, c, controller, value, flag, flipped)
	graphics.setColor(c.r, c.g, c.b, c.a)
	graphics.rectangle("fill", x, y, w, h)

	if bit.band(controller.buttons.pressed, flag) == flag then
		graphics.setColor(255, 255, 255, 255)
		graphics.rectangle("fill", x, y, w, h)
	else
		graphics.setColor(200, 200, 200, 255)
		if flipped then
			graphics.rectangle("fill", w + x, y, w*-value, h)
		else
			graphics.rectangle("fill", x, y, w*value, h)
		end
		draw20XXShadow(x, y, w, h, c)
	end
end

local white = color(255, 255, 255, 225)
local red = color(200, 0, 0, 225)
local green = color(0, 200, 0, 225)
local purple = color(125, 0, 125, 225)
local dyellow = color(125, 125, 0, 225)
local yellow = color(255, 255, 0, 225)

local root2 = math.sqrt(2)

function SKIN:Paint(controller)
	draw20XXBox(56, 56, 96, 96, grey) -- Joystick

	local x, y = memory.game.translateAxis(controller.joystick.x, controller.joystick.y)

	-- Map circular coordiantes onto a square
	-- https://stackoverflow.com/a/32391780

	local sx = 0.5 * math.sqrt(2 + x*x - y*y + 2*x*root2) - 0.5 * math.sqrt(2 + x*x - y*y - 2*x*root2)
	local sy = 0.5 * math.sqrt(2 - x*x + y*y + 2*y*root2) - 0.5 * math.sqrt(2 - x*x + y*y - 2*y*root2)

	draw20XXBox((56 + 48 - 8) + 40 * sx, (56 + 48 - 8) + 40 * (-sy), 16, 16, white)

	draw20XXButton(256, 56+32, 64, 64, green, controller, BUTTONS.A) -- A
	draw20XXButton(256-40, 56+64+16, 32, 32, red, controller, BUTTONS.B) -- B

	if SETTINGS:IsStartEnabled() then
		draw20XXButton(256-64, 56+32, 24, 24, grey, controller, BUTTONS.START) -- Start
	end

	draw20XXButton(256, 56, 64, 24, grey, controller, BUTTONS.Y) -- Y
	draw20XXButton(256 + 64 + 8, 56, 24, 24, purple, controller, BUTTONS.Z) -- Z
	draw20XXButton(256 + 64 + 8, 56 + 32, 24, 64, grey, controller, BUTTONS.X) -- X

	draw20XXBox(256 + 64 + 40, 56, 96, 96, dyellow) -- C-Stick

	if SETTINGS:IsDPadEnabled() then
		draw20XXButton(128, 168, 24, 24, grey, controller, DPAD.UP)
		draw20XXButton(128 - 28, 168 + 28, 24, 24, grey, controller, DPAD.LEFT)
		draw20XXButton(128 + 28, 168 + 28, 24, 24, grey, controller, DPAD.RIGHT)
		draw20XXButton(128, 168 + 56, 24, 24, grey, controller, DPAD.DOWN)
	end

	local x, y = memory.game.translateAxis(controller.cstick.x, controller.cstick.y)

	local sx = 0.5 * math.sqrt(2 + x*x - y*y + 2*x*root2) - 0.5 * math.sqrt(2 + x*x - y*y - 2*x*root2)
	local sy = 0.5 * math.sqrt(2 - x*x + y*y + 2*y*root2) - 0.5 * math.sqrt(2 - x*x + y*y - 2*y*root2)

	draw20XXBox((256 + 64 + 80) + 40 * sx, (56 + 48 - 8) + 40 * (-sy), 16, 16, yellow)

	local al, ar = 0, 0

	if SETTINGS:IsSlippiReplay() and melee.isInGame() then
		local analog = controller.analog and controller.analog.float or 0
		al = analog
		ar = analog
	else
		al, ar = memory.game.translateTriggers(controller.analog.l, controller.analog.r)
	end

	draw20XXAnalog(56 + 12, 24, 84, 24, grey, controller, al, BUTTONS.L) -- L
	draw20XXAnalog(256, 24, 84, 24, grey, controller, ar, BUTTONS.R, true) -- R
end

overlay.registerSkin("20xx", SKIN)