local PANEL = {}

local watcher = require("memory.watcher")

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
local MASK_SHADER = graphics.newShader[[
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
			// a discarded pixel wont be applied as the stencil.
			discard;
		}
		return vec4(1.0);
	}
]]

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
		COLOR = {0, 225, 150, 255},
		POSITION = {
			x = 12 + 64 + 256,
			y = 64
		}
	},
	B = {
		OUTLINE = newImage("textures/buttons/b-outline.png"),
		PRESSED = newImage("textures/buttons/b-pressed.png"),
		COLOR = {230, 0, 0, 255},
		POSITION = {
			x = 16 + 256,
			y = 108
		}
	},
	X = {
		OUTLINE = newImage("textures/buttons/x-outline.png"),
		PRESSED = newImage("textures/buttons/x-pressed.png"),
		COLOR = {255, 255, 255, 255},
		POSITION = {
			x = 138 + 256,
			y = 48
		}
	},
	Y = {
		OUTLINE = newImage("textures/buttons/y-outline.png"),
		PRESSED = newImage("textures/buttons/y-pressed.png"),
		COLOR = {255, 255, 255, 255},
		POSITION = {
			x = 60 + 256,
			y = 0
		}
	},
	Z = {
		OUTLINE = newImage("textures/buttons/z-outline.png"),
		PRESSED = newImage("textures/buttons/z-pressed.png"),
		COLOR = {165, 75, 165, 255},
		POSITION = {
			x = 128 + 256,
			y = -16
		}
	},
	START = {
		OUTLINE = newImage("textures/buttons/start-outline.png"),
		PRESSED = newImage("textures/buttons/start-pressed.png"),
		COLOR = {255, 255, 255, 255},
		POSITION = {
			x = 256,
			y = 42
		}
	}
}

local MAX_PORTS = 4

local state = require("smash.states")

function PANEL:Initialize()
	self:super()

	self.m_pFont = newFont("fonts/Rodin-Bokutoh-Pro-UB.ttf", 16)

	self.m_bEnabled = false
	self.m_iPort = -1
	self.m_iActions = 0

	watcher.hook("match.finished", "Actions - Reset", function(finished)
		if finished == 0 then
			print("starting APM counter")
			self.m_bEnabled = true
			self:ResetAPM()
		else
			print("stopping APM counter")
			self.m_bEnabled = false
		end
	end)

	watcher.hook("player.*.*.action_state", "Actions - Counter", function(port, entityType, state_id)
		if port == self:GetPort() and not state.isNatural(state_id) then
			local player = watcher.player[port][entityType]
			print(string.format("[%04X] %s", state_id, state.translateChar(player.character, state_id)))
			self:UpdateAPM(entityType, state_id)
		end
	end)
end

function PANEL:SetPort(port)
	self.m_iPort = port
end

function PANEL:GetPort()
	return self.m_iPort
end

function PANEL:ResetAPM()
	self.m_iActions = 0
end

function PANEL:UpdateAPM(entityType, state)
	if not self.m_bEnabled then return end
	self.m_iActions = self.m_iActions + 1
end

function PANEL:Paint(w, h)
	local controller = watcher.controller[self.m_iPort]

	if controller and controller.plugged ~= 0xFF then
		-- Draw Joystick

		local time = watcher.match.frame / 60

		graphics.setFont(self.m_pFont)

		if time < 60 then
			graphics.print(format("APM: %d", self.m_iActions), 8, h - 24)
		else
			graphics.print(format("APM: %d", self.m_iActions / time * 60), 8, h - 24)
		end

		local x, y = controller.joystick.x, 1 - controller.joystick.y

		graphics.setColor(255, 255, 255, 255)

		graphics.stencil(function()
			graphics.setShader(MASK_SHADER)
			graphics.easyDraw(BUTTON_TEXTURES.JOYSTICK.MASK, 22 + (40 * x), 12 + (40 * y), 0, 128, 128, 0, 0)
			graphics.setShader()
		end, "replace", 1)
		graphics.setStencilTest("equal", 0) -- Mask out the gate behind the joystick
			graphics.easyDraw(BUTTON_TEXTURES.JOYSTICK.BACKGROUND, 22, 52, 0, 128, 128)
		graphics.setStencilTest()

		graphics.easyDraw(BUTTON_TEXTURES.JOYSTICK.STICK, 22 + (40 * x), 12 + (40 * y), 0, 128, 128, 0, 0, 0.0, 0.0)

		-- Draw C-Stick

		local x, y = controller.cstick.x, 1 - controller.cstick.y

		graphics.setColor(255, 235, 0, 255)
		graphics.easyDraw(BUTTON_TEXTURES.CSTICK.BACKGROUND, 48 + 128, 52, 0, 128, 128)
		graphics.easyDraw(BUTTON_TEXTURES.CSTICK.STICK, 48 + 128 + (32 * x), 20 + (32 * y), 0, 128, 128, 0, 0)

		graphics.setColor(255, 255, 255, 255)

		-- Draw L

		graphics.setLineStyle("smooth")
		love.graphics.setLineWidth(3)

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

gui.register("ControllerDisplay", PANEL, "Panel")