local PANEL = class.create("PortSelect", "Panel")

ACCESSOR(PANEL, "Port", "m_iPort", 1)

local overlay = require("overlay")

function PANEL:PortSelect()
	self:super() -- Initialize our baseclass

	self:DockPadding(1, 1, 1, 1)
	self:SetBorderColor(color_clear)
	self:SetBackgroundColor(color(0, 0, 0, 200))

	local LABEL = self:Add("Label")
	LABEL:SetText("Ports")
	LABEL:SetTextAlignment("center")
	LABEL:SizeToText()
	LABEL:Dock(DOCK_TOP)
	LABEL:SetTextColor(color_white)
	LABEL:SetShadowDistance(1)
	LABEL:SetShadowColor(color_black)
	LABEL:SetFont("fonts/melee-bold.otf", 12)
	self.LABEL = LABEL

	self:SetSize(80, 106 + LABEL:GetHeight() + 5)
	self:CenterVertical()

	self.PORT_BUTTONS = {}

	for i=1,4 do
		local but = self:Add("Checkbox")
		but:SetText("Port "..i)
		but:DockMargin(1, 1, 1, 1)
		but:Dock(DOCK_TOP)
		but:SetToggleable(false)
		but:SetToggled(false)
		but:SetRadio(true)

		but.OnClick = function()
			overlay.showPort(1)
			self:ChangePort(i)
		end

		self.PORT_BUTTONS[i] = but
	end
end

function PANEL:ChangePort(port)
	for i=1,4 do
		self.PORT_BUTTONS[i]:SetToggled(false)
	end

	self.PORT_BUTTONS[port]:SetToggled(true)
	self:SetPort(port)
	love.updateTitle(love.getTitleNoPort())
end

function PANEL:Toggle()
	self:SetVisible(not self:IsVisible())
end
