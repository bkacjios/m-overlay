function PANEL:Initialize()
	self:super()
	
	self.m_sText = "Label"
	self.m_cTextColor = color(0, 0, 0)
	self.m_pFont = love.graphics.getFont()
	self.m_bWrapped = false
	self.m_bFocusable = false
	self.m_sAlignment = "center"
end

function PANEL:SetFont(...)
	self.m_pFont = love.graphics.newFont(...)
end

function PANEL:SetWrapped(b)
	self.m_bWrapped = b
end

function PANEL:SetTextColor(c)
	self.m_cTextColor = c
end

function PANEL:SetTextAlignment(s)
	self.m_sAlignment = s
end

function PANEL:SetText(s)
	self.m_sText = tostring(s)
end

function PANEL:GetText()
	return self.m_sText
end

local floor = math.floor

function PANEL:Paint(w, h)
	self:super("Paint", w, h)

	love.graphics.setColor(unpackcolor(self.m_cTextColor))
	love.graphics.setFont(self.m_pFont)
	local tw,th = self.m_pFont:getWidth(self.m_sText), self.m_pFont:getHeight()
	if self.m_bWrapped then
		love.graphics.printf(self.m_sText, 0, 0, self:GetWide(), self.m_sAlignment)
	else
		-- Set alignment for non-wrapped text
		if self.m_sAlignment == "center" then
			love.graphics.print(self.m_sText, floor(w/2 - (tw/2)), floor(h/2 - (th/2)))
		elseif self.m_sAlignment == "right" then
			love.graphics.print(self.m_sText, floor(-tw/2), floor(h/2 - (th/2)))
		else -- Assume left
			love.graphics.print(self.m_sText, 0, floor(h/2 - (th/2)))
		end
	end
end

function PANEL:SizeToContents()
	
end

gui.register("Label", PANEL, "Panel")