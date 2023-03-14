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

function PANEL:Skin()
	self:super("Skin")
	gui.skinHook("Init", "SubPanel", self)
end

function PANEL:AddOption(id, label, toggled)
	local option = self:Add("CheckBox")
	option:SetText(label)
	option:Dock(DOCK_TOP)
	option:SetToggled(toggled)
	option.OnToggle = function()
		if self.m_iValue ~= self:GetValue() then
			self:OnValueChanged(self.m_iValue)
		end
	end

	self.OPTIONS[id] = option
	return option
end

function PANEL:PerformLayout()
	self:SizeToChildren(false, true)
end

function PANEL:GetValue()
	self.m_iValue = 0
	for id, option in pairs(self.OPTIONS) do
		if option:IsToggled() then
			self.m_iValue = bit.bor(self.m_iValue, id)
		end
	end
	return self.m_iValue
end

function PANEL:SetValue(value)
	if self.m_iValue ~= value then
		self.m_iValue = value
		for id, option in pairs(self.OPTIONS) do
			-- DON'T use SetToggled, since it would call OnValueChanged
			-- We call OnValueChanged manually to reduce calls
			option.m_bToggled = bit.band(value, id) == id
		end
		self:OnValueChanged(value) -- Manual call
	end
end

function PANEL:OnValueChanged(value)
	-- OVERRIDE
end