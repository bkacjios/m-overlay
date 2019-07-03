function PANEL:Initialize()
	self:super()

	self:DockPadding(0,0,0,0)

	self.m_tDropDownEntries = {}

	self:AddDropDownEntry("File")
	self:AddDropDownEntry("Edit")
end

function PANEL:AddDropDownEntry(name)
	local entry = self:Add("Button")
	entry:SetText(name)
	entry:SetBGColor(color_blank)
	entry:SetBorderColor(color_blank)
	entry:DockMargin(0,0,0,0)
	entry:Dock(DOCK_LEFT)

	entry.OnClick = function(this)
		self:OnEntryClicked(name, this)
	end

	self.m_tDropDownEntries[name] = entry
	return entry
end

function PANEL:OnEntryClicked(name, panel)
	print(name, panel)
end

gui.register("SceneTaskBar", PANEL, "Panel")