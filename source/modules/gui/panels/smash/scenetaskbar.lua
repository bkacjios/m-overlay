function PANEL:Initialize()
	self:super()

	self:DockPadding(0,0,0,0)

	self.m_tEntries = {}

	self:AddEntry("File")
	self:AddEntry("Edit")
end

function PANEL:AddEntry(name)
	local entry = self:Add("Button")
	entry:SetText(name)
	entry:SetBGColor(color_blank)
	entry:SetBorderColor(color_blank)
	entry:DockMargin(0,0,0,0)
	entry:Dock(DOCK_LEFT)

	entry.OnClick = function(this)
		self:OnEntryClicked(name, this)
	end

	self.m_tEntries[name] = entry
	return entry
end

function PANEL:OnEntryClicked(name, panel)
	local menu = gui.create("ContextMenu")
	menu:SetPos(panel:LocalToWorld(0, panel:GetHeight()))

	if name == "File" then
		menu:AddEntry("New Layout", gui.newSceneLayout)
		menu:AddEntry("Open Layout", gui.openSceneLayout)
		menu:AddEntry("Save As...", gui.saveSceneLayout)
		menu:AddSeperator()
		menu:AddEntry("Exit", love.event.quit)
	elseif name == "Edit" then
		menu:AddEntry("New Panel", gui.addNewPanel)
		menu:AddEntry("Edit Panels", gui.editPanels)
	end
end

gui.register("SceneTaskBar", PANEL, "Panel")