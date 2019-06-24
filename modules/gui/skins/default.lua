local SKIN = {}

SKIN.Background = color(240, 240, 240)

SKIN.PanelBorder = color(165, 165, 165)
SKIN.PanelFocused = color(0, 162, 232)

SKIN.FrameBorder = color(100, 100, 100)
SKIN.FrameControlBar = color(225, 225, 225)
SKIN.FrameFocusedControlBar = color(0, 162, 232)

SKIN.ButtonBackground = color(215, 215, 215)
SKIN.ButtonDisabled = color(100, 100, 100, 100)
SKIN.ButtonPressed = color(153, 217, 234)
SKIN.ButtonHover = color(220, 242, 248)

SKIN.ButtonClosePressed = color(243, 105, 113)
SKIN.ButtonCloseHover = color(248, 167, 171)

SKIN.TextEntryBackground = color(255, 255, 255)
SKIN.TextEntryFocused = color(0, 162, 232)

SKIN.ScrollBarGrip = color(205, 205, 205, 255)
SKIN.ScrollBarGripPressed = color(96, 96, 96, 255)
SKIN.ScrollBarGripHover = color(166, 166, 166, 255)

function SKIN:InitPanel(panel)
	panel:SetBGColor(self.Background)
	panel:SetBorderColor(self.PanelBorder)
end

function SKIN:PaintPanel(panel, w, h)
	graphics.setColor(unpackcolor(panel:GetBGColor()))
	graphics.rectangle("fill", 0, 0, w, h)

	graphics.setLineStyle("rough")
	graphics.setLineWidth(1)
	
	graphics.setColor(unpackcolor(panel:GetBorderColor()))
	graphics.innerRectangle(0, 0, w, h)
end

function SKIN:PaintFocusPanel(panel, w, h)
	graphics.setColor(unpackcolor(panel:GetBGColor()))
	graphics.rectangle("fill", 0, 0, w, h)

	graphics.setLineStyle("rough")
	graphics.setLineWidth(1)

	if panel:HasFocus() then
		graphics.setColor(unpackcolor(self.PanelFocused))
		graphics.innerRectangle(0, 0, w, h)
	else
		graphics.setColor(unpackcolor(panel:GetBorderColor()))
		graphics.innerRectangle(0, 0, w, h)
	end
end

function SKIN:PaintScrollBarButtonUp(panel, w, h)
	self:PaintButton(panel,w,h)
	graphics.setColor(150, 150, 150, 255)
	graphics.polygon('fill', 4, 12, 8, 4, 12, 12)
end

function SKIN:PaintScrollBarButtonDown(panel, w, h)
	self:PaintButton(panel,w,h)
	graphics.setColor(150, 150, 150, 255)
	graphics.polygon('fill', 4, 4, 12, 4, 8, 12)
end

function SKIN:PaintScrollBarGrip(panel, w, h)
	local color = self.ScrollBarGrip
	if panel:IsPressed() then
		color = self.ScrollBarGripPressed
	elseif panel:IsHovered() then
		color = self.ScrollBarGripHover
	end
	graphics.setColor(unpackcolor(color))
	graphics.rectangle("fill", 1, 0, w-2, h)
end

function SKIN:InitButton(panel)
	panel:SetPressedColor(self.ButtonPressed)
	panel:SetHoveredColor(self.ButtonHover)
end

function SKIN:InitExitButton(panel)
	panel:SetPressedColor(self.ButtonClosePressed)
	panel:SetHoveredColor(self.ButtonCloseHover)
end

function SKIN:PaintButton(panel, w, h)
	local color = self.ButtonBackground

	if not panel:IsEnabled() then
		color = self.ButtonDisabled
	elseif panel:IsPressed() then
		color = panel:GetPressedColor() or self.ButtonPressed
	elseif panel:IsHovered() then
		color = panel:GetHoveredColor() or self.ButtonHover
	end

	graphics.setColor(color)
	graphics.rectangle("fill", 0, 0, w, h)

	graphics.setLineStyle("rough")
	graphics.setLineWidth(1)
	
	--[[graphics.setColor(255, 255, 255, 255)
	graphics.innerRectangle(0, 1, w, h - 2)]]

	graphics.setColor(unpackcolor(panel:GetBorderColor()))
	graphics.innerRectangle(0, 0, w, h)
end

function SKIN:PaintFrame(panel, w, h)
	graphics.setColor(unpackcolor(self.Background))
	graphics.rectangle("fill", 0, 0, w, h)
	
	graphics.setColor(unpackcolor(panel:HasFocus(true) and self.FrameFocusedControlBar or self.FrameControlBar))
	graphics.rectangle("fill", 0, 0, w, 32)

	graphics.setLineStyle("rough")
	graphics.setLineWidth(1)
	
	--[[graphics.setColor(255, 255, 255, 255)
	graphics.innerRectangle(0, 1, w, h - 2)]]
	
	graphics.setColor(unpackcolor(panel.m_cBordercolor or self.FrameBorder))
	graphics.innerRectangle(0, 0, w, h)
end

function SKIN:PaintTextEntry(panel, w, h)
	graphics.setColor(unpackcolor(self.TextEntryBackground))
	graphics.rectangle("fill", 0, 0, w, h)

	graphics.setLineStyle("rough")
	graphics.setLineWidth(1)

	if panel:HasFocus() then
		graphics.setColor(unpackcolor(self.TextEntryFocused))
		graphics.innerRectangle(0, 0, w, h)
	else
		graphics.setColor(unpackcolor(panel:GetBorderColor()))
		graphics.innerRectangle(0, 0, w, h)
	end
end

gui.registerSkin("default", SKIN)