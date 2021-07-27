function PANEL:Initialize()
	self:super()

	self.m_pData = love.image.newImageData(2, 2)
	self.m_pData:setPixel(0, 0, 1, 1, 1, 1) -- Top left		= White
	--self.m_pImage:setPixel(1, 0, 0, 1, 0, 1) -- Top Right		= Green -- This is set in PANEL:SetColor
	self.m_pData:setPixel(0, 1, 0, 0, 0, 1) -- Bottom left 	= Black
	self.m_pData:setPixel(1, 1, 0, 0, 0, 1) -- Bottom Right	= Black

	self:SetColor(color_green) -- Set a default color so the image/imagedata is created
end

function PANEL:PerformLayout()
	self.m_pCanvas = love.graphics.newCanvas(self:GetSize()) -- Create a new canvas to fix the panel size
	self:DrawGradient() -- Redraw our gradient to the canvas
end

function PANEL:DrawGradient()
	local w, h = self:GetSize()

	graphics.setCanvas(self.m_pCanvas)
		graphics.clear() -- Clear whatever was drawn previously
		graphics.easyDraw(self.m_pImage, -w/4, -h/4, 0, w*1.25, h*1.75) -- Draw our gradient image
	graphics.setCanvas()
end

function PANEL:SetColor(c)
	self.m_cColor = c
	self.m_pData:setPixel(1, 0, c.r/255, c.g/255, c.b/255, c.a/255) -- Set the main color of our gradient picker
	self.m_pImage = graphics.newImage(self.m_pData) -- Create a new image from our image data
	self:DrawGradient() -- Draw our image to the canvas 
end

function PANEL:GetColor(x, y)
	local data = self.m_pCanvas:newImageData()
	local r, g, b, a = data:getPixel(x, y) -- Get the color of the pixel on the canvas
	return color(r * 255, g * 255, b * 255, a * 255)
end

function PANEL:GetColor()
	return self.m_cColor
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)

	graphics.easyDraw(self.m_pCanvas, 0, 0, 0, w, h)
end

gui.register("ColorGradient", PANEL, "Panel")