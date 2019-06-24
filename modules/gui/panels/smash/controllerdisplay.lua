local PANEL = {}

local watcher = require("memory.watcher")
local perspective = require("perspective")
local state = require("smash.states")

local BUTTONS = {
	NONE		= 0x0000,
	DPAD_LEFT	= 0x0001,
	DPAD_RIGHT	= 0x0002,
	DPAD_DOWN	= 0x0004,
	DPAD_UP		= 0x0008,
	Z			= 0x0010,
	R			= 0x0020,
	L			= 0x0040,
	A			= 0x0100,
	B			= 0x0200,
	X			= 0x0400,
	Y			= 0x0800,
	START		= 0x1000,
}

local timer = love.timer
local graphics = love.graphics
local newImage = graphics.newImage
local newFont = graphics.newFont
local format = string.format

local BUTTON_TEXTURES = {
	DPAD = {
		BACKGROUND = newImage("textures/buttons/d-pad-gate.png"),
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
		BACKGROUND = newImage("textures/buttons/joystick-gate.png"),
		MASK = newImage("textures/buttons/joystick-mask.png"),
		STICK = newImage("textures/buttons/joystick-outline.png"),
	},
	CSTICK = {
		BACKGROUND = newImage("textures/buttons/c-stick-gate.png"),
		STICK = newImage("textures/buttons/c-stick.png"),
	},
	A = {
		OUTLINE = newImage("textures/buttons/a-outline.png"),
		PRESSED = newImage("textures/buttons/a-pressed.png"),
		COLOR = color(0, 225, 150, 255),
		POSITION = {
			x = 12 + 64 + 256,
			y = 64
		}
	},
	B = {
		OUTLINE = newImage("textures/buttons/b-outline.png"),
		PRESSED = newImage("textures/buttons/b-pressed.png"),
		COLOR = color(230, 0, 0, 255),
		POSITION = {
			x = 16 + 256,
			y = 108
		}
	},
	X = {
		OUTLINE = newImage("textures/buttons/x-outline.png"),
		PRESSED = newImage("textures/buttons/x-pressed.png"),
		COLOR = color(255, 255, 255, 255),
		POSITION = {
			x = 138 + 256,
			y = 48
		}
	},
	Y = {
		OUTLINE = newImage("textures/buttons/y-outline.png"),
		PRESSED = newImage("textures/buttons/y-pressed.png"),
		COLOR = color(255, 255, 255, 255),
		POSITION = {
			x = 60 + 256,
			y = 0
		}
	},
	Z = {
		OUTLINE = newImage("textures/buttons/z-outline.png"),
		PRESSED = newImage("textures/buttons/z-pressed.png"),
		COLOR = color(165, 75, 165, 255),
		POSITION = {
			x = 128 + 256,
			y = -16
		}
	},
	START = {
		OUTLINE = newImage("textures/buttons/start-outline.png"),
		PRESSED = newImage("textures/buttons/start-pressed.png"),
		COLOR = color(255, 255, 255, 255),
		POSITION = {
			x = 256,
			y = 42
		}
	}
}

local MAX_PORTS = 4

function PANEL:Initialize()
	self:super()

	self:SetSize(512, 256)
	
	self:DockPadding(0,0,0,0)
	self:DockMargin(0,0,0,0)

	self.m_pFont = newFont("fonts/A-OTF-FolkPro-Bold.otf", 16)

	self.m_bEnabled = false
	self.m_iPort = -1
	self.m_iActions = 0

	watcher.hook("match.finished", self, self.ResetAPM)
	watcher.hook("player.*.*.action_state", self, self.UpdateAPM)
end

function PANEL:SetPort(port)
	self.m_iPort = port
end

function PANEL:GetPort()
	return self.m_iPort
end

function PANEL:ResetAPM(finished)
	if finished == 0 then
		print("starting APM counter")
		self.m_iActions = 0
		self.m_bEnabled = true
	else
		print("stopping APM counter")
		self.m_bEnabled = false
	end
end

function PANEL:UpdateAPM(port, entityType, state_id)
	local player = watcher.player[port][entityType]

	if player and port == self:GetPort() and (state.isAction(state_id) or state.isCharacterAction(player.character, state_id)) then
		print(string.format("[%04X] %s", state_id, state.translateChar(player.character, state_id)))
		
		if not self.m_bEnabled then return end
		self.m_iActions = self.m_iActions + 1
	end
end

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

function PANEL:Paint(w, h)
	local controller = watcher.controller[self.m_iPort]

	if controller and controller.plugged ~= 0xFF then

		-- Draw APM

		local time = watcher.match.frame / 60

		graphics.setFont(self.m_pFont)
		graphics.print(format("APM: %d", self.m_iActions / time * 60), 8, h - 24)

		-- Draw Joystick

		local x, y = controller.joystick.x, 1 - controller.joystick.y

		local angle = math.atan2(controller.joystick.x, controller.joystick.y)
		local mag = math.sqrt(controller.joystick.x ^ 2 + controller.joystick.y ^ 2)

		local far = mag * 15
		local near = mag * 20

		-- Make the rectangle look like its fading into the horizon
		vertices[1][1] = far		-- x
		vertices[1][2] = near		-- y
		vertices[2][1] = 128 - far	-- x
		vertices[2][2] = near		-- y

		local rotated = transformVertices(vertices, 64 + 22 + (40 * x), 64 + 12 + (40 * y), angle, 64, 64)

		graphics.setColor(255, 255, 255, 255)

		graphics.stencil(function()
			perspective.on(self:GetWorldPos())
			perspective.quad(BUTTON_TEXTURES.JOYSTICK.MASK, rotated[1], rotated[2], rotated[3], rotated[4])
			perspective.off()
		end, "replace", 1)
		graphics.setStencilTest("equal", 0) -- Mask out the gate behind the joystick
			graphics.easyDraw(BUTTON_TEXTURES.JOYSTICK.BACKGROUND, 22, 52, 0, 128, 128)
		graphics.setStencilTest()

		perspective.on(self:GetWorldPos())
		perspective.quad(BUTTON_TEXTURES.JOYSTICK.STICK, rotated[1], rotated[2], rotated[3], rotated[4])
		perspective.off()

		-- Draw C-Stick

		local x, y = controller.cstick.x, 1 - controller.cstick.y

		local angle = math.atan2(controller.cstick.x, controller.cstick.y)
		local mag = math.sqrt(controller.cstick.x ^ 2 + controller.cstick.y ^ 2)

		local far = mag * 12
		local near = mag * 16

		-- Make the rectangle look like its fading into the horizon
		vertices[1][1] = far		-- x
		vertices[1][2] = near		-- y
		vertices[2][1] = 128 - far	-- x
		vertices[2][2] = near		-- y

		local rotated = transformVertices(vertices, 64 + 48 + 128 + (32 * x), 64 + 20 + (32 * y), angle, 64, 64)

		graphics.setColor(255, 235, 0, 255)
		graphics.easyDraw(BUTTON_TEXTURES.CSTICK.BACKGROUND, 48 + 128, 52, 0, 128, 128)

		perspective.on(self:GetWorldPos())
		perspective.quad(BUTTON_TEXTURES.CSTICK.STICK, rotated[1], rotated[2], rotated[3], rotated[4])
		perspective.off()

		graphics.setColor(255, 255, 255, 255)

		-- Draw L

		graphics.setLineStyle("smooth")
		graphics.setLineWidth(3)

		graphics.stencil(function()
			-- Create a rounded rectangle mask
			graphics.rectangle("fill", 24 + 14, 16, 100, 12, 6, 6)
		end, "replace", 1)
		graphics.setStencilTest("greater", 0) -- Only draw within our rounded rectangle mask
			-- L Analog
			graphics.rectangle("fill", 24 + 14, 16, 88 * controller.analog.float.l, 12)

	 		-- L Button
			if bit.band(controller.buttons.pressed, BUTTONS.L) == BUTTONS.L then
				graphics.rectangle("fill", 24 + 14 + 88, 16, 12, 12)
			end
		graphics.setStencilTest()

		-- Draw outline
		graphics.rectangle("line", 24 + 14, 16, 100, 12, 6, 6)
		-- Draw segment for button press
		graphics.line(24 + 14 + 88, 16, 24 + 14 + 88, 16 + 12)

		-- Draw R

		graphics.stencil(function()
			-- Create a rounded rectangle mask
			graphics.rectangle("fill", 48 + 128 + 14, 16, 100, 12, 6, 6)
		end, "replace", 1)
		graphics.setStencilTest("greater", 0) -- Only draw within our rounded rectangle mask
			-- R Analog
			graphics.rectangle("fill", 48 + 128 + 14 + 12 + (88 * (1 - controller.analog.float.r)), 16, 88 * controller.analog.float.r, 12)

			-- R Button
			if bit.band(controller.buttons.pressed, BUTTONS.R) == BUTTONS.R then
				graphics.rectangle("fill", 48 + 128 + 14, 16, 12, 12)
			end
		graphics.setStencilTest()

		-- Draw outline
		graphics.rectangle("line", 48 + 128 + 14, 16, 100, 12, 6, 6)
		-- Draw segment for button press
		graphics.line(48 + 128 + 14 + 12, 16, 48 + 128 + 14 + 12, 16 + 12)

		-- Draw buttons

		graphics.easyDraw(BUTTON_TEXTURES.DPAD.BACKGROUND, 108, 144, 0, 128, 128)

		for button, flag in pairs(BUTTONS) do
			local texture = BUTTON_TEXTURES[button]
			if texture then
				local pos = texture.POSITION
				graphics.setColor(texture.COLOR)
				if texture.PRESSED and bit.band(controller.buttons.pressed, flag) == flag then -- Check if the button is pressed
					graphics.easyDraw(texture.PRESSED, pos.x, pos.y, 0, 128, 128)
				elseif texture.OUTLINE then
					graphics.easyDraw(texture.OUTLINE, pos.x, pos.y, 0, 128, 128)
				end
			end
		end
	end
end

gui.register("ControllerDisplay", PANEL, "Base")