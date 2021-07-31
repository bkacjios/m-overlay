function PANEL:Initialize()
	self:super() -- Initialize our baseclass
	
	self.m_txtColorValue = self:Add("TextEntry")
	self.m_txtColorValue:Dock(DOCK_TOP)
	self.m_txtColorValue:SetHoveredInput(true)

	self.m_txtColorValue.OnTextChanged = function(this, text, add)
		if text:match("(#%x%x%x%x%x%x)") then
			self:SetColor(color(text))
		end
	end

	self.m_pColorShade = self:Add("ColorShade")
	self.m_pColorShade:Dock(DOCK_FILL)

	self.m_pColorShade.OnColorChanged = function(this, col)
		-- col will be our final color
		self.m_txtColorValue:SetText(string.format("#%06X", col:hex()))
		self.m_txtColorValue:SelectAll()
	end

	self.m_pColorHue = self:Add("ColorHue")
	self.m_pColorHue:Dock(DOCK_RIGHT)

	self.m_pColorHue.OnHueChanged = function(this, hue)
		-- Set the hue of our shade picker
		self.m_pColorShade:SetHue(hue)
	end

	self:SetColor(color(0, 255, 255))
end

function PANEL:SetColor(c)
	local hue, saturation, value = ColorToHSV(c)
	if saturation > 0 then
		-- Only update hue if we aren't achromatic
		self.m_pColorHue:SetHue(hue)
	end
	self.m_pColorShade:SetColor(c)
end

function PANEL:GetColor()
	return self.m_pColorShade:GetColor()
end

gui.register("ColorPicker", PANEL, "Panel")