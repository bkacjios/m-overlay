local PANEL = class.create("ImageURL", "Image")

function PANEL:ImageURL()
	self:super()
end

function PANEL:SetURL(url)
	local raw = http.request(url)
	if not raw then return end
	local file = love.filesystem.newFileData(raw, url, "file")
	local data = love.image.newImageData(file)
	self:SetImage(data)
end
