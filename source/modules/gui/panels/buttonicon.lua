local PANEL = class.create("ButtonIcon", "Button")

function PANEL:ButtonIcon()
	-- Initialize our baseclass
	self:super()

	self:SetFocusable(true)

	self.m_pIcon = self:Add("Image")
	self.m_pIcon:Dock(DOCK_LEFT)
	self.m_pIcon:SetSize(16, 16)
	self:InheritMethods(self.m_pIcon)

	self:TextMargin(28, 0, 0, 0)
	self:SetTextAlignmentX("left")

	gui.skinHook("Init", "Button", self)
end

function PANEL:PrePaint(w, h)
	if self.m_bDrawButton then
		gui.skinHook("Paint", "Button", self, w, h)
	end
end

function PANEL:Paint(w, h)
	self:PaintLabel(w, h)
end

function PANEL:PaintOverlay(w, h)
	gui.skinHook("PaintOverlay", "Button", self, w, h)
end