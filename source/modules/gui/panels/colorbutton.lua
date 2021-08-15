local PANEL = class.create("ColorButton", "Button")

ACCESSOR(PANEL, "Color", "m_cColor", color_white)

function PANEL:ColorButton()
	-- Initialize our baseclass
	self:super()
	self:TextMargin(28, 0, 0, 0)
	self:SetTextAlignment("left")
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)

	graphics.setColor(self.m_cColor)
	graphics.rectangle("fill", 4, 4, h-8, h-8)
	graphics.setColor(self:GetBorderColor())
	graphics.rectangle("line", 4, 4, h-8, h-8)
end

function PANEL:PaintOverlay(w, h)
	gui.skinHook("PaintOverlay", "Button", self, w, h)
end