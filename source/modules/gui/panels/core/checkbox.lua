function PANEL:Initialize()
	self:super()

	self:MakeAccessor("Toggled", "m_bToggled", false)
	self:MakeAccessor("Enabled", "m_bEnabled", true)

	self.m_pLabel = self:Add("Label")
	self.m_pLabel:DockMargin(32, 0, 0, 0)
	self.m_pLabel:Dock(DOCK_FILL)
	self.m_pLabel:SetText("Checkbox")

	self:SetFocusable(true)

	--gui.skinHook("Init", "Checkbox", self)
end

function PANEL:SetText(str)
	self.m_pLabel:SetText(str)
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
	gui.skinHook("Paint", "Checkbox", self, w, h)
end

function PANEL:OnMousePressed(x, y, but)
	if not self.m_bEnabled or but ~= 1 then return end
	self:SetToggled(not self:GetToggled())
	self:OnToggle()
	return true
end

function PANEL:OnMouseReleased(x, y, but)
	if not self.m_bEnabled or but ~= 1 then return end
	self:OnClick()
end

function PANEL:OnToggle()
	-- Override
end

function PANEL:OnClick()
	-- Override
end

gui.register("Checkbox", PANEL, "Panel")