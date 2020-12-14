function PANEL:Initialize()
	self:super()

	self:SetBGColor(color_blank)
	self:SetBorderColor(color_blank)
	self:SetFocusable(false)
	
	self.m_pFont = graphics.newFont("fonts/melee.otf", 12)

	self:MakeAccessor("Text", "m_sText", "Label")
	self:MakeAccessor("TextColor", "m_cTextColor", color_black)
	self:MakeAccessor("FontFile", "m_sFontFile")
	self:MakeAccessor("FontSize", "m_iFontSize")
	self:MakeAccessor("FontHint", "m_iFontHint")
	self:MakeAccessor("ShadowDistance", "m_iShadowDistance", 1)
	self:MakeAccessor("ShadowColor", "m_cShadowColor", color_lightgrey)
	self:MakeAccessor("OutlineThickness", "m_iOutlineThickness")
	self:MakeAccessor("OutlineColor", "m_cOutlineColor", color_black)

	self:MakeAccessor("Wrapped", "m_bWrapped", false)
	self:MakeAccessor("TextAlignment", "m_sAlignment", "left")
end

function PANEL:Think(dt)
	if not self.m_pFont and self.m_sFontFile then
		self.m_pFont = graphics.newFont(self.m_sFontFile, self.m_iFontSize, self.m_iFontHint)
	end
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

	graphics.setColor(unpackcolor(self.m_cTextColor))
	graphics.setFont(self.m_pFont)

	local tw,th = self.m_pFont:getWidth(self.m_sText), self.m_pFont:getAscent() - self.m_pFont:getDescent() 
	if self.m_bWrapped then
		graphics.printf(self.m_sText, 0, 0, self:GetWidth(), self.m_sAlignment)
	else
		--print(self.m_pFont:getHeight(), self.m_pFont:getLineHeight(), self.m_pFont:getDescent(), self.m_pFont:getAscent(), self.m_pFont:getBaseline())

		local x, y = 0, 0

		-- Set alignment for non-wrapped text
		if self.m_sAlignment == "center" then
			x, y = floor(w/2 - (tw/2)), floor(h/2 - (th/2))
		elseif self.m_sAlignment == "right" then
			x, y = w - tw, floor(h/2 - (th/2))
		else -- Assume left
			x, y = 0, floor(h/2 - (th/2))
		end

		local ol = tonumber(self.m_iOutlineThickness)

		if ol and ol > 0 then
			graphics.setColor(unpackcolor(self.m_cOutlineColor))
			graphics.textOutline(self.m_sText, ol, x, y)
		end

		local sd = tonumber(self.m_iShadowDistance)

		if sd and sd > 0 then
			graphics.setColor(unpackcolor(self.m_cShadowColor))
			graphics.print(self.m_sText, x + sd, y + sd)
		end

		graphics.setColor(unpackcolor(self.m_cTextColor))
		graphics.print(self.m_sText, x, y)
	end
end

function PANEL:SizeToText()
	self:SetSize(self.m_pFont:getWidth(self.m_sText), self.m_pFont:getAscent() - self.m_pFont:getDescent() )
end

function PANEL:WidthToText()
	self:SetWidth(self.m_pFont:getWidth(self.m_sText))
end

gui.register("Label", PANEL, "Panel")