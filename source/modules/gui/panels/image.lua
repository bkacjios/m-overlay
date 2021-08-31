local PANEL = class.create("Image", "Panel")

function PANEL:Image()
	self:super()
	self:SetDrawPanel(false)
end

local CACHE = {}

function PANEL:SetImage(file)
	if not CACHE[file] then
		CACHE[file] = graphics.newImage(file)
	end
	self.m_pImage = CACHE[file]
end

function PANEL:Paint(w, h)
	if not self.m_pImage then return end
	graphics.draw(self.m_pImage, 0, 0, 0, w / self.m_pImage:getWidth(), h / self.m_pImage:getHeight())
end

function PANEL:SizeToContents()
	self:SetSize(self.m_pImage:getDimensions())
end