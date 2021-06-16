local PANEL = {}

local overlay = require("overlay")

function PANEL:Initialize()
	self:super()

	self:MakeAccessor("Port", "m_iPort", 1)

	self:DockPadding(1, 1, 1, 1)
	self:SetSize(80, 106)
	self:SetBorderColor(color_clear)
	self:SetBackgroundColor(color(0, 0, 0, 100))
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

		but.OnPressed = function()
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

gui.register("PortSelect", PANEL, "Panel")