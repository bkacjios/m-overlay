local PANEL = {}

function PANEL:Initialize()
	self:super()
	self:SetWidth(128)

	self:SetFocusable(true)

	self.m_bGrabbed = false
	
	self.m_iMin = 0
	self.m_iMax = 100
	self.m_iValue = 0
	self.m_iSteps = 1
	self.m_iIncrements = 5
	self.m_iNotches = 4
end

function PANEL:Paint(w,h)
	gui.skinHook("Paint", "Slider", self, w, h)

	graphics.setColor(color(100, 100, 100))
	graphics.line(0, h/2, w, h/2)

	local x = 0
	local range = self.m_iMax - self.m_iMin

	local notches = (range/self.m_iIncrements)

	local gap = w/notches

	for i=1, notches-1 do
		x = 0 + gap * i
		graphics.line(x, 8, x, h - 8)
	end

	gap = w/self.m_iNotches

	for i=1, self.m_iNotches-1 do
		x = 0 + gap * i
		graphics.line(x, 4, x, h - 4)
	end

	local xpos = self.m_iValue/range*w

	graphics.setColor(color(0, 162, 232))
	graphics.rectangle("fill", xpos - 4, 4, 8, h - 8)
end

function PANEL:SetValue(i)
	self.m_iValue = math.min(self.m_iMax, math.max(self.m_iMin, i))
	self:OnValueChanged(self.m_iValue)
end

function PANEL:GetValue()
	return self.m_iValue
end

function PANEL:GetRange()
	return self.m_iMax - self.m_iMin
end

function PANEL:SetValueFromMouseX(x)
	local w = self:GetWidth()
	local range = self:GetRange()
	local numsteps = range / self.m_iSteps
	self:SetValue(math.floor(self.m_iMin + (x/w*numsteps) + 0.5))
end

function PANEL:OnMousePressed(x, y, but)
	if not self:IsEnabled() or but ~= 1 then return end

	local w = self:GetWidth()
	local range = self:GetRange()
	local xpos = self.m_iValue/range*w

	if x <= xpos + 4 and x >= xpos - 4 then
		self.m_bGrabbed = true
	else
		self:SetValueFromMouseX(x)
	end
	return true
end

function PANEL:OnMouseMoved(x, y, dx, dy, istouch)
	if self.m_bGrabbed then
		self:SetValueFromMouseX(x)
	end
end

function PANEL:OnMouseWheeled(x, y)
	self:SetValue(self.m_iValue + (y * self.m_iSteps))
end

function PANEL:OnMouseReleased(x, y, but)
	if not self:IsEnabled() or but ~= 1 then return end
	if self.m_bGrabbed then
		self.m_bGrabbed = false
	end
end

function PANEL:OnValueChanged(i)
	
end

gui.register("Slider", PANEL, "Panel")