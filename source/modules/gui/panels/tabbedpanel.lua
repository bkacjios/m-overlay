local PANEL = class.create("Tab", "Button")

PANEL:ACCESSOR("Panel", "m_pPanel", nil)

function PANEL:Tab()
	self:super()
	self:TextMargin(28, 0, 0, 0)
	self:SetTextAlignment("left")

	self:SetBackgroundColor(color_clear)
end

function PANEL:OnClick()
	if self.m_pPanel then
		self.m_pPanel:GetParent():SetActivePanel(self.m_pPanel)
	end
end

function PANEL:SetImage(file)
	if not file then return end
	self.m_pImage = graphics.newImage(file)
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)

	if not self.m_pImage then return end
	graphics.setColor(color_white)
	graphics.easyDraw(self.m_pImage, 4, 4, 0, 16, 16)
end

function PANEL:PaintOverlay(w, h)
	gui.skinHook("PaintOverlay", "Button", self, w, h)
end

local PANEL = class.create("TabbedPanel", "Panel")

function PANEL:TabbedPanel()
	self:super()
	self:DockPadding(0,0,0,0)
	self.m_pTabBar = self:Add("Panel")
	self.m_pTabBar:Dock(DOCK_TOP)
	self.m_pTabBar:DockPadding(0, 0, 0, 0)
	self.m_pTabBar:DockMargin(4, 4, 4, 2)
	self.m_pTabBar:SetBorderColor(color_clear)
	self.m_pTabBar:SetBackgroundColor(color_clear)

	self.m_pActivePanel = nil
end

function PANEL:SetActivePanel(panel)
	if self.m_pActivePanel then
		self.m_pActivePanel:SetVisible(false)
	end
	panel:SetVisible(true)
	self.m_pActivePanel = panel
end

function PANEL:AddTab(name, icon, active)
	local panel = self:Add("Panel")
	panel:Dock(DOCK_FILL)
	panel:DockMargin(0, 0, 0, 0)
	panel:SetVisible(false)

	local tab = self.m_pTabBar:Add("Tab")
	tab:DockMargin(0, 0, 0, 0)
	tab:Dock(DOCK_LEFT)
	tab:SetText(name)
	tab:SetPanel(panel)
	tab:SetImage(icon)
	tab:SetWidth(82)

	if active then
		self:SetActivePanel(panel)
	end

	return panel
end