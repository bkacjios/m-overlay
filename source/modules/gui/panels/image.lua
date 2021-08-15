local PANEL = class.create("Image", "BasePanel")

function PANEL:Image()
	self:super()
end

function PANEL:SetImage(file)
	self.m_pImage = graphics.newImage(file)
end

function PANEL:Paint(w, h)
	if not self.m_pImage then return end
	graphics.draw(self.m_pImage, 0, 0, 0, w / self.m_pImage:getWidth(), h / self.m_pImage:getHeight())
end

function PANEL:SizeToContentes()
	self:SetSize(self.m_pImage:getDimensions())
end