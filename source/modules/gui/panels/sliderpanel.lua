local PANEL = class.create("SliderPanel", "Label")

PANEL:ACCESSOR("TextFormat", "m_strTextFormat", "%d")

function PANEL:SliderPanel()
	self:super() -- Initialize our baseclass
	self:SetFocusable(true)
	self:SetDrawPanel(true)
	self:SetBGColor(color(215, 215, 215))

	self:TextMargin(0, 4, 0, 0)
	self:SetTextAlignmentX("center")
	self:SetTextAlignmentY("top")
	self:SetTextColor(color_darkgrey)
	self:DockPadding(2, 18, 2, 2)

	self.m_pSlider = self:Add("Slider")
	self.m_pSlider:Dock(DOCK_TOP)

	self:ValidateLayout()
	self:SizeToChildren(false, true)

	self:InheritMethods(self.m_pSlider) -- Inherit all slider functions

	self.m_pSlider.OnValueChanged = function(this, value)
		self:SetText(string.format(self.m_strTextFormat, value))
		self:OnValueChanged(value)
	end
end

function PANEL:PerformLayout()
end

function PANEL:OnValueChanged(value)
	-- Override
end