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
		self.m_pColorShade:SetHue(hue)
	end

	self:SetColor(color(0, 255, 255))
end

function PANEL:SetColor(c)
	local hue, saturation, value = ColorToHSV(c)
	self.m_pColorHue:SetHue(hue)
	self.m_pColorShade:SetHue(hue)
	self.m_pColorShade:SetSaturation(saturation)
	self.m_pColorShade:SetValue(value)
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
end

gui.register("ColorPicker", PANEL, "Panel")