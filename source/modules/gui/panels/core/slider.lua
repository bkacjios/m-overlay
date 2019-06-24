local PANEL = {}

function PANEL:Initialize()
	self:super()
	
	self.m_iMin = 0
	self.m_iMax = 100
	self.m_iValue = 50
	self.m_iNotches = 4
end

function PANEL:Paint(w,h)

end

gui.register("Slider", PANEL, "Panel")