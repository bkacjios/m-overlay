function PANEL:Initialize()
	self:super()

	self:DockPadding(0,0,0,0)

	self.m_tDropDownEntries = {}
end

function PANEL:AddDropDownEntry(name)
	local entry = self:Add("Button")
	entry:SetText(name)
	entry:SetBGColor(color_blank)
	entry:SetBorderColor(color_blank)
	entry:DockMargin(0,0,0,0)
	entry:Dock(DOCK_LEFT)

	self.m_tDropDownEntries[name] = entry
end

gui.register("SceneTaskBar", PANEL, "Panel")