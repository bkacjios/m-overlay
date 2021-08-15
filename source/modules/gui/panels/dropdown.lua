local PANEL = class.create("DropdownSelect", "Panel")

function PANEL:DropdownSelect()
	self:super() -- Initialize our baseclass
end

local PANEL = class.create("Dropdown", "Label")

function PANEL:Dropdown()
	self:super() -- Initialize our baseclass

	self.m_tOptions = {}
	self.m_iSelection = 1
	self.m_bFocusable = true
end

--[[function PANEL:Paint(w, h)
	gui.skinHook("Paint", "Dropdown", self, w, h)
end]]

function PANEL:AddOption(str, default)
	table.insert(self.m_tOptions, str)
	if default then
		self.m_iSelection = #self.m_tOptions
		self:UpdateSelection()
	end
end

function PANEL:SelectOption(num)
	self.m_iSelection = num
	self:UpdateSelection()
end

function PANEL:OnSelectOption(num)
	-- Override
end

function PANEL:OpenDropdown()

end

function PANEL:OnMousePressed(x, y, but)
	if but ~= 1 then return end
	self:OpenDropdown()
end

function PANEL:UpdateSelection()
	self:SetText(self.m_tOptions[self.m_iSelection])
end

function PANEL:OnMouseWheeled(x, y)
	if y > 0 then
		self.m_iSelection = math.max(1, self.m_iSelection - 1)
	else
		self.m_iSelection = math.min(#self.m_tOptions, self.m_iSelection + 1)
	end
	self:OnSelectOption(self.m_iSelection)
	self:UpdateSelection()
end
