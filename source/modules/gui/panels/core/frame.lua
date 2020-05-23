local PANEL = {}

function PANEL:Initialize()
	self:super()
	
	self.m_bGrabbed = false

	self:MakeAccessor("Draggable", "m_bDraggable", true)
	self:MakeAccessor("HideOnClose", "m_bHideOnClose", false)

	self:DockPadding(4, 36, 4, 4)
	
	self.m_pTitle = self:Add("Label")
	self.m_pTitle:SetText("Window")
	
	self.m_pClose = self:Add("Button")
	self.m_pClose:SetText("x")
	gui.skinHook("Init", "ExitButton", self.m_pClose)
	
	self.m_pClose.OnClick = function(this, but)
		if self.m_bHideOnClose then
			self:SetVisible(false)
		else
			self:Remove()
		end
	end
end

function PANEL:SetTitle(s)
	self.m_pTitle:SetText(s)
end

function PANEL:PerformLayout()
	self.m_pTitle:SetPos(2, 2)
	self.m_pTitle:SetSize(self:GetWidth() -  48, 28)
	
	self.m_pClose:SetPos(self:GetWidth() - 46, 4)
	self.m_pClose:SetSize(42, 24)
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "Frame", self, w, h)
end

function PANEL:OnMousePressed(x, y, but)
	self:BringToFront()
	if not self.m_bDraggable or not self:HasFocus() then return end
	if y > 32 then return end -- Only allow them to move using the top bar
	self.m_bGrabbed = true
	self.m_tGrabbedOffset = { x = x, y = y }
end

function PANEL:OnMouseReleased(x, y, but)
	if not self.m_bDraggable then return end
	self.m_bGrabbed = false
end

function PANEL:Think(dt)
	if not self.m_bGrabbed then return end

	local mx, my = love.mouse.getPosition()
	local gx, gy = self.m_tGrabbedOffset.x, self.m_tGrabbedOffset.y
	
	self:SetPos(mx - gx, my - gy)
end

gui.register("Frame", PANEL, "Panel")