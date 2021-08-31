local PANEL = class.create("CheckBox", "Button")

PANEL:ACCESSOR("Toggled", "m_bToggled", false)

function PANEL:CheckBox()
	-- Initialize our baseclass
	self:super()
	self:TextMargin(28, 0, 0, 0)
	self:SetTextAlignmentX("left")
end

function PANEL:SetToggled(b, force)
	if self.m_bToggled ~= b or force then
		self.m_bToggled = b
		self:OnToggle(b)
	end
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "CheckBox", self, w, h)
	self:PaintLabel(w, h)
end

function PANEL:OnClick()
	self:SetToggled(not self:GetToggled())
end

function PANEL:OnToggle(on)
	-- Override
end