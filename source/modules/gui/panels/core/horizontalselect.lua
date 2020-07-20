local PANEL = {}

function PANEL:Initialize()
	self:super()
	self:DockPadding(0,0,0,0)

	self:SetBGColor(color_blank)
	self:SetBorderColor(color_blank)

	self:SetTextAlignment("center")

	self.m_tOptions = {}
	self.m_iSelection = 1
	self.m_bFocusable = true

	self.m_pButLeft = self:Add("Button")
	--self.m_pButLeft:SetDrawLabel(false)
	self.m_pButLeft:SetText("<")
	self.m_pButLeft:Dock(DOCK_LEFT)
	self.m_pButLeft:SetWidth(20)
	function self.m_pButLeft:OnClick()
		self:GetParent():SelectLeft()
	end

	self.m_pButRight = self:Add("Button")
	--self.m_pButRight:SetDrawLabel(false)
	self.m_pButRight:SetText(">")
	self.m_pButRight:Dock(DOCK_RIGHT)
	self.m_pButRight:SetWidth(20)
	function self.m_pButRight:OnClick()
		self:GetParent():SelectRight()
	end

	gui.skinHook("Init", "HorizontalSelect", self)
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
	return #self.m_tOptions
end

function PANEL:SelectOption(num, force)
	if self.m_iSelection == num and not force then return end
	self.m_iSelection = num
	self:UpdateSelection()
	self:OnSelectOption(self.m_iSelection)
end

function PANEL:GetSelection()
	return self.m_iSelection
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
	--if not self:HasFocus() then return end
	if y > 0 then
		self:SelectLeft()
	else
		self:SelectRight()
	end
	return true
end

gui.register("HorizontalSelect", PANEL, "Label")