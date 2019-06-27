function PANEL:Initialize()
	self:super()

	self:DockPadding(0,0,0,0)

	self.m_pLuaMemory = self:Add("Label")
	self.m_pLuaMemory:DockMargin(0,0,0,0)
	self.m_pLuaMemory:Dock(DOCK_RIGHT)
	self.m_pLuaMemory:SetWidth(100)
	self.m_pLuaMemory:SetTextAlignment("left")

	self.m_pGPUMemory = self:Add("Label")
	self.m_pGPUMemory:DockMargin(0,0,0,0)
	self.m_pGPUMemory:Dock(DOCK_RIGHT)
	self.m_pGPUMemory:SetWidth(100)
	self.m_pGPUMemory:SetTextAlignment("left")
end

function PANEL:Think(dt)
	self.m_pLuaMemory:SetText(string.format(" RAM %s ", string.toSize(collectgarbage("count")*1024)))

	local stats = graphics.getStats()

	self.m_pGPUMemory:SetText(string.format(" GPU %s ", string.toSize(stats.texturememory)))
end

gui.register("SceneInfoBar", PANEL, "Panel")