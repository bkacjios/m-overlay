local PANEL = class.create("Button", "Label")

PANEL:ACCESSOR("DrawLabel", "m_bDrawLabel", true)
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

function PANEL:Paint(w, h)
	if self.m_bDrawButton then
		gui.skinHook("Paint", "Button", self, w, h)
	end
	if self.m_bDrawLabel then
		self:super("Paint", w, h)
	end
end

function PANEL:PaintOverlay(w, h)
	gui.skinHook("PaintOverlay", "Button", self, w, h)
end