local PANEL = {}

function PANEL:OnMousePressed(x, y, but)
	self.m_bPressed = true
	self:GetParent():Grip(self)
	self:SetBGColor(color(240, 240, 240, 255))
	return true
end

function PANEL:OnMouseReleased()
	self.m_bPressed = false
	self:GetParent():OnMouseReleased()
end

function PANEL:IsPressed()
	return self.m_bPressed
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "ScrollBarGrip", self, w, h)
end

gui.register("ScrollBarGrip", PANEL, "Panel")

local PANEL = {}

function PANEL:Initialize()	
	self:super()
	
	self:SetWidth(16)
	self.m_iOffset = 0
	self.m_iScroll = 0
	self.m_iCanvasSize = 1
	self.m_iBarSize = 1
	
	self.m_pScrollGrip = self:Add("ScrollBarGrip")
	
	self.m_pUpButton = self:Add("Button")
	self.m_pUpButton:SetText("")
	self.m_pUpButton.OnClick = function(self) self:GetParent():AddScroll(-1) end
	self.m_pUpButton.Paint = function(panel, w, h) gui.skinHook("Paint", "ScrollBarButtonUp", panel, w, h) end
	
	self.m_pDownButton = self:Add("Button")
	self.m_pDownButton:SetText("")
	self.m_pDownButton.OnClick = function(self) self:GetParent():AddScroll(1) end
	self.m_pDownButton.Paint = function(panel, w, h) gui.skinHook("Paint", "ScrollBarButtonDown", panel, w, h) end
end

function PANEL:SetEnabled(b)
	if not b then
		self.m_iOffset = 0
		self:SetScroll(0)
		self.m_bHasChanged = true
	end
	
	self:SetVisible(b)
	
	-- We're probably changing the width of something in our parent
	-- by appearing or hiding, so tell them to re-do their layout.
	if self.m_bEnabled ~= b then
		self:GetParent():InvalidateLayout()
		if self:GetParent().OnScrollbarAppear then
			self:GetParent():OnScrollbarAppear()
		end
	end
	
	self.m_bEnabled = b
end

function PANEL:Value()
	return self.Pos
end

function PANEL:BarScale()
	if self.m_iBarSize == 0 then return 1 end
	return self.m_iBarSize / (self.m_iCanvasSize+self.m_iBarSize)
end

function PANEL:SetUp(bsize, csize)
	self.m_iBarSize = bsize
	self.m_iCanvasSize = math.max(csize - bsize, 1)
	self:SetEnabled(csize > bsize)
	self:InvalidateLayout()
end

function PANEL:OnMouseWheeled(x, y)
	if not self:IsVisible() then return false end
	return self:AddScroll(y * -1)
end

function PANEL:AddScroll(dir)
	local oldScroll = self:GetScroll()
	self:SetScroll(self:GetScroll() + (dir * 25))
	return oldScroll ~= self:GetScroll()
end

function PANEL:SetScroll(scrll)
	if not self.m_bEnabled then self.m_iScroll = 0 return end

	self.m_iScroll = math.clamp(scrll, 0, self.m_iCanvasSize)
	
	self:InvalidateLayout()
	
	-- If our parent has a OnVScroll function use that, if
	-- not then invalidate layout (which can be pretty slow)
	local func = self:GetParent().OnVScroll
	if func then
		func(self:GetParent(), self:GetOffset())
	else
		self:GetParent():InvalidateLayout()
	end
end

function PANEL:GetScroll()
	if not self.m_bEnabled then self.m_iScroll = 0 end
	return self.m_iScroll
end

function PANEL:GetOffset()
	if not self.m_bEnabled then return 0 end
	return self.m_iScroll * -1
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "Panel", self, w, h)
end

function PANEL:OnMousePressed(x, y, but)
	if but ~= 1 then return end
	local PageSize = self.m_iBarSize
	if y > self.m_pScrollGrip.m_iPosY then
		self:SetScroll(self:GetScroll() + PageSize)
	else
		self:SetScroll(self:GetScroll() - PageSize)
	end
	return true
end

function PANEL:OnMouseReleased(x, y, but)
	self.m_bDragging = false
	self.DraggingCanvas = nil
	self.m_pScrollGrip.Depressed = false
end

function PANEL:Grip(panel)
	if not self.m_bEnabled then return end
	if self.m_iBarSize == 0 then return end

	local mx, my = love.mouse.getPosition()
	local px, py = panel:GetPos()

	self.m_bDragging = true
	self.HoldPos = my - py
	self.m_pScrollGrip.Depressed = true
end

function PANEL:Think(dt)
	if not self.m_bEnabled then return end
	if not self.m_bDragging then return end

	local trackSize = self:GetHeight() - self:GetWidth() * 2 - self.m_pScrollGrip:GetHeight()

	local mx, my = love.mouse.getPosition()
	my = (my - self.HoldPos - self.m_pUpButton:GetHeight()) / trackSize

	self:SetScroll(my * self.m_iCanvasSize)
end

function PANEL:PerformLayout()
	local wide = self:GetWidth()
	local scroll = self:GetScroll() / self.m_iCanvasSize
	local barsize = math.max(self:BarScale() * (self:GetHeight() - (wide * 2)), 10)
	local track = self:GetHeight() - (wide * 2) - barsize
	track = track + 1
	
	scroll = scroll * track
	
	self.m_pScrollGrip:SetPos(0, wide + scroll)
	self.m_pScrollGrip:SetSize(wide, barsize)
	
	self.m_pUpButton:SetPos(0, 0)
	self.m_pUpButton:SetSize(wide, wide)
	
	self.m_pDownButton:SetPos(0, self:GetHeight() - wide)
	self.m_pDownButton:SetSize(wide, wide)
end

gui.register("ScrollBar", PANEL, "Panel")