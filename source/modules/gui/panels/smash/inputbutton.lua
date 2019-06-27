local PANEL = {}

local memory = require("memory.watcher")

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

function PANEL:Initialize()
	self:super()

	self:MakeAccessor("Port", "m_iPort", 0)
	self:MakeAccessor("Button", "m_sButton", "NONE")
end

function PANEL:IsButtonPressed()
	local controller = memory.controller[self.m_iPort]
	local button = BUTTONS[self.m_sButton:upper()]

	if not button or not controller then return false end

	if controller.plugged ~= 0xFF and bit.band(controller.buttons.pressed, button) == button then
		return true
	end

	return false
end

gui.register("InputButton", PANEL, "Panel")