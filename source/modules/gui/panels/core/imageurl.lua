local PANEL = {}

function PANEL:SetURL(url)
	local raw = http.request(url)
	if not raw then return end
	local file = love.filesystem.newFileData(raw, "", "file")
	local data = love.image.newImageData(file)
	self.m_pImage = love.graphics.newImage(data)
end

function PANEL:Paint(w, h)
	if not self.m_pImage then return end
	love.graphics.draw(self.m_pImage, 0, 0, 0, w / self.m_pImage:getWidth(), h / self.m_pImage:getHeight())
end

gui.register("ImageURL", PANEL, "Base")