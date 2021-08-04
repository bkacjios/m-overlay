local PANEL = {}

ACCESSOR(PANEL, "Enabled", "m_bEnabled", true)

PANEL.ToolTipColor = color(240, 240, 240)

function PANEL:Initialize()
	self:super() -- Initialize our baseclass
	self:SetFocusable(false) -- Ignore focus

	self:SetSize(256, 256)
	self:DockPadding(8, 8, 8, 0)

	self.m_pTitle = self:Add("Label")
	self.m_pTitle:Dock(DOCK_TOP)
	self.m_pTitle:SetLineHeight(0.75)
	self.m_pTitle:SetTextColor(color_red)

	self.m_pBody = self:Add("Label")
	self.m_pBody:Dock(DOCK_FILL)
	self.m_pBody:SetWrapped(true)
	self.m_pBody:SetFont("fonts/melee.otf", 10)
	self.m_pBody:SetLineHeight(0.75)
	self.m_pBody:SetPos(8, 16+24)
	self.m_pBody:SetSize(236, 228)
end

function PANEL:SetTitle(str)
	self.m_pTitle:SetText(str)
end

function PANEL:SetBody(str)
	self.m_pBody:SetText(str)
	self.m_pBody:HeightToText()
	self:SizeToChildren(false, true)
end

function PANEL:Paint(w, h)
	graphics.setColor(color_black)
	graphics.roundRect(4, 4, w-8, h-8, 4)
	graphics.setColor(self.ToolTipColor)
	graphics.roundRect(5, 5, w-10, h-10, 4)
end

gui.register("ToolTip", PANEL, "Base")