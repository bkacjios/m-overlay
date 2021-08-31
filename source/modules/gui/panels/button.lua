local PANEL = class.create("Button", "Label")

PANEL:ACCESSOR("PressedColor", "m_cPressedColor")
PANEL:ACCESSOR("HoveredColor", "m_cHoveredColor")
PANEL:ACCESSOR("DrawButton", "m_bDrawButton", true)

function PANEL:Button()
	-- Initialize our baseclass
	self:super()

	self:SetFocusable(true)

	self:SetTextAlignmentX("center")
	self:SetText("Button")

	gui.skinHook("Init", "Button", self)
end

function PANEL:PrePaint(w, h)
	if self.m_bDrawButton then
		gui.skinHook("Paint", "Button", self, w, h)
	end
end

function PANEL:Paint(w, h)
	self:PaintLabel(w, h)
end

function PANEL:PaintOverlay(w, h)
	gui.skinHook("PaintOverlay", "Button", self, w, h)
end