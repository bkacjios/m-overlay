local PANEL = class.create("Error", "BasePanel")

function PANEL:Error()
	self:super() -- Initialize our baseclass

	self:SetSize(512, 256)
	self:DockPadding(8, 8, 8, 0)

	self.m_pTitle = self:Add("Label")
	self.m_pTitle:Dock(DOCK_TOP)
	self.m_pTitle:SetLineHeight(0.75)
	self.m_pTitle:SetTextColor(color_red)

	self.m_pBody = self:Add("Label")
	self.m_pBody:Dock(DOCK_FILL)
	self.m_pBody:SetWrapped(true)
	self.m_pBody:SetFont("fonts/melee.otf", 11)
	self.m_pBody:SetLineHeight(0.75)
	self.m_pBody:SetPos(8, 16+24)
	self.m_pBody:SetSize(236, 228)
end