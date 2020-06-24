function PANEL:Initialize()
	self:super()

	self:MakeAccessor("Toggled", "m_bToggled", false)

	self.m_pLabel = self:Add("Label")
	self.m_pLabel:DockMargin(32, 0, 0, 0)
	self.m_pLabel:Dock(DOCK_FILL)
	self.m_pLabel:SetText("Checkbox")

	self:SetFocusable(true)

	--gui.skinHook("Init", "Checkbox", self)
end

function PANEL:SetToggle(b)
	if self.m_bToggled ~= b then
		self.m_bToggled = b
		self:OnToggle(b)
	end
end

function PANEL:SetText(str)
	self.m_pLabel:SetText(str)
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
	gui.skinHook("Paint", "Checkbox", self, w, h)
end

function PANEL:OnMousePressed(x, y, but)
	if not self:IsEnabled() or but ~= 1 then return end
	self:SetToggled(not self:GetToggled())
	self:OnToggle(self:GetToggled())
	return true
end

function PANEL:OnMouseReleased(x, y, but)
	if not self:IsEnabled() or but ~= 1 then return end
	self:OnClick()
end

function PANEL:OnToggle(on)
	-- Override
end

function PANEL:OnClick()
	-- Override
end

gui.register("Checkbox", PANEL, "Panel")