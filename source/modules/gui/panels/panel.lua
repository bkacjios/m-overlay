local PANEL = class.create("Panel", "BasePanel")

PANEL:ACCESSOR("Enabled", "m_bEnabled", true)
PANEL:ACCESSOR("BorderColor", "m_cBorderColor", color_blank)
PANEL:ACCESSOR("BackgroundColor", "m_cBackgroundColor", color_blank)
PANEL:ACCESSOR("BGColor", "m_cBackgroundColor", color_blank)
PANEL:ACCESSOR("TooltipTitle", "m_strTooltipTitle", nil)
PANEL:ACCESSOR("TooltipBody", "m_strTooltipBody", nil)

function PANEL:Panel()
	self:super() -- Initialize our baseclass
	gui.skinHook("Init", "Panel", self)
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "Panel", self, w, h)
end

function PANEL:PaintOverlay(w, h)
	gui.skinHook("PaintOverlay", "Panel", self, w, h)
end

function PANEL:PostPaint(w, h)
	if not self:IsEnabled() then
		graphics.setColor(color(0, 0, 0, 100))
		graphics.rectangle("fill", 0, 0, w, h)
	end
end

function PANEL:OnQuertyTooltip()
	if self.m_strTooltipTitle and self.m_strTooltipBody then
		gui.setTooltip(self.m_strTooltipTitle, self.m_strTooltipBody)
		return true
	end
end
