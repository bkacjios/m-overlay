local PANEL = class.create("RadioPanel", "Label")

PANEL:ACCESSOR("Option", "m_iOption")
PANEL:ACCESSOR("Horizontal", "m_bHorizontal", false)

function PANEL:RadioPanel()
	self:super() -- Initialize our baseclass
	self:SetFocusable(true)
	self:SetDrawPanel(true)
	self:SetBGColor(color(215, 215, 215))

	self:TextMargin(0, 4, 0, 0)
	self:SetTextAlignmentX("center")
	self:SetTextAlignmentY("top")
	self:SetTextColor(color_darkgrey)
	self:DockPadding(2, 18, 2, 2)

	self.OPTIONS = {}
end

function PANEL:AddOption(id, label, active)
	local option = self:Add("RadioBox")
	option:SetText(label)
	option:Dock(self.m_bHorizontal and DOCK_LEFT or DOCK_TOP)
	option.OnClick = function()
		self:SetValue(id)
	end

	self.OPTIONS[id] = option

	if active then
		self:SetValue(id)
	end

	return option
end

function PANEL:PerformLayout()
	self:SizeToChildren(self.m_bHorizontal, not self.m_bHorizontal)
end

function PANEL:SetValue(id)
	if self.m_iOption ~= id then
		for i, option in pairs(self.OPTIONS) do
			option:SetToggled(i == id)
		end
		self:OnSelectOption(id, self.m_iOption)
		self.m_iOption = id
	end
end

function PANEL:OnSelectOption(id, prev)
	-- OVERRIDE
end