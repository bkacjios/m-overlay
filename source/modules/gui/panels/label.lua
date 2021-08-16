local PANEL = class.create("Label", "Panel")

PANEL:ACCESSOR("Text", "m_sText", "Label")
PANEL:ACCESSOR("TextColor", "m_cTextColor", color_black)
PANEL:ACCESSOR("FontFile", "m_sFontFile")
PANEL:ACCESSOR("FontSize", "m_iFontSize")
PANEL:ACCESSOR("FontHint", "m_iFontHint")
PANEL:ACCESSOR("ShadowDistance", "m_iShadowDistance", 1)
PANEL:ACCESSOR("ShadowColor", "m_cShadowColor", color_lightgrey)
PANEL:ACCESSOR("OutlineThickness", "m_iOutlineThickness")
PANEL:ACCESSOR("OutlineColor", "m_cOutlineColor", color_black)
PANEL:ACCESSOR("Wrapped", "m_bWrapped", false)
PANEL:ACCESSOR("TextAlignment", "m_sAlignment", "left")

function PANEL:Label()
	self:super() -- Initialize our baseclass

	self.m_tTextMargins = { left = 0, top = 0, right = 0, bottom = 0 }

	self:SetBGColor(color_blank)
	self:SetBorderColor(color_blank)
	self:SetFocusable(false)
	
	self.m_pFont = graphics.newFont("fonts/melee.otf", 12)

	self:SetLineHeight(0.55)

	self:SetText(self.m_sText)
end

function PANEL:TextMargin(left, top, right, bottom)
	self.m_tTextMargins.left = left
	self.m_tTextMargins.top = top
	self.m_tTextMargins.right = right
	self.m_tTextMargins.bottom = bottom
end

function PANEL:GetTextMargin()
	return self.m_tTextMargins
end

function PANEL:Think(dt)
	self:super("Think", dt)
	if not self.m_pFont and self.m_sFontFile then
		self.m_pFont = graphics.newFont(self.m_sFontFile, self.m_iFontSize, self.m_iFontHint)
	end
end

function PANEL:SetText(text)
	self.m_sText = text
	if self.m_bWrapped then
		self.m_iTextWidth, self.m_tTextWrap = self.m_pFont:getWrap(self.m_sText, self:GetWidth())
	else
		self.m_iTextWidth, self.m_tTextWrap = self.m_pFont:getWidth(self.m_sText), {self.m_sText}
	end
end

function PANEL:PerformLayout()
end

function PANEL:SetLineHeight(height)
	self.m_pFont:setLineHeight(height)
end

function PANEL:GetLineHeight()
	return self.m_pFont:getLineHeight()
end

function PANEL:SetFont(filename, size, hinting)
	self.m_pFont = graphics.newFont(filename, size, hinting)
	self.m_sFontFile = filename
	self.m_iFontSize = size
	self.m_iFontHint = hinting
end

local floor = math.floor

function PANEL:Paint(w, h)
	self:super("Paint", w, h)

	graphics.setColor(self.m_cTextColor)
	graphics.setFont(self.m_pFont)

	local x, y = self.m_tTextMargins.left, self.m_tTextMargins.top

	w = w - self.m_tTextMargins.right - self.m_tTextMargins.left
	h = h - self.m_tTextMargins.top - self.m_tTextMargins.bottom

	local tw,th = self.m_pFont:getWidth(self.m_sText), self.m_pFont:getAscent() - self.m_pFont:getDescent()

	if self.m_bWrapped then
		local sd = tonumber(self.m_iShadowDistance)

		if sd and sd > 0 then
			graphics.setColor(self.m_cShadowColor)
			graphics.printf(self.m_sText, x + sd, y + sd, self:GetWidth(), self.m_sAlignment)
		end

		graphics.setColor(self.m_cTextColor)
		graphics.printf(self.m_sText, x, y, self:GetWidth(), self.m_sAlignment)
	else
		--print(self.m_pFont:getHeight(), self.m_pFont:getLineHeight(), self.m_pFont:getDescent(), self.m_pFont:getAscent(), self.m_pFont:getBaseline())

		-- Set alignment for non-wrapped text
		if self.m_sAlignment == "center" then
			x, y = x + floor(w/2 - (tw/2)), y + floor(h/2 - (th/2))
		elseif self.m_sAlignment == "right" then
			x, y = x + w - tw, y + floor(h/2 - (th/2))
		else -- Assume left
			y = y + floor(h/2 - (th/2))
		end

		local ol = tonumber(self.m_iOutlineThickness)

		if ol and ol > 0 then
			graphics.setColor(self.m_cOutlineColor)
			graphics.textOutline(self.m_sText, ol, x, y)
		end

		local sd = tonumber(self.m_iShadowDistance)

		if sd and sd > 0 then
			graphics.setColor(self.m_cShadowColor)
			graphics.print(self.m_sText, x + sd, y + sd)
		end

		graphics.setColor(self.m_cTextColor)
		graphics.print(self.m_sText, x, y)
	end
end

function PANEL:SizeToText()
	self:SetSize(self.m_iTextWidth, self.m_pFont:getHeight() * self:GetLineHeight() * #self.m_tTextWrap)
end

function PANEL:WidthToText()
	self:SetWidth(self.m_pFont:getWidth(self.m_sText))
end

function PANEL:HeightToText()
	self:SetHeight(self.m_pFont:getHeight() * self:GetLineHeight() * #self.m_tTextWrap)
end
