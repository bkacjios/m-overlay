function PANEL:Initialize()
	self:super()

	self:DockPadding(0,1,0,1)

	self.m_pLuaMemory = self:Add("Label")
	self.m_pLuaMemory:DockMargin(0,0,0,0)
	self.m_pLuaMemory:Dock(DOCK_RIGHT)
	self.m_pLuaMemory:SetWidth(128)
	self.m_pLuaMemory:SetTextAlignment("left")

	self.m_pGPUMemory = self:Add("Label")
	self.m_pGPUMemory:DockMargin(0,0,0,0)
	self.m_pGPUMemory:Dock(DOCK_RIGHT)
	self.m_pGPUMemory:SetWidth(128)
	self.m_pGPUMemory:SetTextAlignment("left")

	self.m_pCanvasSize = self:Add("Button")
	self.m_pCanvasSize:DockMargin(0,0,0,0)
	self.m_pCanvasSize:Dock(DOCK_LEFT)
	self.m_pCanvasSize:SetTextAlignment("left")
	self.m_pCanvasSize:SetBGColor(color_blank)
	self.m_pCanvasSize:SetBorderColor(color_blank)

	self.m_pCanvasSize.OnClick = function(this)
		local edit = gui.create("CanvasEditor")
		edit:Center()
		edit:MakePopup()
	end
end

function PANEL:Think(dt)
	self.m_pLuaMemory:SetText(string.format(" RAM: %s ", string.toSize(collectgarbage("count")*1024)))

	local stats = graphics.getStats()

	self.m_pGPUMemory:SetText(string.format(" GPU: %s ", string.toSize(stats.texturememory)))

	local canvas = self:GetParent():GetDisplay()

	self.m_pCanvasSize:SetText(string.format(" Canvas: %dx%d ", canvas:GetSize()))
	self.m_pCanvasSize:WidthToText()
end

gui.register("SceneInfoBar", PANEL, "Panel")