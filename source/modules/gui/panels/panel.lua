local PANEL = class.create("Panel", "BasePanel")

PANEL:ACCESSOR("Enabled", "m_bEnabled", true)
PANEL:ACCESSOR("BorderColor", "m_cBorderColor")
PANEL:ACCESSOR("BackgroundColor", "m_cBackgroundColor")
PANEL:ACCESSOR("BGColor", "m_cBackgroundColor")
PANEL:ACCESSOR("TooltipTitle", "m_strTooltipTitle")
PANEL:ACCESSOR("TooltipBody", "m_strTooltipBody")
PANEL:ACCESSOR("DrawPanel", "m_bDrawPanel", true)

function PANEL:Panel()
	self:super() -- Initialize our baseclass
	gui.skinHook("Init", "Panel", self)
end

function PANEL:Paint(w, h)
	if self.m_bDrawPanel then
		gui.skinHook("Paint", "Panel", self, w, h)
	end
end

function PANEL:PaintOverlay(w, h)
	if self.m_bDrawPanel then
		gui.skinHook("PaintOverlay", "Panel", self, w, h)
	end
end

function PANEL:PostPaint(w, h)
	if not self:IsEnabled() then
		graphics.setColor(color(0, 0, 0, 100))
		graphics.rectangle("fill", 0, 0, w, h)
	end
end

function PANEL:OnQueryTooltip()
	if self.m_strTooltipTitle and self.m_strTooltipBody then
		gui.setTooltip(self, self.m_strTooltipTitle, self.m_strTooltipBody)
		return true
	end
end
