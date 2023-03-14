local PANEL = class.create("Tab", "Button")

PANEL:ACCESSOR("Active", "m_bActive", false)
PANEL:ACCESSOR("ContentPanel", "m_pContentPanel")
PANEL:ACCESSOR("ActiveColor", "m_cActiveColor")

function PANEL:Tab()
	self:super()
	self:SetTextAlignmentX("left")
	self:TextMargin(28, 0, 0, 0)
end

function PANEL:OnClick()
	if self.m_pContentPanel then
		self.m_pContentPanel:GetParent():SetActivePanel(self.m_pContentPanel)
	end
end

function PANEL:SetImage(file)
	if not file then return end
	self.m_pImage = graphics.newImage(file)
end

function PANEL:PrePaint(w, h)
	gui.skinHook("Paint", "Tab", self, w, h)
end

function PANEL:Paint(w, h)
	if self.m_pImage then
		graphics.setColor(color_white)
		graphics.easyDraw(self.m_pImage, 4, 4, 0, 16, 16)
	end
	self:PaintLabel(w, h)
end

function PANEL:PaintOverlay(w, h)
	gui.skinHook("PaintOverlay", "Button", self, w, h)
end

local PANEL = class.create("TabContents", "Panel")

PANEL:ACCESSOR("Tab", "m_pTab")

function PANEL:TabContents()
	self:super()

	self:Dock(DOCK_FILL)
	self:DockMargin(0, 0, 0, 0)
	self:SetVisible(false)
end

local PANEL = class.create("TabbedPanel", "Panel")

function PANEL:TabbedPanel()
	self:super()
	self:SetDrawPanel(false)
	self:DockPadding(0, 0, 0, 0)

	-- Collection of all the tabs
	self.m_pTabBar = self:Add("Panel")
	self.m_pTabBar:Dock(DOCK_TOP)
	self.m_pTabBar:DockPadding(0, 0, 0, 0)
	self.m_pTabBar:DockMargin(0, 0, 0, 0)
	self.m_pTabBar:SetDrawPanel(false)

	self.m_pActivePanel = nil
end

function PANEL:SetActivePanel(panel)
	if self.m_pActivePanel then
		self.m_pActivePanel:SetVisible(false)
		self.m_pActivePanel:GetTab():SetActive(false)
	end
	panel:SetVisible(true)
	panel:GetTab():SetActive(true)
	self.m_pActivePanel = panel
end

function PANEL:AddTab(name, icon, active)
	local content = self:Add("TabContents")

	local tab = self.m_pTabBar:Add("Tab")
	tab:DockMargin(0, 0, 0, 0)
	tab:Dock(DOCK_LEFT)
	tab:SetText(name)
	tab:SetContentPanel(content)
	tab:SetImage(icon)
	tab:SetWidth(82)

	content:SetTab(tab)

	if active then
		self:SetActivePanel(content)
	end

	return content
end