local PANEL = {}

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
	self.m_pHovered = nil
	self.m_pGrabbed = nil
	self.m_pSelected = nil
	self.m_bDidDrag = false
	self.m_tGrabbedOffset = { x = 0, y = 0 }
end

function PANEL:PrePaint(w, h)
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
end

function PANEL:PaintOverlay(w, h)
	-- Only draw selection in editor mode and if we have a grabbed panel
	if self:IsInEditorMode() then

		-- Only draw hovered selection if we are not currently grabbing something
		if not self.m_bDidDrag and self.m_pHovered and self.m_pHovered ~= self then
			local x, y = self.m_pHovered:GetPos()
			local w, h = self.m_pHovered:GetSize()

			-- Draw a blue selection for objects we are hovering
			graphics.setLineStyle("rough")
			graphics.setLineWidth(3)
			graphics.setColor(color_blue)
			graphics.rectangle("line", x, y, w, h)
		end

		if self.m_pSelected then
			local x, y = self.m_pSelected:GetPos()
			local w, h = self.m_pSelected:GetSize()

			-- Draw a red selection for objects we have selected
			graphics.setLineStyle("rough")
			graphics.setLineWidth(3)
			graphics.setColor(color_red)
			graphics.rectangle("line", x, y, w, h)
		end
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

	-- Select an object if we don't have one already, or we clicked outside of the bounds of previous selection
	if not self.m_pSelected or not self.m_pSelected:IsWorldPointInside(x, y) then
		self.m_pSelected = self:GetHoveredChild(x, y)
	end

	-- Ignore the SceneDisplay object, and allow the MousePressed event to continue on
	if not self.m_pSelected then return true end

	-- Set that we are grabbing a panel
	self.m_pGrabbed = self.m_pSelected

	-- We started a new click, turn off the drag flag
	self.m_bDidDrag = false

	-- Translate mouse position back to local position within the SceneDisplay
	x, y = self.m_pGrabbed:WorldToLocal(x, y)

	self.m_tGrabbedOffset = { x = x, y = y }
	return true -- Stop the mouse event from going up the parent list
end

function PANEL:OnMouseReleased(x, y, but)
	-- Stop if the button isn't a left click or we're not in editor mode
	if but ~= 1 or not self:IsInEditorMode() then return end

	-- If we didn't drag anything...
	if not self.m_bDidDrag then
		x, y = self:LocalToWorld(x, y)

		-- Get the panel we are hoving over, and ignore what we already have selected
		-- May have to change this to Z-Position, as there could be more than 1 object in the background
		self.m_pSelected = self:GetHoveredChild(x, y, self.m_pSelected) or self.m_pSelected
	end

	self.m_bDidDrag = false
	
	-- We are no longer grabbing the panel
	self.m_pGrabbed = nil
end

function PANEL:OnMouseMoved(mx, my, dx, dy, istouch)
	-- Translate mouse position to screenspace
	local lx, ly = self:LocalToWorld(mx, my)

	-- Ignore selection to select and mark panels behind it as hovered over
	self.m_pHovered = self:GetHoveredChild(lx, ly, self.m_pSelected)

	-- Stop if nothing is grabbed or the grabbed object is docked
	if not self.m_pGrabbed or self.m_pGrabbed:GetDock() ~= 0 then return end

	-- Flag that we moved the mouse while grabbing an object
	self.m_bDidDrag = true

	-- Get the size of the grabbed object
	local w, h = self.m_pGrabbed:GetSize()

	-- Get the size of the scene display
	local pw, ph = self:GetSize()

	local t = self.m_iSnapThreshold

	-- Get the offset of the mouse
	local gx, gy = self.m_tGrabbedOffset.x, self.m_tGrabbedOffset.y

	-- Translate mouse position to panels position
	local x, y = mx - gx, my - gy

	-- Position plus size
	local xw, yh = x + w, y + h

	-- Edge snapping on display edges

	-- Edge snap on x axis
	if x <= t and x >= -t then
		-- Snap to left of the screen
		x = 0
	elseif xw <= pw + t and xw >= pw - t then
		-- Snap to right of the screen
		x = pw - w
	end

	-- Edge snap on y axis
	if y <= t and y >= -t then
		-- Snap to top of the screen
		y = 0
	elseif yh <= ph + t and yh >= ph - t then
		-- Snap to bottom of the screen
		y = ph - h
	end

	-- Edge snapping on other objects

	for k, child in ipairs(self:GetChildren()) do
		-- Ignore what we are grabbing
		if child ~= self.m_pGrabbed then
			-- Get child size
			cw, ch = child:GetSize()

			-- Get child position
			local cx, cy = child:GetPos()

			-- Position plus size
			local cxw, cyh = cx + cw, cy + ch
			
			-- Edge snapping on x axis
			if x <= cx + t and x >= cx - t then
				-- Snap left edge of panel to left edge of other panel
				x = cx
			elseif x <= cxw + t and x >= cxw - t then
				-- Snap left edge of panel to right edge of other panel
				x = cxw
			elseif xw <= cx + t and xw >= cx - t then
				-- Snap right edge of panel to left edge of other panel
				x = cx - w
			elseif xw <= cxw + t and xw >= cxw - t then
				-- Snap right edge of panel to right edge of other panel
				x = cxw - w
			end

			-- Edge snapping on y axis
			if y <= cy + t and y >= cy - t then
				-- Snap top edge of panel to top edge of other panel
				y = cy
			elseif y <= cyh + t and y >= cyh - t then
				-- Snap top edge of panel to bottom edge of other panel
				y = cyh
			elseif yh <= cy + t and yh >= cy - t then
				-- Snap bottom edge of panel to top edge of other panel
				y = cy - h
			elseif yh <= cyh + t and yh >= cyh - t then
				-- Snap bottom edge of panel to bottom edge of other panel
				y = cyh - h
			end
		end
	end
	
	-- Finally set our snapped position
	self.m_pGrabbed:SetPos(x, y)
end

gui.register("SceneDisplay", PANEL, "Panel")