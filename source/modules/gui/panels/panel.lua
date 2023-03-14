local PANEL = class.create("Panel", "BasePanel")

PANEL:ACCESSOR("Enabled", "m_bEnabled", true)
PANEL:ACCESSOR("BorderColor", "m_cBorderColor", color(165, 165, 165))
PANEL:ACCESSOR({"BGColor","BackgroundColor"}, "m_cBackgroundColor", color(200, 200, 200))
PANEL:ACCESSOR("TooltipTitle", "m_strTooltipTitle")
PANEL:ACCESSOR("TooltipBody", "m_strTooltipBody")
PANEL:ACCESSOR("TooltipParent", "m_pTooltipParent")
PANEL:ACCESSOR("DrawPanel", "m_bDrawPanel", true)

function PANEL:Panel()
	self:super() -- Initialize our baseclass
end

function PANEL:Skin()
	gui.skinHook("Init", "Panel", self)
end

function PANEL:PrePaint(w, h)
	if self.m_bDrawPanel then
		gui.skinHook("Paint", "Panel", self, w, h)
	end
end

function PANEL:Paint(w, h)
	-- Override
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
		gui.setTooltip(self.m_pTooltipParent or self, self.m_strTooltipTitle, self.m_strTooltipBody)
		return true
	end
end

function PANEL:IsPressed()
	return self.m_bPressed and self:IsHovered()
end

function PANEL:OnMousePressed(x, y, but)
	if not self.m_bEnabled or but ~= 1 then return end
	self.m_bPressed = true
	return true
end

function PANEL:OnMouseReleased(x, y, but)
	if not self.m_bEnabled or but ~= 1 then return end
	if self.m_bPressed then
		self.m_bPressed = false
		if self:IsHovered() then
			self:OnClick()
			return true
		end
	end
end

function PANEL:OnClick()
	-- Override
end