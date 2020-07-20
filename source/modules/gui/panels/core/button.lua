function PANEL:Initialize()
	self:super()

	self:SetFocusable(true)

	self:MakeAccessor("DrawLabel", "m_bDrawLabel", true)
	self:MakeAccessor("Enabled", "m_bEnabled", true)

	self:MakeAccessor("PressedColor", "m_cPressedColor")
	self:MakeAccessor("HoveredColor", "m_cHoveredColor")

	self:SetTextAlignment("center")
	self:SetText("Button")

	gui.skinHook("Init", "Button", self)
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "Button", self, w, h)
	if self.m_bDrawLabel then
		self:super("Paint", w, h)
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
	self.m_bPressed = false
	self:OnClick()
end

function PANEL:OnClick()
	-- Override
end

gui.register("Button", PANEL, "Label")