function PANEL:Initialize()
	self:super()

	self:SetBGColor(color_blank)
	self:SetFocusable(false)
	
	self.m_pFont = graphics.getFont()

	self:MakeAccessor("Text", "m_sText", "Label")
	self:MakeAccessor("TextColor", "m_cTextColor", color_black)

	self:MakeAccessor("Wrapped", "m_bWrapped", false)
	self:MakeAccessor("TextAlignment", "m_sAlignment", "center")
end

function PANEL:SetFont(...)
	self.m_pFont = graphics.newFont(...)
end

local floor = math.floor

function PANEL:Paint(w, h)
	self:super("Paint", w, h)

	graphics.setColor(unpackcolor(self.m_cTextColor))
	graphics.setFont(self.m_pFont)

	local tw,th = self.m_pFont:getWidth(self.m_sText), self.m_pFont:getHeight()
	if self.m_bWrapped then
		graphics.printf(self.m_sText, 0, 0, self:GetWide(), self.m_sAlignment)
	else
		-- Set alignment for non-wrapped text
		if self.m_sAlignment == "center" then
			graphics.print(self.m_sText, floor(w/2 - (tw/2)), floor(h/2 - (th/2)))
		elseif self.m_sAlignment == "right" then
			graphics.print(self.m_sText, floor(-tw/2), floor(h/2 - (th/2)))
		else -- Assume left
			graphics.print(self.m_sText, 0, floor(h/2 - (th/2)))
		end
	end
end

function PANEL:SizeToContents()
	
end

gui.register("Label", PANEL, "Panel")