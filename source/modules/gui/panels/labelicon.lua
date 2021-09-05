local PANEL = class.create("LabelIcon", "Label")

function PANEL:LabelIcon()
	-- Initialize our baseclass
	self:super()

	self.m_pIcon = self:Add("Image")
	self.m_pIcon:Dock(DOCK_LEFT)
	self.m_pIcon:SetSize(16, 16)
	self.m_pIcon:SetFocusable(false)
	self:InheritMethods(self.m_pIcon)

	self:TextMargin(28, 0, 0, 0)
	self:SetTextAlignmentX("left")
end