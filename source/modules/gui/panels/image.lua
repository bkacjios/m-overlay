local PANEL = {}

function PANEL:SetImage(file)
	self.m_pImage = love.graphics.newImage(file)
end

function PANEL:Paint(w, h)
	if not self.m_pImage then return end
	love.graphics.draw(self.m_pImage, 0, 0, 0, w / self.m_pImage:getWidth(), h / self.m_pImage:getHeight())
end

gui.register("Image", PANEL, "Base")