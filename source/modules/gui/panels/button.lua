local PANEL = class.create("Button", "Label")

ACCESSOR(PANEL, "DrawLabel", "m_bDrawLabel", true)
ACCESSOR(PANEL, "DrawPanel", "m_bDrawPanel", true)
ACCESSOR(PANEL, "PressedColor", "m_cPressedColor")
ACCESSOR(PANEL, "HoveredColor", "m_cHoveredColor")

function PANEL:Button()
	-- Initialize our baseclass
	self:super()
	
	self:SetFocusable(true)

	self:SetTextAlignment("center")
	self:SetText("Button")

	gui.skinHook("Init", "Button", self)
end

function PANEL:Paint(w, h)
	if self.m_bDrawPanel then
		gui.skinHook("Paint", "Button", self, w, h)
	end
	if self.m_bDrawLabel then
		self:super("Paint", w, h)
	end
end

function PANEL:PaintOverlay(w, h)
	gui.skinHook("PaintOverlay", "Button", self, w, h)
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
	self.m_bPressed = false
	if self:IsHovered() then
		self:OnClick()
	end
end

function PANEL:OnClick()
	-- Override
end