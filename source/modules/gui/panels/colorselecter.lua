local PANEL = class.create("ColorSelector", "Panel")

PANEL:ACCESSOR("ColorButton", "m_pColorButton")

function PANEL:ColorSelector()
	self:super()

	self.COLORPICKER = self:Add("ColorPicker")
	self.COLORPICKER:Dock(DOCK_FILL)
	self.COLORPICKER:DockPadding(0,0,0,0)
	self.COLORPICKER:DockMargin(0,0,0,0)
	self.COLORPICKER:SetBorderColor(color_blank)

	self.OPTIONS = self:Add("Panel")
	self.OPTIONS:Dock(DOCK_BOTTOM)
	self.OPTIONS:SetHeight(28)
	self.OPTIONS:DockPadding(0,0,0,0)
	self.OPTIONS:DockMargin(0,0,0,0)
	self.OPTIONS:SetBorderColor(color_blank)

	self.OKAY = self.OPTIONS:Add("ButtonIcon")
	self.OKAY:SetImage("textures/gui/disk.png")
	self.OKAY:Dock(DOCK_RIGHT)
	self.OKAY:SetText("Save")
	self.OKAY:SetWidth(64)

	self.OKAY.OnClick = function(this)
		self:SetVisible(false)
		if self.m_pColorButton and self.m_pColorButton.SetColor then
			self.m_pColorButton:SetColor(self.COLORPICKER:GetColor())
		end
	end

	self.CANCEL = self.OPTIONS:Add("ButtonIcon")
	self.CANCEL:SetImage("textures/gui/cancel.png")
	self.CANCEL:Dock(DOCK_RIGHT)
	self.CANCEL:SetText("Cancel")
	self.CANCEL:SetWidth(76)

	self.CANCEL.OnClick = function(this)
		self:SetVisible(false)
	end
end

function PANEL:SetColor(col)
	self.COLORPICKER:SetColor(col)
end

function PANEL:GetColor()
	return self.COLORPICKER:GetColor()
end
