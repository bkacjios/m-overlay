function PANEL:Initialize()
	self:super()

	self.m_bFocusable = true
	self.m_bDrawLabel = true
	self.m_bEnabled = true
	self:SetText("Button")
	gui.skinHook("Init", "Button", self)
end

function PANEL:SetLabelEnabled(b)
	self.m_bDrawLabel = b
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "Button", self, w, h)
	if self.m_bDrawLabel then
		self:super("Paint", w, h)
	end
end

function PANEL:SetEnabled(b)
	self.m_bEnabled = b
end

function PANEL:IsEnabled()
	return self.m_bEnabled
end

function PANEL:GetEnabled()
	return self.m_bEnabled
end

function PANEL:SetPressedColor(c)
	self.m_cPressedColor = c
end

function PANEL:GetPressedColor()
	return self.m_cPressedColor
end

function PANEL:SetHoveredColor(c)
	self.m_cHoveredColor = c
end

function PANEL:GetHoveredColor()
	return self.m_cHoveredColor
end

function PANEL:IsPressed()
	return self.m_bPressed
end

function PANEL:OnMousePressed(x, y, but)
	if but ~= 1 then return end
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