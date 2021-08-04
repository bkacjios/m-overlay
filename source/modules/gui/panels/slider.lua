local PANEL = {}

PANEL.NotchColor = color(100, 100, 100)
PANEL.GrabberColor = color(0, 162, 232)

ACCESSOR(PANEL, "Min", "m_iMin", 0)					-- minumum allowed value
ACCESSOR(PANEL, "Max", "m_iMax", 100)				-- maximum allowed value
ACCESSOR(PANEL, "Value", "m_iValue", 0)				-- starting value
ACCESSOR(PANEL, "Steps", "m_iSteps", 1)				-- steps/max = number of potential values
ACCESSOR(PANEL, "Increments", "m_iIncrements", 5)	-- "minor" notches
ACCESSOR(PANEL, "Notches", "m_iNotches", 4)			-- "major" notches

function PANEL:Initialize()
	self:super() -- Initialize our baseclass
	self:SetWidth(128)

	self:SetFocusable(true)

	self.m_bGrabbed = false
end

function PANEL:Paint(w,h)
	gui.skinHook("Paint", "Slider", self, w, h)

	-- Draw a line down the middle
	graphics.setColor(self.NotchColor)
	graphics.line(0, h/2, w, h/2)

	local x = 0

	if self.m_iIncrements > 0 then
		local range = self:GetRange()

		local increments = (range/self.m_iIncrements)
		local gap = w/increments

		for i=1, increments-1 do
			x = 0 + gap * i
			graphics.line(x, 8, x, h - 8)
		end
	end

	if self.m_iNotches > 0 then
		gap = w/self.m_iNotches

		for i=1, self.m_iNotches-1 do
			x = 0 + gap * i
			graphics.line(x, 4, x, h - 4)
		end
	end
end

function PANEL:PaintOverlay(w, h)
	gui.skinHook("PaintOverlay", "FocusPanel", self, w, h)

	local perct = (self.m_iValue - self.m_iMin) / (self.m_iMax - self.m_iMin)
	local xpos = perct*w

	graphics.setColor(self.GrabberColor)
	graphics.rectangle("fill", xpos - 4, 4, 8, h - 8)

	graphics.setColor(color_black)
	graphics.rectangle("line", xpos - 4, 4, 8, h - 8)
end

function PANEL:SetValue(i)
	-- Round value to nearest step
	local value = math.floor((i / self.m_iSteps) + 0.5) * self.m_iSteps
	-- Clamp value to min/max
	self.m_iValue = math.min(self.m_iMax, math.max(self.m_iMin, value))
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
	self:SetValue(math.floor(self.m_iMin + ((x/w) * range) + 0.5))
end

function PANEL:OnMousePressed(x, y, but)
	if not self:IsEnabled() or but ~= 1 then return end

	local w = self:GetWidth()

	local perct = (self.m_iValue - self.m_iMin) / (self.m_iMax - self.m_iMin)
	local xpos = perct*w

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
	if not self:IsEnabled() then return end
	self:SetValue(self.m_iValue + (y * self.m_iSteps))
	return true
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