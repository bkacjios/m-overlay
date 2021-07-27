function PANEL:Initialize()
	self:super()

	self.RIGHT = self:Add("Panel")
	self.RIGHT:SetWidth(128)
	self.RIGHT:Dock(DOCK_RIGHT)

	self.m_txtColorValue = self.RIGHT:Add("TextEntry")

	self.m_pColorGradient = self:Add("ColorGradient")
	self.m_pColorGradient:Dock(DOCK_FILL)

end

function PANEL:SetColor(c)
	self.m_pColorGradient:SetColor(c)
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
end

gui.register("ColorPicker", PANEL, "Panel")