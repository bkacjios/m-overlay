local PANEL = class.create("GCBinderPanel", "Label")

function PANEL:GCBinderPanel()
	self:super() -- Initialize our baseclass
	self:SetFocusable(true)
	self:SetDrawPanel(true)
	self:SetBGColor(color(215, 215, 215))

	self:SetHeight(48)

	self:TextMargin(0, 4, 0, 0)
	self:SetTextAlignmentX("center")
	self:SetTextAlignmentY("top")
	self:SetTextColor(color_darkgrey)
	self:DockPadding(2, 18, 2, 2)

	self.m_pBinder = self:Add("GCBinder")
	self.m_pBinder:Dock(DOCK_TOP)

	self:InheritMethods(self.m_pBinder) -- Inherit all slider functions
end