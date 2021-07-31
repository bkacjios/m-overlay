ACCESSOR(PANEL, "Color", "m_cColor", color_white)

function PANEL:Initialize()
	-- Initialize our baseclass
	self:super()

	self:TextMargin(24, 0, 0, 0)
end

function PANEL:Paint(w, h)
	if self.m_bDrawPanel then
		gui.skinHook("Paint", "Button", self, w, h)
	end

	if self.m_bDrawLabel then
		self:super("Paint", w, h)
	end

	graphics.setColor(self.m_cColor)
	graphics.rectangle("fill", 4, 4, h-8, h-8)
	graphics.setColor(self:GetBorderColor())
	graphics.rectangle("line", 4, 4, h-8, h-8)
end

function PANEL:PaintOverlay(w, h)
	gui.skinHook("PaintOverlay", "Button", self, w, h)
end

gui.register("ColorButton", PANEL, "Button")