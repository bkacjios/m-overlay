local PANEL = {}

function PANEL:Initialize()
	self:super()

	self:DockPadding(0,0,0,0)
	self:DockMargin(0,0,0,0)

	self:SetBGColor(color_blank)
	self:SetBorderColor(color_blank)

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

function PANEL:GetEditorMode()
	return self:GetParent():GetEditorMode()
end

function PANEL:OnMousePressed(x, y, but)
	if not gui.isInEditorMode() or but ~= 1 or not self:GetEditorMode() then return end
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
	if but ~= 1 or not self:GetEditorMode() then return end
	self.m_bHolding = false
end

function PANEL:Think(dt)
	if not self.m_pGrabbed or not self.m_bHolding then return end
	if self.m_pGrabbed:GetDock() ~= 0 then return end -- Can't move docked objects

	local mx, my = self:WorldToLocal(love.mouse.getPosition())
	local gx, gy = self.m_tGrabbedOffset.x, self.m_tGrabbedOffset.y
	
	self.m_pGrabbed:SetPos(mx - gx, my - gy)
end

gui.register("SceneDisplay", PANEL, "Panel")


local PANEL = {}

function PANEL:Initialize()
	self:super()

	self:DockPadding(0,0,0,0)
	self:DockMargin(0,0,0,0)

	self:SetBGColor(color_blank)
	self:SetBorderColor(color_blank)

	self.m_pObjectList = self:Add("Panel")
	self.m_pObjectList:SetWidth(128 + 32)
	self.m_pObjectList:Dock(DOCK_LEFT)
	self.m_pObjectList:SetVisible(false)

	self.m_pSceneDisplay = self:Add("SceneDisplay")
	self.m_pSceneDisplay:Dock(DOCK_FILL)

	self.m_bEditable = true
end

function PANEL:AddToScene(name)
	local panel = self.m_pSceneDisplay:Add(name)

	local but = self.m_pObjectList:Add("Label")
	but:Dock(DOCK_TOP)
	but:SetText(name)

	return panel
end

function PANEL:SetEditorMode(b)
	self.m_bEditable = b
	self.m_pObjectList:SetVisible(b)
	if b then
		self:SetBGColor(color(240, 240, 240))
		self.m_pSceneDisplay:DockMargin(4, 4, 4, 4)
		self.m_pSceneDisplay:SetBGColor(color_black)
	else
		self:SetBGColor(color_blank)
		self.m_pSceneDisplay:DockMargin(0, 0, 0, 0)
		self.m_pSceneDisplay:SetBGColor(color_blank)
	end
	self:InvalidateLayout()
end

function PANEL:GetEditorMode()
	return self.m_bEditable
end

function PANEL:GetObjectList()
	return self.m_pObjectList
end

function PANEL:GetDisplay()
	return self.m_pSceneDisplay
end

gui.register("SceneEditor", PANEL, "Panel")