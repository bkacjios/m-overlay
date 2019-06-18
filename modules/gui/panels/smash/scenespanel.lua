local PANEL = {}

function PANEL:Initialize()
	self:super()

	self:DockPadding(0,0,0,0)
	self:DockMargin(0,0,0,0)

	self.m_bEditable = true

	self.m_pGrabbed = nil
	self.m_bHolding = false
	self.m_tGrabbedOffset = { x = 0, y = 0 }
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
	if gui.isInEditorMode() and self.m_pGrabbed then
		local x, y = self.m_pGrabbed:GetPos()
		local w, h = self.m_pGrabbed:GetSize()
		love.graphics.setLineStyle("rough")
		love.graphics.setColor(255, 0, 0, 255)
		love.graphics.rectangle("line", x, y, w, h)
	end
end

function PANEL:OnMousePressed(x, y, but)
	if not gui.isInEditorMode() or but ~= 1 or not self.m_bEditable then return end
	x, y = self:LocalToWorld(x, y)
	local grabbed = self:GetHoveredPanel(x, y)
	if grabbed == self then self.m_pGrabbed = nil return true end
	self.m_pGrabbed = grabbed
	self.m_bHolding = true
	x, y = self.m_pGrabbed:WorldToLocal(x, y)
	self.m_pGrabbed:GiveFocus()
	self.m_tGrabbedOffset = { x = x, y = y }
	return true -- Stop the mouse event from going up the parent list
end

function PANEL:OnMouseReleased(x, y, but)
	if but ~= 1 or not self.m_bEditable then return end
	self.m_bHolding = false
end

function PANEL:Think(dt)
	if not self.m_pGrabbed or not self.m_bHolding then return end

	local mx, my = self:WorldToLocal(love.mouse.getPosition())
	local gx, gy = self.m_tGrabbedOffset.x, self.m_tGrabbedOffset.y
	
	self.m_pGrabbed:SetPos(mx - gx, my - gy)
end

gui.register("ScenesPanel", PANEL, "Panel")