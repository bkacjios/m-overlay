local PANEL = class.create("Checkbox", "Button")

PANEL:ACCESSOR("Radio", "m_bRadio", false)
PANEL:ACCESSOR("Toggleable", "m_bToggleable", true)
PANEL:ACCESSOR("Toggled", "m_bToggled", false)

function PANEL:Checkbox()
	-- Initialize our baseclass
	self:super()
	self:TextMargin(28, 0, 0, 0)
	self:SetTextAlignment("left")
end

function PANEL:SetToggle(b, force)
	if self.m_bToggled ~= b or force then
		self.m_bToggled = b
		self:OnToggle(b)
	end
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
	if self.m_bRadio then
		gui.skinHook("Paint", "Radio", self, w, h)
	else
		gui.skinHook("Paint", "Checkbox", self, w, h)
	end
end

function PANEL:OnMousePressed(x, y, but)
	if not self.m_bEnabled or but ~= 1 then return end
	self.m_bPressed = true
	return true
end

function PANEL:OnMouseReleased(x, y, but)
	if not self.m_bEnabled or but ~= 1 then return end
	self.m_bPressed = false
	if self:IsHovered() then
		if self.m_bToggleable then
			self:SetToggled(not self:GetToggled())
			self:OnToggle(self:GetToggled())
		else
			self:OnClick()
		end
	end
end

function PANEL:OnToggle(on)
	-- Override
end

function PANEL:OnClick()
	-- Override
end
