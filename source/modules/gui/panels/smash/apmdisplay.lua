local PANEL = {}

local watcher = require("memory.watcher")
local perspective = require("perspective")
local state = require("smash.states")

require("extensions.math")

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

local DISCONNECTED = newImage("textures/buttons/disconnected.png")

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

	self.m_pFont = newFont("fonts/ultimate-bold.otf", 16)

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
		self.m_iActions = 0
		self.m_bEnabled = true
	else
		self.m_bEnabled = false
	end
end

function PANEL:UpdateAPM(port, entityType, state_id)
	local player = watcher.player[port][entityType]

	if player and port == self:GetPort() and (state.isAction(state_id) or state.isCharacterAction(player.character, state_id)) then
		--print(string.format("[%04X] %s", state_id, state.translateChar(player.character, state_id)))
		if not self.m_bEnabled then return end
		self.m_iActions = self.m_iActions + 1
	end
end


function PANEL:Paint(w, h)
	graphics.setColor(255, 255, 255, 255)

	local time = watcher.match.frame / 60

	graphics.setFont(self.m_pFont)
	graphics.print(format("APM: %d", self.m_iActions / time * 60), 8, h - 24)
end

gui.register("APMDisplay", PANEL, "Base")