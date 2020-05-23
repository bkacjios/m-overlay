local PANEL = {}

function PANEL:Initialize()
	self:super()
	self:SetWidth(128)
	
	self.m_iMin = 0
	self.m_iMax = 100
	self.m_iValue = 50
	self.m_iNotches = 4
end

function PANEL:Paint(w,h)
	graphics.line(0, h/2, w, h/2)

	local gap = w/self.m_iNotches
	local x = 0

	for i=1, self.m_iNotches-1 do
		x = 0 + gap * i
		graphics.line(x, 0, x, h)
	end
end

gui.register("Slider", PANEL, "Panel")