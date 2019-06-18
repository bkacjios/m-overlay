local PANEL = {}

function PANEL:Initialize()
	self:super()
	self:DockPadding(0,0,0,0)

	self.m_tOptions = {}
	self.m_iSelection = 1
	self.m_bFocusable = true

	self.m_pButLeft = self:Add("Button")
	self.m_pButLeft:SetLabelEnabled(false)
	self.m_pButLeft:Dock(DOCK_LEFT)
	self.m_pButLeft:SetWide(20)
	function self.m_pButLeft:OnClick()
		self:GetParent():SelectLeft()
	end

	self.m_pButRight = self:Add("Button")
	self.m_pButRight:SetLabelEnabled(false)
	self.m_pButRight:Dock(DOCK_RIGHT)
	self.m_pButRight:SetWide(20)
	function self.m_pButRight:OnClick()
		self:GetParent():SelectRight()
	end
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "FocusPanel", self, w, h)
	self:super("Paint", w, h) -- Paint our label
end

function PANEL:AddOption(str, default)
	table.insert(self.m_tOptions, str)
	if default then
		self:SelectOption(#self.m_tOptions)
	end
	self:UpdateSelection()
end

function PANEL:SelectOption(num)
	if self.m_iSelection == num then return end
	self.m_iSelection = num
	self:UpdateSelection()
	self:OnSelectOption(self.m_iSelection)
end

function PANEL:OnSelectOption(num)
	-- Override
end

function PANEL:OnMousePressed(x, y, but)
end

function PANEL:UpdateSelection()
	self:SetText(self.m_tOptions[self.m_iSelection])
	self.m_pButLeft:SetEnabled(self.m_iSelection > 1)
	self.m_pButRight:SetEnabled(self.m_iSelection < #self.m_tOptions)
end

function PANEL:SelectLeft()
	self:SelectOption(math.max(1, self.m_iSelection - 1))
end

function PANEL:SelectRight()
	self:SelectOption(math.min(#self.m_tOptions, self.m_iSelection + 1))
end

function PANEL:OnMouseWheeled(x, y)
	if not self:HasFocus() then return end
	if y > 0 then
		self:SelectLeft()
	else
		self:SelectRight()
	end
	return true
end

gui.register("HorizontalSelect", PANEL, "Label")