love.filesystem.setRequirePath("?.lua;?/init.lua;modules/?.lua;modules/?/init.lua")

math.randomseed(love.timer.getTime())

-- Read version file and strip any trailing whitespace
local VERSION = love.filesystem.read("version.txt"):match("^(%S+)")

function love.getMOverlayVersion()
	return VERSION or "0.0.0"
end

require("console")
require("errorhandler")
require("extensions.love")

local log = require("log")
local melee = require("melee")
local zce = require("zce")
local memory = require("memory")
local perspective = require("perspective")
local notification = require("notification")

local music = require("music")

local color = require("util.color")
local gui = require("gui")

local ease = require("ease")

local graphics = love.graphics
local newImage = graphics.newImage

local PORT_FONT = graphics.newFont("fonts/melee-bold.otf", 42)
local WAITING_FONT = graphics.newFont("fonts/melee-bold.otf", 24)
local DEBUG_FONT = graphics.newFont("fonts/melee-bold.otf", 12)

local GRADIENT = newImage("textures/gradient.png")
local DOLPHIN = newImage("textures/dolphin.png")
local GAME = newImage("textures/game.png")
local MELEE = newImage("textures/meleedisk.png")
local MELEELABEL = newImage("textures/meleedisklabel.png")
local SHADOW = newImage("textures/shadow.png")

--PANEL_SETTINGS

local MAX_PORTS = 4
local PORT_DISPLAY_OVERRIDE = nil
local CONTROLLER_PORT_DISPLAY = 0

function love.getPort()
	return PANEL_PORT_SELECT:GetPort()
end

function love.setPort(port)
	PANEL_PORT_SELECT:ChangePort(((port-1) % MAX_PORTS) + 1)
end

function love.getSkin()
	return PANEL_SKIN_SELECT:GetSkin()
end

function love.setSkin(skin)
	return PANEL_SKIN_SELECT:ChangeSkin(skin)
end

local PORT_TEXTURES = {
	[1] = newImage("textures/player1_color.png"),
	[2] = newImage("textures/player2_color.png"),
	[3] = newImage("textures/player3_color.png"),
	[4] = newImage("textures/player4_color.png")
}

local BUTTONS = {
	Z = 0x0010,
	R = 0x0020,
	L = 0x0040,
	A = 0x0100,
	B = 0x0200,
	X = 0x0400,
	Y = 0x0800,
	START = 0x1000,
}

local DPAD = {
	DPAD_LEFT = 0x0001,
	DPAD_RIGHT = 0x0002,
	DPAD_DOWN = 0x0004,
	DPAD_UP = 0x0008,
}

local portless_title = ""
function love.updateTitle(str)
	local title = str
	portless_title = str
	if PANEL_SETTINGS:IsPortTitleEnabled() then
		title = string.format("%s (Port %d)", str, love.getPort())
	end
	love.window.setTitle(title)
end

function love.getTitleNoPort()
	return portless_title
end

function love.load(args, unfilteredArg)
	melee.loadtextures()
	gui.init()
	love.keyboard.setKeyRepeat(true)

	PANEL_PORT_SELECT = gui.create("PortSelect")
	PANEL_PORT_SELECT:SetVisible(false)

	PANEL_SKIN_SELECT = gui.create("SkinSelect")
	PANEL_SKIN_SELECT:SetVisible(false)

	PANEL_SETTINGS = gui.create("Settings")
	PANEL_SETTINGS:LoadSettings()
	PANEL_SETTINGS:SetVisible(false)
	
	music.init()

	if memory.hasPermissions() then
		love.updateTitle("M'Overlay - Waiting for Dolphin...")
	else
		love.updateTitle("M'Overlay - Invalid permissions...")
		--notification.error()
	end

	-- Loop through all the commandline arguments
	for n, arg in pairs(args) do
		 -- Check for '--port=N' first..
		local portn = tonumber(string.match(arg, "%-%-port=(%d+)"))

		if arg == "--port" then -- Alternative '--port N'
			portn = tonumber(args[n+1]) -- Convert the next argument in the commandline to a number
		end

		if portn then -- A port number was specified..
			love.setPort(portn)
			CONTROLLER_PORT_DISPLAY = love.timer.getTime() + 3 -- Show the port display number for 3 seconds
			break -- Done
		end
	end
end

memory.hook("menu.player_one_port", "Controller port that is acting as player 1", function(port)
	if melee.isSinglePlayerGame() or (memory.menu.major == MENU_VS_UNKNOWN and PANEL_SETTINGS:IsSlippiNetplay()) then
		love.setPort(port+1)
		log.debug("[AUTOPORT] Player \"one\" port changed %d", love.getPort())
	end
end)

memory.hook("menu.major", "Slippi Auto Port Switcher", function(major)
	if melee.isSinglePlayerGame() or (major == MENU_VS_UNKNOWN and PANEL_SETTINGS:IsSlippiNetplay()) then
		-- Switch back to whatever controller is controlling port 1, when not in a match
		love.setPort(memory.menu.player_one_port+1)
		log.debug("[AUTOPORT] Forcing port %d in menus", love.getPort())
	end
end)

memory.hook("menu.minor", "Slippi Auto Port Switcher", function(minor)
	-- MENU_VS_UNKNOWN = Slippi online
	if memory.menu.major == MENU_VS_UNKNOWN and PANEL_SETTINGS:IsSlippiNetplay() then
		if minor == MENU_VS_UNKNOWN_CSS or menu == MENU_VS_UNKNOWN_SSS then
			-- Switch back to whatever controller is controlling port 1, when not in a match
			love.setPort(memory.menu.player_one_port+1)
			log.debug("[AUTOPORT] Forcing port %d in menus", love.getPort())
			if minor == MENU_VS_UNKNOWN_CSS then
				-- Display the port info only when swiching back to CSS
				CONTROLLER_PORT_DISPLAY = love.timer.getTime() + 1.5 -- Show the port display number for 1.5 seconds
			end
		elseif minor == MENU_VS_UNKNOWN_VERSUS then
			PORT_DISPLAY_OVERRIDE = (memory.slippi.local_player.index % MAX_PORTS) + 1
			CONTROLLER_PORT_DISPLAY = love.timer.getTime() + 3 -- Show the port display number for 3 seconds
			log.debug("[AUTOPORT] Switching display icon to use port %d", love.getPort())
		elseif minor == MENU_VS_UNKNOWN_INGAME then
			-- Switch to the local player index whenever else
			PORT_DISPLAY_OVERRIDE = nil
			love.setPort(memory.slippi.local_player.index+1)
			log.debug("[AUTOPORT] Switching to slippi local player index %d", love.getPort())
		end
	end
end)

memory.hook("player.*.character", "Show port on character select", function(port, character)
	if memory.menu.minor == MENU_VS_CSS and port == love.getPort() then
		CONTROLLER_PORT_DISPLAY = love.timer.getTime() + 1.5 -- Show the port display number for 1.5 seconds
	end
end)

function love.update(dt)
	music.update()
	memory.update() -- Look for Dolphin.exe
	notification.update(8, 0)
	gui.update(dt)
end

function love.resize(w, h)
	gui.resize(w, h)
end

function love.joystickpressed(joy, but)
	gui.joyPressed(joy, but)
end

function love.joystickreleased(joy, but)
	gui.joyReleased(joy, but)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" and not isrepeat then
		PANEL_SETTINGS:Toggle()
		PANEL_PORT_SELECT:Toggle()
		PANEL_SKIN_SELECT:Toggle()
	end

	gui.keyPressed(key, scancode, isrepeat)

	local num = tonumber(string.match(key, "kp(%d)") or key)

	if not PANEL_SETTINGS:IsVisible() and num and num >= 1 and num <= 4 then
		love.setPort(num)
		PORT_DISPLAY_OVERRIDE = nil
		CONTROLLER_PORT_DISPLAY = love.timer.getTime() + 1.5
	end
end

function love.keyreleased(key)
	gui.keyReleased(key)
end

function love.textinput(text)
	gui.textInput(text)
end

function love.mousemoved(x, y, dx, dy, istouch)
	gui.mouseMoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
	gui.mousePressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	gui.mouseReleased(x, y, button, istouch, presses)
end

function love.wheelmoved(x, y)
	if PANEL_SETTINGS:IsVisible() then
		gui.mouseWheeled(x, y)
		return
	end

	local port = love.getPort()
	
	if y > 0 then
		port = port - 1
	elseif y < 0 then
		port = port + 1
	end
	love.setPort(port)
	PORT_DISPLAY_OVERRIDE = nil
	CONTROLLER_PORT_DISPLAY = love.timer.getTime() + 1.5
end

local DC_CON = newImage("textures/buttons/disconnected.png")

local ANALOG = newImage("textures/buttons/analog-outline.png")
local ANALOG_FILLED = newImage("textures/buttons/analog-filled.png")

local BUTTON_TEXTURES = {
	DPAD = {
		GATE = newImage("textures/buttons/d-pad-gate.png"),
		GATE_FILLED = newImage("textures/buttons/d-pad-gate-filled.png"),
		POSITION = {
			x = 100,
			y = 128,
		},
	},

	DPAD_LEFT = {
		PRESSED = newImage("textures/buttons/d-pad-pressed-left.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	DPAD_RIGHT = {
		PRESSED = newImage("textures/buttons/d-pad-pressed-right.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	DPAD_UP = {
		PRESSED = newImage("textures/buttons/d-pad-pressed-up.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	DPAD_DOWN = {
		PRESSED = newImage("textures/buttons/d-pad-pressed-down.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	JOYSTICK = {
		GATE = newImage("textures/buttons/joystick-gate.png"),
		GATE_FILLED = newImage("textures/buttons/joystick-gate-filled.png"),
		MASK = newImage("textures/buttons/joystick-mask.png"),
		STICK = newImage("textures/buttons/joystick.png"),
		FILLED = newImage("textures/buttons/joystick-filled.png"),
	},
	CSTICK = {
		GATE = newImage("textures/buttons/c-stick-gate.png"),
		GATE_FILLED = newImage("textures/buttons/c-stick-gate-filled.png"),
		MASK = newImage("textures/buttons/c-stick-mask.png"),
		STICK = newImage("textures/buttons/c-stick.png"),
		FILLED = newImage("textures/buttons/c-stick-filled.png"),
	},
	A = {
		OUTLINE = newImage("textures/buttons/a-outline.png"),
		FILLED = newImage("textures/buttons/a-filled.png"),
		PRESSED = newImage("textures/buttons/a-pressed.png"),
		COLOR = color(0, 225, 150, 255),
		POSITION = {
			x = 12 + 64 + 256,
			y = 48
		}
	},
	B = {
		OUTLINE = newImage("textures/buttons/b-outline.png"),
		FILLED = newImage("textures/buttons/b-filled.png"),
		PRESSED = newImage("textures/buttons/b-pressed.png"),
		COLOR = color(230, 0, 0, 255),
		POSITION = {
			x = 16 + 256,
			y = 92
		}
	},
	X = {
		OUTLINE = newImage("textures/buttons/x-outline.png"),
		FILLED = newImage("textures/buttons/x-filled.png"),
		PRESSED = newImage("textures/buttons/x-pressed.png"),
		COLOR = color(255, 255, 255, 255),
		POSITION = {
			x = 138 + 256,
			y = 32
		}
	},
	Y = {
		OUTLINE = newImage("textures/buttons/y-outline.png"),
		FILLED = newImage("textures/buttons/y-filled.png"),
		PRESSED = newImage("textures/buttons/y-pressed.png"),
		COLOR = color(255, 255, 255, 255),
		POSITION = {
			x = 60 + 256,
			y = -16
		}
	},
	Z = {
		OUTLINE = newImage("textures/buttons/z-outline.png"),
		FILLED = newImage("textures/buttons/z-filled.png"),
		PRESSED = newImage("textures/buttons/z-pressed.png"),
		COLOR = color(165, 75, 165, 255),
		POSITION = {
			x = 128 + 256,
			y = -32
		}
	},
	START = {
		OUTLINE = newImage("textures/buttons/start-outline.png"),
		FILLED = newImage("textures/buttons/start-filled.png"),
		PRESSED = newImage("textures/buttons/start-pressed.png"),
		COLOR = color(255, 255, 255, 255),
		POSITION = {
			x = 256,
			y = 26
		}
	}
}

local vertices = {
	{
		0, 0,
		0, 0,
		1, 1, 1,
	},
	{
		128, 0,
		1, 0,
		1, 1, 1
	},
	{
		128, 128,
		1, 1,
		1, 1, 1
	},
	{
		0, 128,
		0, 1,
		1, 1, 1
	},
}

local rotated_vertices = {}

local function transformVertices(vertices, x, y, angle, ox, oy)
	if #vertices ~= #rotated_vertices then
		rotated_vertices = {}
	end

	local c = math.cos(angle)
	local s = math.sin(angle)

	for i=1, #vertices do
		-- Create or use vertex cache
		rotated_vertices[i] = rotated_vertices[i] or {}

		-- Copy and rotate X and Y vertex points
		rotated_vertices[i][1] = x + (vertices[i][1] - ox) * c - (vertices[i][2] - oy) * s
		rotated_vertices[i][2] = y + (vertices[i][1] - ox) * s + (vertices[i][2] - oy) * c

		-- Copy other vertex settings
		rotated_vertices[i][3] = vertices[i][3]
		rotated_vertices[i][4] = vertices[i][4]
		rotated_vertices[i][5] = vertices[i][5]
		rotated_vertices[i][6] = vertices[i][6]
	end

	return rotated_vertices
end

local function drawButtons(buttons, controller)
	for button, flag in pairs(buttons) do
		local texture = BUTTON_TEXTURES[button]
		if texture then
			if button ~= "START" or (button == "START" and PANEL_SETTINGS:IsStartEnabled()) then
				local pos = texture.POSITION
				graphics.setColor(texture.COLOR)
				if texture.PRESSED and bit.band(controller.buttons.pressed, flag) == flag then -- Check if the button is pressed
					graphics.easyDraw(texture.PRESSED, pos.x, pos.y, 0, 128, 128)
				else
					local text = PANEL_SETTINGS:IsHighContrast() and texture.FILLED or texture.OUTLINE
					if text then
						graphics.easyDraw(text, pos.x, pos.y, 0, 128, 128)
					end
				end
			end
		end
	end
end

function love.drawDefaultDisplay(controller)
	-- Draw Joystick

	local x, y = memory.game.translateAxis(controller.joystick.x, controller.joystick.y)

	--[[if PANEL_SETTINGS:IsDebugging() then
		local strx = ("JOY_X: % f"):format(x)
		local stry = ("JOY_Y: % f"):format(y)
		local btts = ("BUTTONS: %X"):format(controller.buttons.pressed)
		graphics.setFont(DEBUG_FONT)

		graphics.setColor(0, 0, 0, 255)
		graphics.textOutline(btts, 2, 96, 256 - 4 - 36)
		graphics.textOutline(strx, 2, 96, 256 - 4 - 24)
		graphics.textOutline(stry, 2, 96, 256 - 4 - 12)

		graphics.setColor(255, 255, 255, 255)
		graphics.print(btts, 96, 256 - 8 - 36 )
		graphics.print(strx, 96, 256 - 4 - 24)
		graphics.print(stry, 96, 256 - 4 - 12)
	end]]

	local vx, vy = x, 1 - y

	local angle = math.atan2(x, y)
	local mag = math.sqrt(x*x + y*y)

	local far = mag * 12
	local near = mag * 20

	-- Make the rectangle look like its fading into the horizon

	-- Top left
	vertices[1][1] = far
	-- Top right
	vertices[2][1] = 128 - far

	-- Bottom left
	vertices[1][2] = near
	-- Bottom right
	vertices[2][2] = near

	local rotated = transformVertices(vertices, 64 + 22 + (40 * vx), 64 + 12 + (40 * vy), angle, 64, 64)

	graphics.setColor(255, 255, 255, 255)

	if PANEL_SETTINGS:IsHighContrast() then
		graphics.easyDraw(BUTTON_TEXTURES.JOYSTICK.GATE_FILLED, 22, 52, 0, 128, 128)
	else
		graphics.stencil(function()
			perspective.on()
			perspective.quad(BUTTON_TEXTURES.JOYSTICK.MASK, rotated[1], rotated[2], rotated[3], rotated[4])
			perspective.off()
		end, "replace", 1)
		graphics.setStencilTest("equal", 0) -- Mask out the gate behind the joystick
			graphics.easyDraw(BUTTON_TEXTURES.JOYSTICK.GATE, 22, 52, 0, 128, 128)
		graphics.setStencilTest()
	end

	perspective.on()
	perspective.quad(PANEL_SETTINGS:IsHighContrast() and BUTTON_TEXTURES.JOYSTICK.FILLED or BUTTON_TEXTURES.JOYSTICK.STICK, rotated[1], rotated[2], rotated[3], rotated[4])
	perspective.off()

	-- Draw C-Stick

	local x, y = memory.game.translateAxis(controller.cstick.x, controller.cstick.y)

	--[[if PANEL_SETTINGS:IsDebugging() then
		local strx = ("C_X: % f"):format(x)
		local stry = ("C_Y: % f"):format(y)
		graphics.setFont(DEBUG_FONT)

		graphics.setColor(0, 0, 0, 255)
		graphics.textOutline(strx, 2, 224, 256 - 4 - 24)
		graphics.textOutline(stry, 2, 224, 256 - 4 - 12)

		graphics.setColor(255, 255, 255, 255)
		graphics.print(strx, 224, 256 - 4 - 24)
		graphics.print(stry, 224, 256 - 4 - 12)
	end]]

	local vx, vy = x, 1 - y

	local angle = math.atan2(x, y)
	local mag = math.sqrt(x*x + y*y)

	local far = mag * 12
	local near = mag * 20

	-- Make the rectangle look like its fading into the horizon

	-- Top left
	vertices[1][1] = far
	-- Top right
	vertices[2][1] = 128 - far

	-- Bottom left
	vertices[1][2] = near
	-- Bottom right
	vertices[2][2] = near

	local rotated = transformVertices(vertices, 64 + 48 + 128 + (32 * vx), 64 + 18 + (32 * vy), angle, 64, 64)

	graphics.setColor(255, 235, 0, 255)

	if PANEL_SETTINGS:IsHighContrast() then
		graphics.easyDraw(BUTTON_TEXTURES.CSTICK.GATE_FILLED, 48 + 128, 52, 0, 128, 128)
	else
		graphics.stencil(function()
			perspective.on()
			perspective.quad(BUTTON_TEXTURES.CSTICK.MASK, rotated[1], rotated[2], rotated[3], rotated[4])
			perspective.off()
		end, "replace", 1)
		graphics.setStencilTest("equal", 0) -- Mask out the gate behind the joystick
			graphics.easyDraw(BUTTON_TEXTURES.CSTICK.GATE, 48 + 128, 52, 0, 128, 128)
		graphics.setStencilTest()
	end

	perspective.on()
	perspective.quad(PANEL_SETTINGS:IsHighContrast() and BUTTON_TEXTURES.CSTICK.FILLED or BUTTON_TEXTURES.CSTICK.STICK, rotated[1], rotated[2], rotated[3], rotated[4])
	perspective.off()

	graphics.setColor(255, 255, 255, 255)

	-- Draw L

	if PANEL_SETTINGS:IsSlippiReplay() then
		graphics.setLineStyle("smooth")
		love.graphics.setLineWidth(4)

		-- Draw outline
		graphics.easyDraw(PANEL_SETTINGS:IsHighContrast() and ANALOG_FILLED or ANALOG, 108 + 6, 14, 0, 116, 24)

		-- Draw L segment for button press
		graphics.line(108 + 14 + 88, 20, 108 + 14 + 88, 20 + 12)

		-- Draw R segment for button press
		graphics.line(108 + 14 + 12, 20, 108 + 14 + 12, 20 + 12)

		graphics.stencil(function()
			-- Create a rounded rectangle mask
			graphics.rectangle("fill", 108 + 14, 20, 100, 12, 6, 6)
		end, "replace", 1)
		graphics.setStencilTest("greater", 0) -- Only draw within our rounded rectangle mask
			-- Analog

			local analog = controller.analog and controller.analog.float or 0

			if not melee.isInGame() then
				local al, ar = memory.game.translateTriggers(controller.analog.l, controller.analog.r)

				analog = math.max(al, ar)
			end

	 		-- L Button
			if bit.band(controller.buttons.pressed, BUTTONS.L) == BUTTONS.L then
				graphics.rectangle("fill", 108 + 14, 20, 12, 12)
				analog = 1
			end

			-- R Button
			if bit.band(controller.buttons.pressed, BUTTONS.R) == BUTTONS.R then
				graphics.rectangle("fill", 108 + 14 + 12 + 76, 20, 12, 12)
				analog = 1
			end

			local w = 76 * analog
			graphics.rectangle("fill", 108 + 14 + 12 + 76/2 - (w/2), 20, w, 12)
		graphics.setStencilTest()
	else
		local al, ar = memory.game.translateTriggers(controller.analog.l, controller.analog.r)

		graphics.setLineStyle("smooth")
		love.graphics.setLineWidth(4)

		-- Draw L

		-- Draw outline
		graphics.easyDraw(PANEL_SETTINGS:IsHighContrast() and ANALOG_FILLED or ANALOG, 24 + 6, 14, 0, 116, 24)
		-- Draw segment for button press
		graphics.line(24 + 14 + 88, 20, 24 + 14 + 88, 20 + 12)

		graphics.stencil(function()
			-- Create a rounded rectangle mask
			graphics.rectangle("fill", 24 + 14, 20, 100, 12, 6, 6)
		end, "replace", 1)
		graphics.setStencilTest("greater", 0) -- Only draw within our rounded rectangle mask
	 		-- L Button
			if bit.band(controller.buttons.pressed, BUTTONS.L) == BUTTONS.L then
				graphics.rectangle("fill", 24 + 14 + 88, 20, 12, 12)
				al = 1
			end

			-- L Analog
			graphics.rectangle("fill", 24 + 14, 20, 88 * al, 12)
		graphics.setStencilTest()

		-- Draw R

		-- Draw outline
		graphics.easyDraw(PANEL_SETTINGS:IsHighContrast() and ANALOG_FILLED or ANALOG, 48 + 128 + 6, 14, 0, 116, 24)
		-- Draw segment for button press
		graphics.line(48 + 128 + 14 + 12, 20, 48 + 128 + 14 + 12, 20 + 12)

		graphics.stencil(function()
			-- Create a rounded rectangle mask
			graphics.rectangle("fill", 48 + 128 + 14, 20, 100, 12, 6, 6)
		end, "replace", 1)
		graphics.setStencilTest("greater", 0) -- Only draw within our rounded rectangle mask
			-- R Button
			if bit.band(controller.buttons.pressed, BUTTONS.R) == BUTTONS.R then
				graphics.rectangle("fill", 48 + 128 + 14, 20, 12, 12)
				ar = 1
			end

			-- R Analog
			graphics.rectangle("fill", 48 + 128 + 14 + 12 + (88 * (1 - ar)), 20, 88 * ar, 12)
		graphics.setStencilTest()
		
		--[[if PANEL_SETTINGS:IsDebugging() then
			local strl = ("L: %f"):format(al)
			local strr = ("R: %f"):format(ar)
			graphics.setFont(DEBUG_FONT)

			graphics.setColor(0, 0, 0, 255)
			graphics.textOutline(strl, 2, 340, 256 - 4 - 24)
			graphics.textOutline(strr, 2, 340, 256 - 4 - 12)

			graphics.setColor(255, 255, 255, 255)
			graphics.print(strl, 340, 256 - 4 - 24)
			graphics.print(strr, 340, 256 - 4 - 12)
		end]]
	end

	-- Draw buttons

	if PANEL_SETTINGS:IsDPadEnabled() then
		graphics.easyDraw(PANEL_SETTINGS:IsHighContrast() and BUTTON_TEXTURES.DPAD.GATE_FILLED or BUTTON_TEXTURES.DPAD.GATE, 108, 144, 0, 128, 128)
		drawButtons(DPAD, controller)
	end

	drawButtons(BUTTONS, controller)
end

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

function love.draw20XXDisplay(controller)
	draw20XXBox(56, 56, 96, 96, grey) -- Joystick

	local x, y = memory.game.translateAxis(controller.joystick.x, controller.joystick.y)

	-- Map circular coordiantes onto a square
	-- https://stackoverflow.com/a/32391780

	local sx = 0.5 * math.sqrt(2 + x*x - y*y + 2*x*root2) - 0.5 * math.sqrt(2 + x*x - y*y - 2*x*root2)
	local sy = 0.5 * math.sqrt(2 - x*x + y*y + 2*y*root2) - 0.5 * math.sqrt(2 - x*x + y*y - 2*y*root2)

	draw20XXBox((56 + 48 - 8) + 40 * sx, (56 + 48 - 8) + 40 * (-sy), 16, 16, white)

	draw20XXButton(256, 56+32, 64, 64, green, controller, BUTTONS.A) -- A
	draw20XXButton(256-40, 56+64+16, 32, 32, red, controller, BUTTONS.B) -- B

	if PANEL_SETTINGS:IsStartEnabled() then
		draw20XXButton(256-64, 56+32, 24, 24, grey, controller, BUTTONS.START) -- Start
	end

	draw20XXButton(256, 56, 64, 24, grey, controller, BUTTONS.Y) -- Y
	draw20XXButton(256 + 64 + 8, 56, 24, 24, purple, controller, BUTTONS.Z) -- Z
	draw20XXButton(256 + 64 + 8, 56 + 32, 24, 64, grey, controller, BUTTONS.X) -- X

	draw20XXBox(256 + 64 + 40, 56, 96, 96, dyellow) -- C-Stick

	if PANEL_SETTINGS:IsDPadEnabled() then
		draw20XXButton(128, 168, 24, 24, grey, controller, DPAD.DPAD_UP)
		draw20XXButton(128 - 28, 168 + 28, 24, 24, grey, controller, DPAD.DPAD_LEFT)
		draw20XXButton(128 + 28, 168 + 28, 24, 24, grey, controller, DPAD.DPAD_RIGHT)
		draw20XXButton(128, 168 + 56, 24, 24, grey, controller, DPAD.DPAD_DOWN)
	end

	local x, y = memory.game.translateAxis(controller.cstick.x, controller.cstick.y)

	local sx = 0.5 * math.sqrt(2 + x*x - y*y + 2*x*root2) - 0.5 * math.sqrt(2 + x*x - y*y - 2*x*root2)
	local sy = 0.5 * math.sqrt(2 - x*x + y*y + 2*y*root2) - 0.5 * math.sqrt(2 - x*x + y*y - 2*y*root2)

	draw20XXBox((256 + 64 + 80) + 40 * sx, (56 + 48 - 8) + 40 * (-sy), 16, 16, yellow)

	local al, ar = 0, 0

	if PANEL_SETTINGS:IsSlippiReplay() and melee.isInGame() then
		local analog = controller.analog and controller.analog.float or 0
		al = analog
		ar = analog
	else
		al, ar = memory.game.translateTriggers(controller.analog.l, controller.analog.r)
	end

	draw20XXAnalog(56 + 12, 24, 84, 24, grey, controller, al, BUTTONS.L) -- L
	draw20XXAnalog(256, 24, 84, 24, grey, controller, ar, BUTTONS.R, true) -- R
end

function love.drawControllerOverlay()
	local controller
	local port = love.getPort()

	-- Check if ZCE (dynamic controller address swapping)
	if zce.isZce() then
		if zce.isOot() then
			controller = memory.controller.oot[port]
		elseif zce.isMajora() then
			controller = memory.controller.mm[port]
		elseif zce.isZ1() then
			controller = memory.controller.z1[port]
		elseif zce.isZ2() then
			controller = memory.controller.z2[port]
		else
			controller = memory.controller.menu[port]
		end
	else
		controller = memory.controller[port]
	end

	if PANEL_SETTINGS:IsSlippiReplay() and melee.isInGame() then
		local player = memory.player[port]

		if not player then return end

		local entity

		if player.transformed == 256 then
			-- If the player has the "transformed" flag set, assume they are now controlling the "partner" entity
			entity = player.partner
		else
			entity = player.entity
		end
		
		controller = entity.controller
	end

	if controller then
		if controller.plugged and controller.plugged ~= (memory.game.pluggedValue or 0x00) then
			local sin = 128 + math.sin(love.timer.getTime()*2) * 128
			graphics.setColor(255, 0, 0, sin)
			graphics.easyDraw(DC_CON, 512-42-16, 256-42-16, 0, 42, 42)
		end

		if love.getSkin() == 1 then
			love.drawDefaultDisplay(controller)
		else
			love.draw20XXDisplay(controller)
		end
	end
end

do
	local icon_time_start
	local icon_time_show
	local icon_time_next

	local icon_rotate = 0

	local canvas = love.graphics.newCanvas()

	function love.drawTrobber(game)
		local t = love.timer.getTime()
		local dt = love.timer.getDelta()

		local lx = 0
		local ly = math.sin(t*3) * 4
		local rx = icon_rotate

		local rotate_speed = 0
		
		if not game then
			if not icon_time_start or icon_time_next < t then
				icon_time_start = t
				icon_time_show = t + 1
				icon_time_next = t + 2
			end

			local anim = 0
			if icon_time_show > t then
				anim = ease.sigmoid(math.min(1, (t - icon_time_start)/1))
				lx = ease.lerp(0, -160, anim)
				ly = ease.lerp(0, 64, anim)
				rx = ease.lerp(0, -90, anim)
			else
				anim = ease.outback(math.min(1, (t - icon_time_show)/1))
				lx = ease.lerp(160, 0, anim)
				ly = ease.lerp(64, 0, anim)
				rx = ease.lerp(90, 0, anim)
			end
		else
			rotate_speed = math.sinlerp(0, 360*4*dt/2, t/2)
			icon_rotate = (icon_rotate + rotate_speed) % 360
		end

		graphics.setColor(255, 255, 255, 255)

		graphics.setCanvas(canvas)

		graphics.clear(0,0,0,0)
		if not game then
			graphics.setBlendMode("replace", "premultiplied")
		end

		graphics.setScissor(256-80-20, 0, 160+40, 256)

		local slippi = PANEL_SETTINGS:IsSlippiNetplay() or PANEL_SETTINGS:IsSlippiReplay()
		local icon = game and (slippi and MELEE or GAME) or DOLPHIN

		graphics.setColor(255, 255, 255, 255)
		graphics.easyDraw(icon, 256+lx, 64+40+ly, math.rad(rx), 80, 80, 0.5, 0.5)
		
		if game then
			local p = rotate_speed/13

			for i=0, 16 do
				local j = rotate_speed - i
				graphics.setColor(255, 255, 255, rotate_speed*4)
				graphics.easyDraw(slippi and MELEELABEL or icon, 256+lx, 64+40+ly, math.rad(rx-(i*p*4)), 80, 80, 0.5, 0.5)
			end
		end

		graphics.setScissor()

		if not game then
			graphics.setBlendMode("multiply", "premultiplied")

			graphics.easyDraw(GRADIENT, 256-80-20, 0, 0, 80, 256)
			graphics.easyDraw(GRADIENT, 256+80+20, 0, math.rad(180), 80, 256, 0, 1)
		end

		graphics.setCanvas()

		graphics.setBlendMode("alpha", "alphamultiply")

		if game then
			local sw = math.sinlerp(0.5, 1, t*3)
			graphics.setColor(125, 125, 125, 150)
			graphics.easyDraw(SHADOW, 256, 154, 0, 64*sw, 6*sw, 0.5, 0.5)
		end

		graphics.setColor(255, 255, 255, 255)
		graphics.draw(canvas)
	end
end

do
	local ellipses = {".", "..", "..."}

	function love.drawNotificationText(msg)
		local t = love.timer.getTime()

		local w = WAITING_FONT:getWidth(msg)
		local h = WAITING_FONT:getHeight()
		local x = 256 - (w/2)
		local y = 128+32

		local i = math.floor(t % #ellipses) + 1

		msg = msg .. ellipses[i]

		graphics.setFont(WAITING_FONT)
		graphics.setColor(0, 0, 0, 255)
		graphics.textOutline(msg, 3, x, y)
		graphics.setColor(255, 255, 255, 255)
		graphics.print(msg, x, y)
	end
end

function love.supportsGameCapture()
	return jit.os:lower() == "windows"
end

function love.draw()
	if not love.supportsGameCapture() then
		graphics.setBackgroundColor(100, 100, 100, 255)
	else
		-- Default to completely transparent, makes the overlay completely invisible when not in a game!
		local alpha = 0

		if (memory.initialized and memory.game) or PANEL_SETTINGS:IsVisible() then
			-- Only apply transparency when we are watching a games memory.
			alpha = 255 - ((PANEL_SETTINGS:GetTransparency() / 100) * 255)
		end

		-- Transparent background for OBS
		graphics.setBackgroundColor(0, 0, 0, alpha)

		-- Show a preview for transparency
		if PANEL_SETTINGS:IsVisible() then
			graphics.setBackgroundColor(255, 255, 255, alpha)

			for x=0, 512/32 do
				for y=0, 256/32 do
					graphics.setColor(240, 240, 240, 255)
					graphics.rectangle("fill", 32 * (x + (y%2)), 32 * (y + (x%2)), 32, 32)
				end
			end

			graphics.setColor(0, 0, 0, alpha)
			graphics.rectangle("fill", 0, 0, 512, 256)

			--[[graphics.setColor(0, 0, 0, 100)
			graphics.rectangle("fill", 512 - 20, 0, 20, 256)

			local rad = math.rad(90)

			graphics.setFont(DEBUG_FONT)
			graphics.setColor(0, 0, 0, 255)
			graphics.print(VERSION, 512 - 5, 5, rad)
			graphics.setColor(255, 255, 255, 255)
			graphics.print(VERSION, 512 - 4, 4, rad)]]
		end
	end

	if memory.initialized and memory.game and memory.controller then
		love.drawControllerOverlay()
	else
		if memory.hooked then
			love.drawTrobber(true)
			local slippi = PANEL_SETTINGS:IsSlippiNetplay() or PANEL_SETTINGS:IsSlippiReplay()
			love.drawNotificationText(slippi and "Waiting for melee" or "Waiting for game")
		else
			love.drawTrobber()
			love.drawNotificationText("Waiting for dolphin")
		end
	end

	-- Draw a temporary number to show that the user changed controller port
	if ((PANEL_SETTINGS:AlwaysShowPort() and memory.isInGame()) or CONTROLLER_PORT_DISPLAY >= love.timer.getTime()) then
		local port = love.getPort()
		if memory.isMelee() then
			local port = PORT_DISPLAY_OVERRIDE or port
			local portColor
			if melee.isTeams() then
				portColor = melee.getPlayerTeamColor(port)
			else
				portColor = melee.getPlayerColor(port)
			end
			portColor.a = 200
			graphics.setColor(portColor)
			melee.drawSeries(port, 8, 256 - 72 - 4, 0, 72, 72)
			graphics.setColor(255, 255, 255, 255)
			melee.drawStock(port, 40, 256 - 42, 0, 24, 24)
			graphics.easyDraw(PORT_TEXTURES[port], 12, 256 - 42 - 24, 0, 33, 14)
		else
			graphics.setFont(PORT_FONT)
			graphics.setColor(0, 0, 0, 255)
			graphics.textOutline(port, 3, 16, 256 - 42 - 16)
			graphics.setColor(255, 255, 255, 255)
			graphics.print(port, 16, 256 - 42 - 16)
		end
	end

	gui.render()
	notification.draw()
end

local FPS_LIMIT = 60

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	return function()
		local frame_start = love.timer.getTime()

		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end
 
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
 
			if love.draw then love.draw() end
 
			love.graphics.present()
		end
 
		if love.timer then
			local frame_time = love.timer.getTime() - frame_start
			love.timer.sleep(1 / FPS_LIMIT - frame_time)
		end
	end
end

function love.quit()
	PANEL_SETTINGS:SaveSettings()
	gui.shutdown()
end