local PANEL = {}

function PANEL:SetURL(url)
	local raw = http.request(url)
	if not raw then return end
	local file = love.filesystem.newFileData(raw, "", "file")
	local data = love.image.newImageData(file)
	self:SetImage(data)
end

gui.register("ImageURL", PANEL, "Image")