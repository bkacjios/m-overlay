function PANEL:Initialize()
	self:super()

	self.m_txtColorValue = self:Add("TextEntry")
	self.m_txtColorValue:Dock(DOCK_TOP)

	self.m_pColorShade = self:Add("ColorShade")
	self.m_pColorShade:Dock(DOCK_FILL)

	self.m_pColorShade.OnShadeChanged = function(this, shade)
		self.m_txtColorValue:SetText(string.format("#%06X", shade:hex()))
	end

	self.m_pColorHue = self:Add("ColorHue")
	self.m_pColorHue:Dock(DOCK_RIGHT)

	self.m_pColorHue.OnHueChanged = function(this, hue)
		self.m_pColorShade:SetColor(hue)
	end

	self.m_pColorHue:SetHue(180)
end

function PANEL:SetColor(c)
	self.m_pColorShade:SetColor(c)
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
end

gui.register("ColorPicker", PANEL, "Panel")