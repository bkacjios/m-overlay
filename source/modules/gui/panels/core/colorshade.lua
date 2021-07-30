ACCESSOR(PANEL, "Hue", "m_iHue", 0)
ACCESSOR(PANEL, "Shade", "m_cShade", color(255, 255, 255))
ACCESSOR(PANEL, "Saturation", "m_iSaturation", 1)
ACCESSOR(PANEL, "Value", "m_iValue", 0)

function PANEL:Initialize()
	self:super()
	self:SetFocusable(true)

	self.m_pPickLine = graphics.newImage("textures/colorring.png")
	self.m_pPickImage = graphics.newImage("textures/colorpick.png")
	self.m_pGradient = graphics.newImage("textures/gradient.png")

	self.m_bGrabbed = false

	self:PerformLayout()
end

function PANEL:CreateCanvas()
	self.m_pCanvas = love.graphics.newCanvas(self:GetSize()) -- Create a new canvas to fix the panel size
end

function PANEL:PerformLayout()
	self:CreateCanvas() -- Create a new canvas on resize
	self:DrawGradient() -- Redraw our palette
	self:UpdateShade() -- Recheck our color value
end

function PANEL:DrawGradient()
	local w, h = self:GetSize()

	local color = HSV(self.m_iHue)

	graphics.setCanvas(self.m_pCanvas)
		graphics.clear() -- Clear whatever was drawn previously
		graphics.setColor(color)
		graphics.easyDraw(self.m_pGradient, 0, 0, 0, w, h)
		graphics.setColor(0, 0, 0, 255)
		graphics.easyDraw(self.m_pGradient, 0, 0, math.rad(90), w, h, 0, 1)
	graphics.setCanvas()

	self.m_pCanvasData  = self.m_pCanvas:newImageData()
end

function PANEL:UpdateShade()
	self.m_cShade = HSV(self.m_iHue, self.m_iSaturation, self.m_iValue)
	self:OnShadeChanged(self.m_cShade)
end

function PANEL:SetColor(c)
	local hue, saturation, value = ColorToHSV(c)
	self.m_iHue = hue
	self.m_iSaturation = saturation
	self.m_iValue = value
	self:DrawGradient() -- Draw our image to the canvas
	self:UpdateShade()
end

function PANEL:SetHue(hue)
	self.m_iHue = hue
	self:DrawGradient()
	self:UpdateShade()
end

function PANEL:SetSaturation(saturation)
	self.m_iSaturation = saturation
	self:UpdateShade()
end

function PANEL:SetValue(value)
	self.m_iValue = value
	self:UpdateShade()
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
	graphics.setColor(255, 255, 255, 255)
	graphics.easyDraw(self.m_pCanvas, 0, 0, 0, w, h)
end

function PANEL:SetPickPos(x, y)
	local w,h = self:GetSize()

	if x < 0 then x = 0 end
	if x > w then x = w end
	if y < 0 then y = 0 end
	if y > h then y = h end

	self.m_iSaturation = x/w
	self.m_iValue = 1-(y/h)

	self:UpdateShade()
end

function PANEL:GetPickPos()
	local w,h = self:GetSize()
	return self.m_iSaturation*w, (1-self.m_iValue)*h
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