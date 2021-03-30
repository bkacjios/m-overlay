local PANEL = {}

function PANEL:Initialize()
	self:super()

	self:MakeAccessor("Port", "m_iPort", 1)

	self:DockPadding(0, 0, 0, 0)
	self:SetSize(80, 112)
	self:SetBorderColor(color_clear)
	self:SetBackgroundColor(color(0, 0, 0, 100))
	self:CenterVertical()

	self.PORT1 = self:Add("Checkbox")
	self.PORT1:SetText("Port 1")
	self.PORT1:Dock(DOCK_TOP)
	self.PORT1:SetToggleable(false)
	self.PORT1:SetToggled(true)

	self.PORT2 = self:Add("Checkbox")
	self.PORT2:SetText("Port 2")
	self.PORT2:Dock(DOCK_TOP)
	self.PORT2:SetToggleable(false)

	self.PORT3 = self:Add("Checkbox")
	self.PORT3:SetText("Port 3")
	self.PORT3:Dock(DOCK_TOP)
	self.PORT3:SetToggleable(false)

	self.PORT4 = self:Add("Checkbox")
	self.PORT4:SetText("Port 4")
	self.PORT4:Dock(DOCK_TOP)
	self.PORT4:SetToggleable(false)

	self.PORT1.OnPressed = function()
		self:SetPort(1)
		self.PORT1:SetToggled(true)
		self.PORT2:SetToggled(false)
		self.PORT3:SetToggled(false)
		self.PORT4:SetToggled(false)
	end

	self.PORT2.OnPressed = function()
		self:SetPort(2)
		self.PORT1:SetToggled(false)
		self.PORT2:SetToggled(true)
		self.PORT3:SetToggled(false)
		self.PORT4:SetToggled(false)
	end

	self.PORT3.OnPressed = function()
		self:SetPort(3)
		self.PORT1:SetToggled(false)
		self.PORT2:SetToggled(false)
		self.PORT3:SetToggled(true)
		self.PORT4:SetToggled(false)
	end

	self.PORT4.OnPressed = function()
		self:SetPort(4)
		self.PORT1:SetToggled(false)
		self.PORT2:SetToggled(false)
		self.PORT3:SetToggled(false)
		self.PORT4:SetToggled(true)
	end
end

function PANEL:ChangePort(port)
	if port == 1 then
		self.PORT1:OnPressed()
	elseif port == 2 then
		self.PORT2:OnPressed()
	elseif port == 3 then
		self.PORT3:OnPressed()
	elseif port == 4 then
		self.PORT4:OnPressed()
	end
	self:SetPort(port)
end

function PANEL:Toggle()
	self:SetVisible(not self:IsVisible())
end

gui.register("PortSelect", PANEL, "Panel")