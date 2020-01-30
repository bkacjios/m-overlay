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