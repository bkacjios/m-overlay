local PANEL = class.create("RadioPanel", "Label")

PANEL:ACCESSOR("Option", "m_iOption")

function PANEL:RadioPanel()
	self:super() -- Initialize our baseclass
	self:SetFocusable(true)
	self:SetDrawPanel(true)

	self:TextMargin(0, 2, 0, 0)
	self:SetTextAlignmentX("center")
	self:SetTextAlignmentY("top")
	self:SetTextColor(color_white)
	self:SetShadowDistance(1)
	self:SetShadowColor(color_black)
	self:DockPadding(2, 18, 2, 2)

	self.OPTIONS = {}
end

function PANEL:AddOption(id, label, active)
	local option = self:Add("Checkbox")
	option:SetRadio(true)
	option:SetText(label)
	option:Dock(DOCK_TOP)
	option:SetToggleable(false)
	option.OnClick = function()
		self:SetOption(id)
	end

	self.OPTIONS[id] = option

	if active then
		self:SetOption(id)
	end

	return option
end

function PANEL:PerformLayout()
	self:SizeToChildren(false, true)
end

function PANEL:SetOption(id)
	if self.m_iOption ~= id then
		self.m_iOption = id
		for i, option in pairs(self.OPTIONS) do
			self.OPTIONS[i]:SetToggled(false)
		end
		self.OPTIONS[id]:SetToggled(true)
		self:OnSelectOption(id)
	end
end

function PANEL:OnSelectOption(id)
	-- OVERRIDE
end