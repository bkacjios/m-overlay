local PANEL = {}

function PANEL:Initialize()	
	self:super()
	self:DockPadding(0,0,0,0)

	self.m_pCanvas = self:Add("Panel")	
	self.m_pCanvas:SetBGColor(color_blank)
	self.m_pCanvas:SetBorderColor(color_blank)
	
	-- Create the scroll bar
	self.m_pVBar = self:Add("ScrollBar")
	self.m_pVBar:DockMargin(-1,0,0,0)
	self.m_pVBar:Dock(DOCK_RIGHT)
end

function PANEL:AddItem(class)
	return self.m_pCanvas:Add(class)
end

function PANEL:OnChildAdded(child)
end

function PANEL:SizeToContents()
	self:SetSize(self.m_pCanvas:GetSize())
end

function PANEL:GetVBar()
	return self.m_pVBar
end

function PANEL:GetCanvas()
	return self.m_pCanvas
end

function PANEL:InnerWidth()
	return self:GetCanvas():GetWide()
end

function PANEL:Rebuild()
	self:GetCanvas():SizeToChildren(false, true)
	if self.m_bNoSizing and self:GetCanvas():GetTall() < self:GetTall() then
		self:GetCanvas():SetPos(0, (self:GetTall()-self:GetCanvas():GetTall()) * 0.5)
	end
end

function PANEL:OnMouseWheeled(x, y)
	return self.m_pVBar:OnMouseWheeled(x, y)
end

function PANEL:OnVScroll(iOffset)
	self.m_pCanvas:SetPos(0, iOffset)
end

function PANEL:ScrollToChild(panel)
	self:PerformLayout()
	
	local x, y = self.m_pCanvas:GetChildPosition(panel)
	local w, h = panel:GetSize()
	
	y = y + h * 0.5;
	y = y - self:GetTall() * 0.5;

	self.m_pVBar:AnimateTo(y, 0.5, 0, 0.5);
end

function PANEL:PerformLayout()
	local wide = self:GetWide()
	local ypos = 0
	local xpos = 0
	
	self:Rebuild()
	
	self.m_pVBar:SetUp(self:GetTall(), self.m_pCanvas:GetTall())
	ypos = self.m_pVBar:GetOffset()
		
	if self.m_pVBar.m_bEnabled then
		wide = wide - self.m_pVBar:GetWide()
		wide = wide - self.m_pVBar.m_tDockMargins.left - self.m_pVBar.m_tDockMargins.right
	end

	self.m_pCanvas:SetPos(0, ypos)
	self.m_pCanvas:SetWide(wide)
	
	self:Rebuild()
end

function PANEL:Clear()
	return self.m_pCanvas:Clear()
end

gui.register("ScrollPanel", PANEL, "Panel")