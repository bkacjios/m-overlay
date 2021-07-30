ACCESSOR(PANEL, "Hue", "m_iHue", 0)

function PANEL:Initialize()
	self:super() -- Initialize our baseclass

	self:SetWidth(24)
	self:SetFocusable(true)

	self.m_pPickLine = graphics.newImage("textures/colorring.png")
	self.m_pPickImage = graphics.newImage("textures/colorpick.png")

	self.m_bGrabbed = false

	-- Create a hue color gradient of all colors
	-- red, yellow, green, teal, blue, purple, red
	self.m_pData = love.image.newImageData(1, 7)
	self.m_pData:setPixel(0, 0, 1, 0, 0, 1)		-- 1 		= Red
	self.m_pData:setPixel(0, 1, 1, 1, 0, 1)		-- 2 		= Yellow
	self.m_pData:setPixel(0, 2, 0, 1, 0, 1)		-- 2 		= Green
	self.m_pData:setPixel(0, 3, 0, 1, 1, 1)		-- 3 		= Teal
	self.m_pData:setPixel(0, 4, 0, 0, 1, 1)		-- 3 		= Blue
	self.m_pData:setPixel(0, 5, 1, 0, 1, 1)		-- 1 		= Purple
	self.m_pData:setPixel(0, 6, 1, 0, 0, 1)		-- 1 		= Red

	-- Create a image from our pixel data
	self.m_pImage = graphics.newImage(self.m_pData)
end

function PANEL:PerformLayout()
	self.m_pCanvas = love.graphics.newCanvas(self:GetSize()) -- Create a new canvas to fit the panel size
	self:DrawGradient() -- Redraw our gradient to the canvas
end

function PANEL:DrawGradient()
	local w, h = self:GetSize()

	graphics.setCanvas(self.m_pCanvas)
		graphics.clear() -- Clear whatever was drawn previously
		graphics.setColor(255, 255, 255, 255)
		graphics.easyDraw(self.m_pImage, 0, -h/10, 0, w, h*1.2) -- Draw our gradient image
	graphics.setCanvas()
end

function PANEL:SetHue(h)
	self.m_iHue = math.min(1, math.max(0, h))
	self:OnHueChanged(self.m_iHue)
end

function PANEL:GetColor()
	local hue = math.min(1, math.max(0, self.m_iHue))
	return HSV(hue)
end

function PANEL:PaintOverlay(w, h)
	local ypos = self.m_iHue*h

	graphics.setColor(self:GetColor())
	graphics.easyDraw(self.m_pPickImage, 0, ypos - w/2, 0, w, w)
	graphics.setColor(255, 255, 255, 255)
	graphics.easyDraw(self.m_pPickLine, 0, ypos - w/2, 0, w, w)
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
	graphics.setColor(255, 255, 255, 255)
	graphics.easyDraw(self.m_pCanvas, 0, 0, 0, w, h)
end

function PANEL:SetValueFromMouseY(y)
	local h = self:GetHeight()
	self:SetHue(y/h)
end

function PANEL:OnMousePressed(x, y, but)
	if not self:IsEnabled() or but ~= 1 then return end

	local w, h = self:GetSize()
	local ypos = self.m_iHue*h
	h = h / 2

	if y <= ypos + h and y >= ypos - h then
		self.m_bGrabbed = true
	else
		self:SetValueFromMouseY(y)
	end
	return true
end

function PANEL:OnMouseMoved(x, y, dx, dy, istouch)
	if self.m_bGrabbed then
		self:SetValueFromMouseY(y)
	end
end

function PANEL:OnMouseWheeled(x, y)
	if not self:IsEnabled() then return end
	self:SetHue(self.m_iHue - (y/360))
end

function PANEL:OnMouseReleased(x, y, but)
	if not self:IsEnabled() or but ~= 1 then return end
	if self.m_bGrabbed then
		self.m_bGrabbed = false
	end
end

function PANEL:OnHueChanged(h)
	
end

gui.register("ColorHue", PANEL, "Panel")