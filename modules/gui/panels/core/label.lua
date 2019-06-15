local PANEL = {}

function PANEL:Initialize()
	self:super()
	
	self.m_sText = "Label"
	self.m_cTextColor = Color(0, 0, 0)
	self.m_pFont = love.graphics.newFont("resource/fonts/VeraMono.ttf", 12)
	self.m_bWrapped = false
	self.m_bFocusable = false
	self.m_sAlignment = "center"
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

function PANEL:Paint(w, h)
	love.graphics.setColor(unpackcolor(self.m_cTextColor))
	love.graphics.setFont(self.m_pFont)
	local tw,th = self.m_pFont:getWidth(self.m_sText), self.m_pFont:getHeight()
	if self.m_bWrapped then
		love.graphics.printf(self.m_sText, 0, 0, self:GetWide(), self.m_sAlignment)
	else
		-- Set alignment for non-wrapped text
		if self.m_sAlignment == "center" then
			love.graphics.print(self.m_sText, w/2 - (tw/2), h/2 - (th/2))
		elseif self.m_sAlignment == "right" then
			love.graphics.print(self.m_sText, -tw/2, h/2 - (th/2))
		else -- Assume left
			love.graphics.print(self.m_sText, 0, h/2 - (th/2))
		end
	end
end

function PANEL:SizeToContents()
	
end

gui.register("Label", PANEL, "Panel")