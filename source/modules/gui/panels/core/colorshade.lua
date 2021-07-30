ACCESSOR(PANEL, "Hue", "m_iHue", 0)
ACCESSOR(PANEL, "Saturation", "m_iSaturation", 1)
ACCESSOR(PANEL, "Value", "m_iValue", 1)
ACCESSOR(PANEL, "Color", "m_cColor", color(255, 0, 0))
ACCESSOR(PANEL, "PickerSize", "m_iPickerSize", 32)

function PANEL:Initialize()
	self:super() -- Initialize our baseclass
	
	self:SetFocusable(true)

	self.m_pPickLine = graphics.newImage("textures/colorring.png")
	self.m_pPickImage = graphics.newImage("textures/colorpick.png")
	self.m_pGradient = graphics.newImage("textures/gradient.png")

	self.m_bGrabbed = false

	-- Force a layout update to create our canvas and draw the gradients
	self:PerformLayout()
end

function PANEL:CreateCanvas()
	self.m_pCanvas = love.graphics.newCanvas(self:GetSize()) -- Create a new canvas to fit the panel size
end

function PANEL:PerformLayout()
	self:CreateCanvas() -- Create a new canvas on resize
	self:DrawGradient() -- Redraw our palette
	self:UpdateColor() -- Recheck our color value
end

function PANEL:DrawGradient()
	-- This is NOT called every frame
	-- This is only called when the hue changes

	local w, h = self:GetSize()

	-- Get the primary color of our picker
	local color = HSV(self.m_iHue)

	graphics.setCanvas(self.m_pCanvas)
		graphics.clear() -- Clear whatever was drawn previously
		graphics.setColor(color)
		graphics.easyDraw(self.m_pGradient, 0, 0, 0, w, h)
		graphics.setColor(0, 0, 0, 255)
		graphics.easyDraw(self.m_pGradient, 0, 0, math.rad(90), w, h, 0, 1)
	graphics.setCanvas()
end

function PANEL:UpdateColor()
	-- Only call this function when updating hue, saturation or value
	self.m_cColor = HSV(self.m_iHue, self.m_iSaturation, self.m_iValue)
	self:OnColorChanged(self.m_cColor)
end

-- Sets the hue of our gradient and redraws it
-- Updates the saturation & value
function PANEL:SetColor(c)
	local hue, saturation, value = ColorToHSV(c)
	self.m_iHue = hue
	self.m_iSaturation = saturation
	self.m_iValue = value
	self:DrawGradient() -- Setting the hue requires a redraw
	self:UpdateColor() -- Recalculate color
end

function PANEL:SetHue(hue)
	self.m_iHue = hue
	self:DrawGradient() -- Setting the hue requires a redraw
	self:UpdateColor() -- Recalculate color
end

function PANEL:SetSaturation(saturation)
	self.m_iSaturation = saturation
	self:UpdateColor() -- Recalculate color
end

function PANEL:SetValue(value)
	self.m_iValue = value
	self:UpdateColor() -- Recalculate color
end

function PANEL:PaintOverlay(w, h)
	local xpos, ypos = self:GetPickPos()

	local psize = self.m_iPickerSize
	local hpsize = self.m_iPickerSize / 2

	-- Draw the color we picked
	graphics.setColor(self.m_cColor)
	graphics.easyDraw(self.m_pPickImage, xpos - hpsize, ypos - hpsize, 0, psize, psize)

	-- Draw a high-contrast outline
	graphics.setColor(255, 255, 255, 255)
	graphics.easyDraw(self.m_pPickLine, xpos - hpsize, ypos - hpsize, 0, psize, psize)
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
	-- Draw our color gradiant
	graphics.setColor(255, 255, 255, 255)
	graphics.easyDraw(self.m_pCanvas, 0, 0, 0, w, h)
end

function PANEL:SetPickPos(x, y)
	local w,h = self:GetSize()

	-- Keep x & y within the panel
	if x < 0 then x = 0 end
	if x > w then x = w end
	if y < 0 then y = 0 end
	if y > h then y = h end

	-- Calculate values based on position
	self.m_iSaturation = x/w
	self.m_iValue = 1-(y/h) -- invert, top = 1 and bottom = 0

	self:UpdateColor() -- Recalculate color
end

function PANEL:GetPickPos()
	local w,h = self:GetSize()
	-- Return picker position value on the panel based on color saturation and value
	-- Value is inverted
	return self.m_iSaturation*w, (1-self.m_iValue)*h
end

function PANEL:OnMousePressed(x, y, but)
	if not self:IsEnabled() or but ~= 1 then return end

	local xpos, ypos = self:GetPickPos()
	local hpsize = self.m_iPickerSize / 2

	if x <= xpos + hpsize and x >= xpos - hpsize and y <= ypos + hpsize and y >= ypos - hpsize then
		-- We clicked on the picker
		self.m_bGrabbed = true -- Mark as grabbed for moving
	else
		-- We just clicked somewhere, so set our position there
		self:SetPickPos(x, y)
	end
	return true
end

function PANEL:OnMouseMoved(x, y, dx, dy, istouch)
	if self.m_bGrabbed then
		-- If we grabbed the picker, update its position based on where the mouse moved
		self:SetPickPos(x, y)
	end
end

function PANEL:OnMouseReleased(x, y, but)
	if self.m_bGrabbed then
		-- If we are grabbed and released mouse, let it go
		self.m_bGrabbed = false
	end
end

function PANEL:OnColorChanged(shade)
	-- Override
end

gui.register("ColorShade", PANEL, "Panel")