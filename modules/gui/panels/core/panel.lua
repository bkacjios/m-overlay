local PANEL = {}

function PANEL:Initialize()
	self:super()

	self.m_cBorderColor = color_blank
	self.m_cBackgroundColor = color_blank

	gui.skinHook("Init", "Panel", self)
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "Panel", self, w, h)
end

function PANEL:SetBorderColor(c)
	self.m_cBorderColor = c
end

function PANEL:GetBorderColor()
	return self.m_cBorderColor
end

function PANEL:SetBGColor(c)
	self.m_cBackgroundColor = c
end

function PANEL:GetBGColor()
	return self.m_cBackgroundColor
end

gui.register("Panel", PANEL, "Base")