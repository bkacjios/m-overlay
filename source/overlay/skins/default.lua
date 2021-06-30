local SKIN = {}

local ANALOG = graphics.newImage("textures/buttons/analog-outline.png")
local ANALOG_FILLED = graphics.newImage("textures/buttons/analog-filled.png")

local BUTTON_TEXTURES = {
	DPAD = {
		GATE = graphics.newImage("textures/buttons/d-pad-gate.png"),
		GATE_FILLED = graphics.newImage("textures/buttons/d-pad-gate-filled.png"),
		POSITION = {
			x = 100,
			y = 128,
		},
	},

	DPAD_LEFT = {
		PRESSED = graphics.newImage("textures/buttons/d-pad-pressed-left.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	DPAD_RIGHT = {
		PRESSED = graphics.newImage("textures/buttons/d-pad-pressed-right.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	DPAD_UP = {
		PRESSED = graphics.newImage("textures/buttons/d-pad-pressed-up.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	DPAD_DOWN = {
		PRESSED = graphics.newImage("textures/buttons/d-pad-pressed-down.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	JOYSTICK = {
		GATE = graphics.newImage("textures/buttons/joystick-gate.png"),
		GATE_FILLED = graphics.newImage("textures/buttons/joystick-gate-filled.png"),
		MASK = graphics.newImage("textures/buttons/joystick-mask.png"),
		STICK = graphics.newImage("textures/buttons/joystick.png"),
		FILLED = graphics.newImage("textures/buttons/joystick-filled.png"),
	},
	CSTICK = {
		GATE = graphics.newImage("textures/buttons/c-stick-gate.png"),
		GATE_FILLED = graphics.newImage("textures/buttons/c-stick-gate-filled.png"),
		MASK = graphics.newImage("textures/buttons/c-stick-mask.png"),
		STICK = graphics.newImage("textures/buttons/c-stick.png"),
		FILLED = graphics.newImage("textures/buttons/c-stick-filled.png"),
	},
	A = {
		OUTLINE = graphics.newImage("textures/buttons/a-outline.png"),
		FILLED = graphics.newImage("textures/buttons/a-filled.png"),
		PRESSED = graphics.newImage("textures/buttons/a-pressed.png"),
		COLOR = color(0, 225, 150, 255),
		POSITION = {
			x = 12 + 64 + 256,
			y = 48
		}
	},
	B = {
		OUTLINE = graphics.newImage("textures/buttons/b-outline.png"),
		FILLED = graphics.newImage("textures/buttons/b-filled.png"),
		PRESSED = graphics.newImage("textures/buttons/b-pressed.png"),
		COLOR = color(230, 0, 0, 255),
		POSITION = {
			x = 16 + 256,
			y = 92
		}
	},
	X = {
		OUTLINE = graphics.newImage("textures/buttons/x-outline.png"),
		FILLED = graphics.newImage("textures/buttons/x-filled.png"),
		PRESSED = graphics.newImage("textures/buttons/x-pressed.png"),
		COLOR = color(255, 255, 255, 255),
		POSITION = {
			x = 138 + 256,
			y = 32
		}
	},
	Y = {
		OUTLINE = graphics.newImage("textures/buttons/y-outline.png"),
		FILLED = graphics.newImage("textures/buttons/y-filled.png"),
		PRESSED = graphics.newImage("textures/buttons/y-pressed.png"),
		COLOR = color(255, 255, 255, 255),
		POSITION = {
			x = 60 + 256,
			y = -16
		}
	},
	Z = {
		OUTLINE = graphics.newImage("textures/buttons/z-outline.png"),
		FILLED = graphics.newImage("textures/buttons/z-filled.png"),
		PRESSED = graphics.newImage("textures/buttons/z-pressed.png"),
		COLOR = color(165, 75, 165, 255),
		POSITION = {
			x = 128 + 256,
			y = -32
		}
	},
	START = {
		OUTLINE = graphics.newImage("textures/buttons/start-outline.png"),
		FILLED = graphics.newImage("textures/buttons/start-filled.png"),
		PRESSED = graphics.newImage("textures/buttons/start-pressed.png"),
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
			if button ~= "START" or (button == "START" and SETTINGS:IsStartEnabled()) then
				local pos = texture.POSITION
				graphics.setColor(texture.COLOR)
				if texture.PRESSED and bit.band(controller.buttons.pressed, flag) == flag then -- Check if the button is pressed
					graphics.easyDraw(texture.PRESSED, pos.x, pos.y, 0, 128, 128)
				else
					local text = SETTINGS:IsHighContrast() and texture.FILLED or texture.OUTLINE
					if text then
						graphics.easyDraw(text, pos.x, pos.y, 0, 128, 128)
					end
				end
			end
		end
	end
end

function SKIN:Paint(controller)
	local x, y = memory.game.translateAxis(controller.joystick.x, controller.joystick.y)

	--[[if SETTINGS:IsDebugging() then
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

	local far = mag * 12 -- Higher value = headed towards infinity
	local near = mag * 20 -- Higher value = more rotation into the horizon

	-- Make the rectangle look like its fading into the horizon

	-- Top left
	vertices[1][1] = far
	-- Top right
	vertices[2][1] = 128 - far

	-- Bottom left
	vertices[1][2] = near
	-- Bottom right
	vertices[2][2] = near

	local rotated = transformVertices(vertices, 64 + 22 + (44 * vx), 64 + 8 + (44 * vy), angle, 64, 64)

	graphics.setColor(255, 255, 255, 255)

	if SETTINGS:IsHighContrast() then
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
	perspective.quad(SETTINGS:IsHighContrast() and BUTTON_TEXTURES.JOYSTICK.FILLED or BUTTON_TEXTURES.JOYSTICK.STICK, rotated[1], rotated[2], rotated[3], rotated[4])
	perspective.off()

	-- Draw C-Stick

	local x, y = memory.game.translateAxis(controller.cstick.x, controller.cstick.y)

	--[[if SETTINGS:IsDebugging() then
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

	if SETTINGS:IsHighContrast() then
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
	perspective.quad(SETTINGS:IsHighContrast() and BUTTON_TEXTURES.CSTICK.FILLED or BUTTON_TEXTURES.CSTICK.STICK, rotated[1], rotated[2], rotated[3], rotated[4])
	perspective.off()

	graphics.setColor(255, 255, 255, 255)

	-- Draw L

	if SETTINGS:IsSlippiReplay() then
		graphics.setLineStyle("smooth")
		graphics.setLineWidth(4)

		-- Draw outline
		graphics.easyDraw(SETTINGS:IsHighContrast() and ANALOG_FILLED or ANALOG, 108 + 6, 14, 0, 116, 24)

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
		graphics.setLineWidth(4)

		-- Draw L

		-- Draw outline
		graphics.easyDraw(SETTINGS:IsHighContrast() and ANALOG_FILLED or ANALOG, 24 + 6, 14, 0, 116, 24)
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
		graphics.easyDraw(SETTINGS:IsHighContrast() and ANALOG_FILLED or ANALOG, 48 + 128 + 6, 14, 0, 116, 24)
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
		
		--[[if SETTINGS:IsDebugging() then
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

	if SETTINGS:IsDPadEnabled() then
		graphics.easyDraw(SETTINGS:IsHighContrast() and BUTTON_TEXTURES.DPAD.GATE_FILLED or BUTTON_TEXTURES.DPAD.GATE, 108, 144, 0, 128, 128)
		drawButtons(DPAD, controller)
	end

	drawButtons(BUTTONS, controller)
end

overlay.registerSkin("Default", SKIN)