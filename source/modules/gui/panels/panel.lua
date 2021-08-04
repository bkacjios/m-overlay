local PANEL = {}

ACCESSOR(PANEL, "Enabled", "m_bEnabled", true)
ACCESSOR(PANEL, "BorderColor", "m_cBorderColor", color_blank)
ACCESSOR(PANEL, "BackgroundColor", "m_cBackgroundColor", color_blank)
ACCESSOR(PANEL, "BGColor", "m_cBackgroundColor", color_blank)
ACCESSOR(PANEL, "TooltipTitle", "m_strTooltipTitle", nil)
ACCESSOR(PANEL, "TooltipBody", "m_strTooltipBody", nil)

function PANEL:Initialize()
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

gui.register("Panel", PANEL, "Base")