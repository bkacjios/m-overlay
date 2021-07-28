function PANEL:Initialize()
	self:super()
	self:SetFocusable(true)

	self.m_pPickLine = graphics.newImage("textures/colorring.png")
	self.m_pPickImage = graphics.newImage("textures/colorpick.png")

	self.m_bGrabbed = false

	self.m_vPickPos = {
		x = 1,
		y = 0
	}

	self:CreateCanvas()

	self.m_pData = love.image.newImageData(2, 2)
	self.m_pData:setPixel(0, 0, 1, 1, 1, 1) -- Top left		= White
	self.m_pData:setPixel(1, 0, 1, 0, 0, 1) -- Top Right	= Red -- This is set in PANEL:SetColor
	self.m_pData:setPixel(0, 1, 0, 0, 0, 1) -- Bottom left 	= Black
	self.m_pData:setPixel(1, 1, 0, 0, 0, 1) -- Bottom Right	= Black
	self.m_pImage = graphics.newImage(self.m_pData) -- Create a new image from our image data

	self:SetColor(color(255, 0, 0)) -- Set a default color so the image/imagedata is created

	self:DrawGradient()
end

function PANEL:CreateCanvas()
	self.m_pCanvas = love.graphics.newCanvas(self:GetSize()) -- Create a new canvas to fix the panel size
end

function PANEL:PerformLayout()
	self:CreateCanvas()
	self:DrawGradient()
end

function PANEL:DrawGradient()
	local w, h = self:GetSize()

	graphics.setCanvas(self.m_pCanvas)
		graphics.clear() -- Clear whatever was drawn previously
		graphics.easyDraw(self.m_pImage, -w/2.5, -h/2.5, 0, w*1.8, h*1.8) -- Draw our gradient image
	graphics.setCanvas()

	self.m_pCanvasData  = self.m_pCanvas:newImageData()
end

function PANEL:UpdateShade()
	self.m_cShade = self:GetShadeAt(self:GetPixelPickPos())
	self:OnShadeChanged(self.m_cShade)
end

function PANEL:GetShade()
	return self.m_cShade
end

function PANEL:SetColor(c)
	self.m_cColor = c

	self.m_pData:setPixel(1, 0, c.r/255, c.g/255, c.b/255, c.a/255) -- Set the main color of our gradient picker
	self.m_pImage = graphics.newImage(self.m_pData) -- Create a new image from our image data

	self:DrawGradient() -- Draw our image to the canvas
	self:UpdateShade()
end

function PANEL:GetShadeAt(x, y)
	local r, g, b, a = self.m_pCanvasData:getPixel(x, y) -- Get the color of the pixel on the canvas
	return color(r * 255, g * 255, b * 255, a * 255)
end

function PANEL:GetColor()
	return self.m_cColor
end

function PANEL:PaintOverlay(w, h)
	local xpos, ypos = self:GetPickPos()
	graphics.setColor(self:GetShade())
	graphics.easyDraw(self.m_pPickImage, xpos - 16, ypos - 16, 0, 32, 32)
	graphics.setColor(255, 255, 255, 255)
	graphics.easyDraw(self.m_pPickLine, xpos - 16, ypos - 16, 0, 32, 32)
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
	graphics.easyDraw(self.m_pCanvas, 0, 0, 0, w, h)
end

function PANEL:SetPickPos(x, y)
	local w,h = self:GetSize()

	if x < 0 then x = 0 end
	if x > w then x = w end
	if y < 0 then y = 0 end
	if y > h then y = h end

	self.m_vPickPos.x = x/w
	self.m_vPickPos.y = y/h

	self:UpdateShade()
end

function PANEL:GetPickPos()
	local w,h = self:GetSize()
	local pos = self.m_vPickPos
	return pos.x*w, pos.y*h
end

function PANEL:GetPixelPickPos()
	local w,h = self:GetSize()
	local pos = self.m_vPickPos
	return pos.x*(w-1), pos.y*(h-1)
end

function PANEL:OnMousePressed(x, y, but)
	if not self:IsEnabled() or but ~= 1 then return end

	local xpos, ypos = self:GetPickPos()

	if x <= xpos + 8 and x >= xpos - 8 and y <= ypos + 8 and y >= ypos - 8 then
		self.m_bGrabbed = true
	else
		self:SetPickPos(x, y)
	end
	return true
end

function PANEL:OnMouseMoved(x, y, dx, dy, istouch)
	if self.m_bGrabbed then
		self:SetPickPos(x, y)
	end
end

function PANEL:OnMouseReleased(x, y, but)
	if not self:IsEnabled() or but ~= 1 then return end
	if self.m_bGrabbed then
		self.m_bGrabbed = false
	end
end

function PANEL:OnShadeChanged(shade)
	
end

gui.register("ColorShade", PANEL, "Panel")