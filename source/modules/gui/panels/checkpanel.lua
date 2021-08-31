local PANEL = class.create("CheckPanel", "Label")

PANEL:ACCESSOR("Value", "m_iValue", 0)

function PANEL:CheckPanel()
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

function PANEL:AddOption(id, label, toggled)
	local option = self:Add("CheckBox")
	option:SetText(label)
	option:Dock(DOCK_TOP)
	option:SetToggled(toggled)
	self.OPTIONS[id] = option
	return option
end

function PANEL:PerformLayout()
	self:SizeToChildren(false, true)
end

function PANEL:SetValue(value)
	if self.m_iValue ~= value then
		self.m_iValue = value
		for id, option in pairs(self.OPTIONS) do
			option:SetToggled(bit.band(value, id) == id)
		end
	end
end