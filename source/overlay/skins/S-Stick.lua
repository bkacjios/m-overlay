local SKIN = {}

local ANALOG = graphics.newImage("textures/buttons/analog-outline.png")
local ANALOG_FILLED = graphics.newImage("textures/buttons/analog-filled.png")

local BUTTON_TEXTURES = {
	JOYSTICK = {
		GATE = graphics.newImage("textures/buttons/SS/SS_Gate.png"),
		GATE_FILLED = graphics.newImage("textures/buttons/SS/SS_Gate.png"),
		MASK = graphics.newImage("textures/buttons/joystick-mask.png"),
		STICK = graphics.newImage("textures/buttons/SS/S_Stick.png"),
		FILLED = graphics.newImage("textures/buttons/SS/S_Stick.png"),
	},
	CSTICK = {
		GATE = graphics.newImage("textures/buttons/c-stick-gate.png"),
		GATE_FILLED = graphics.newImage("textures/buttons/c-stick-gate-filled.png"),
		STICK = graphics.newImage("textures/buttons/c-stick-solid.png"),
	},

	L = {
		OUTLINE = graphics.newImage("textures/buttons/SS/SS_L.png"),
		PRESSED = graphics.newImage("textures/buttons/SS/SS_LP.png"),
		
		POSITION = {
			x = 256 - 64 + 40,
			y = 64 + 10
		}
	},	
	
	R = {
		OUTLINE = graphics.newImage("textures/buttons/SS/SS_R.png"),
		PRESSED = graphics.newImage("textures/buttons/SS/SS_RP.png"),
		
		POSITION = {
			x = 256 + 128 + 40,
			y = 64
		}
	},	
	
	C_UP = {
		OUTLINE = graphics.newImage("textures/buttons/SS/SS_CU.png"),
		PRESSED = graphics.newImage("textures/buttons/SS/SS_CUP.png"),
		
		POSITION = {
			x = 256 + 40,
			y = -10
		}
	},

	C_DOWN = {
		OUTLINE = graphics.newImage("textures/buttons/SS/SS_CD.png"),
		PRESSED = graphics.newImage("textures/buttons/SS/SS_CDP.png"),
		
		POSITION = {
			x = 256 - 64 - 15,
			y = 128 + 64 - 10
		}
	},

	C_LEFT = {
		OUTLINE = graphics.newImage("textures/buttons/SS/SS_CL.png"),
		PRESSED = graphics.newImage("textures/buttons/SS/SS_CLP.png"),
		
		POSITION = {
			x = 256 - 64 + 40,
			y = 10
		}
	},

	C_RIGHT = {
		OUTLINE = graphics.newImage("textures/buttons/SS/SS_CR.png"),
		PRESSED = graphics.newImage("textures/buttons/SS/SS_CRP.png"),
		
		POSITION = {
			x = 256 + 64 + 40,
			y = -10
		}
	},

	A = {
		OUTLINE = graphics.newImage("textures/buttons/SS/SS_A.png"),
		PRESSED = graphics.newImage("textures/buttons/SS/SS_AP.png"),
		
		POSITION = {
			x = 256 - 64 + 35,
			y = 128 + 10
		}
	},
	B = {
		OUTLINE = graphics.newImage("textures/buttons/SS/SS_B.png"),
		PRESSED = graphics.newImage("textures/buttons/SS/SS_BP.png"),
		
		POSITION = {
			x = 256 + 64 + 40,
			y = 64 - 10
		}
	},
	X = {
		OUTLINE = graphics.newImage("textures/buttons/SS/SS_X.png"),
		PRESSED = graphics.newImage("textures/buttons/SS/SS_XP.png"),
		
		POSITION = {
			x = 256 + 128 + 40,
			y = 0
		}
	},
	Y = {
		OUTLINE = graphics.newImage("textures/buttons/SS/SS_Y.png"),
		PRESSED = graphics.newImage("textures/buttons/SS/SS_YP.png"),
		
		POSITION = {
			x = 256 + 40,
			y = 64 - 10
		}
	},
	Z = {
		OUTLINE = graphics.newImage("textures/buttons/SS/SS_Z.png"),
		PRESSED = graphics.newImage("textures/buttons/SS/SS_ZP.png"),
		
		POSITION = {
			x = 256 - 64 - 25,
			y = 128 - 10
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
			local pos = texture.POSITION
			graphics.setColor(texture.COLOR)
			local analogr = (SETTINGS:IsSlippiReplay() and melee.isInGame() and controller.analog) and controller.analog.float or controller.analog
			local tl, tr = memory.game.translateTriggers(0, analogr)

			if texture.PRESSED and bit.band(controller.buttons.pressed, flag) == flag then -- Check if the button is pressed
				graphics.easyDraw(texture.PRESSED, pos.x, pos.y, 0, 88, 88)
			elseif button == "R" and tr > 0 and tr < 0.5 then
				graphics.easyDraw(BUTTON_TEXTURES.R.PRESSED, pos.x, pos.y, 0, 88, 88)
			else
				local text = SETTINGS:IsHighContrast() and texture.FILLED or texture.OUTLINE
				if text then
					graphics.easyDraw(text, pos.x, pos.y, 0, 88, 88)
				end
			end
		end
	end
end

function SKIN:Paint(controller)
	local x, y = memory.game.translateJoyStick(controller.joystick.x, controller.joystick.y)

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

	local far = mag * 15 -- Higher value = headed towards infinity
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

	-- Draw buttons
	drawButtons(BUTTONS, controller)
end

overlay.registerSkin("S-Stick", SKIN)