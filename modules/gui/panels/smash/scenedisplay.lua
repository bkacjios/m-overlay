local PANEL = {}

local timer = love.timer

function PANEL:Initialize()
	-- Initialize values within Panel:Initialize()
	self:super()

	-- Display should have no padding or margin
	-- since it will match the size of the window
	self:DockPadding(0,0,0,0)
	self:DockMargin(0,0,0,0)

	-- Transparent for use with OBS game capture
	self:SetBGColor(color_blank)
	self:SetBorderColor(color_blank)

	-- Member values
	self.m_iSnapThreshold = 6
	self.m_pGrabbed = nil
	self.m_bHolding = false
	self.m_tGrabbedOffset = { x = 0, y = 0 }
end

function PANEL:Paint(w, h)
	-- Draw Panel stuff
	self:super("Paint", w, h)

	-- Only draw selection in editor mode and if we have a grabbed panel
	if gui.isInEditorMode() and self.m_pGrabbed then
		local x, y = self.m_pGrabbed:GetPos()
		local w, h = self.m_pGrabbed:GetSize()

		-- Draw a red selection outline
		love.graphics.setLineStyle("rough")
		love.graphics.setLineWidth(3)
		love.graphics.setColor(255, 0, 0, 255)
		love.graphics.outlineRectangle(x, y, w, h)
	end
end

function PANEL:IsInEditorMode()
	-- Check the parent for this setting
	return self:GetParent():IsInEditorMode()
end

function PANEL:OnMousePressed(x, y, button, istouch, presses)
	-- Stop if the button isn't a left click or we're not in editor mode
	if button ~= 1 or not self:IsInEditorMode() then return end

	-- Convert x and y coordinates to global screen values
	x, y = self:LocalToWorld(x, y)

	-- Get the panel we are hoving over, and ignore what we have selected if we double click
	local grabbed = self:GetHoveredPanel(x, y, presses >= 2 and self.m_pGrabbed or nil)

	-- Ignore the SceneDisplay object, and allow the MousePressed event to continue on
	if grabbed == self then self.m_pGrabbed = nil return true end

	-- Set that we are grabbing a panel
	self.m_pGrabbed = grabbed
	self.m_bHolding = true

	-- Translate mouse position back to local position within the SceneDisplay
	x, y = self.m_pGrabbed:WorldToLocal(x, y)

	-- Give our grabbed object focus
	self.m_pGrabbed:GiveFocus()

	-- Bring it in front of all other panels? (TODO: Use object list for ordering)
	self.m_pGrabbed:BringToFront()

	self.m_tGrabbedOffset = { x = x, y = y }
	return true -- Stop the mouse event from going up the parent list
end

function PANEL:OnMouseReleased(x, y, but)
	-- Stop if the button isn't a left click or we're not in editor mode
	if but ~= 1 or not self:IsInEditorMode() then return end
	
	-- We are no longer grabbing the panel
	self.m_bHolding = false
end

function PANEL:OnMouseMoved(mx, my, dx, dy, istouch)
	local grabbed = self.m_pGrabbed

	if not grabbed or not self.m_bHolding then return end
	--if self.m_pGrabbed:GetDock() ~= 0 then return end -- Can't move docked objects

	-- Get the size of the grabbed object
	local w, h = grabbed:GetSize()

	-- Get the size of the scene display
	local pw, ph = self:GetSize()

	local t = self.m_iSnapThreshold

	-- Get the offset of the mouse
	local gx, gy = self.m_tGrabbedOffset.x, self.m_tGrabbedOffset.y

	-- Translate back to the x,y values ( Could probably just use grabbed:GetPos() ? )
	local x, y = mx - gx, my - gy

	-- Edge snapping on x axis
	if x <= t and x >= -t then
		-- Snap to left
		x = 0
	elseif x + w <= pw + t and x + w >= pw - t then
		-- Snap to right
		x = pw - w
	end

	-- Edge snapp on y axis
	if y <= t and y >= -t then
		-- Snap to top
		y = 0
	elseif y + h <= ph + t and y + h >= ph - t then
		-- Snap top bottom
		y = ph - h
	end

	-- TODO: Edge snapping on other objects

	for k, child in ipairs(self:GetChildren()) do
		-- Ignore what we are grabbing
		if child ~= grabbed then

		end
	end
	
	-- Finally set our snapped position
	grabbed:SetPos(x, y)
end

gui.register("SceneDisplay", PANEL, "Panel")