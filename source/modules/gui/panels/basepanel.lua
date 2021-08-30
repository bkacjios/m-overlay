local PANEL = class.create("BasePanel")

require("extensions.table")

PANEL:ACCESSOR("Interacted", "m_bInteracted", false)
PANEL:ACCESSOR("Hovered", "m_bHovered", false)
PANEL:ACCESSOR("Visible", "m_bVisible", true)
PANEL:ACCESSOR("Focusable", "m_bFocusable", true)
PANEL:ACCESSOR("Validated", "m_bValidated", false)

function PANEL:BasePanel()
	self.m_tChildren = {}
	self.m_tOrphans = {}
	self.m_iWorldPosX = 0
	self.m_iWorldPosY = 0
	self.m_fScaleX = 1
	self.m_fScaleY = 1
	self.m_iPosX = 0
	self.m_iPosY = 0
	self.m_iWidth = 42
	self.m_iHeight = 24
	self.m_pParent = nil
	self.m_iZPos = 0
	self.m_bScissorEnabled = true
	self.m_bOrphaned = false
	self.m_bDeleted = false
	self.m_iDock = DOCK_NONE
	self.m_iCenter = CENTER_NONE
	self.m_tDockMargins = { left = 2, top = 2, right = 2, bottom = 2 }
	self.m_tDockPadding = { left = 2, top = 2, right = 2, bottom = 2 }
end

function PANEL:GetClassName()
	return self.__classname
end

function PANEL:__tostring()
	return ("Panel[%q]"):format(self.__classname)
end

function PANEL:GetConfig()
	local w, h = self:GetPixelSize()
	local sx, sy = self:GetScale()

	local config = {
		classname = self:GetClassName(),
		pos = { x = self:GetX(), y = self:GetY(), z = self:GetZPos() },
		size = { width = w, height = h },
		scale = { x = sx, y = sy },
		visible = self:IsVisible(),
		accessors = self.__accessors,
	}

	if self.m_iDock ~= 0 then
		config.dock = {
			mode = self.m_iDock,
			margins = self.m_tDockMargins,
			padding = self.m_tDockPadding,
		}
	end

	return config
end

function PANEL:BringToFront()
	local parent = self.m_pParent
	if not parent then return end -- There's nothing for it to go in front of!
	
	local highest = nil

	for _,child in ipairs(parent.m_tChildren) do
		if not highest or child:GetZPos() > highest:GetZPos() then
			highest = child
		end
	end

	-- No panels or the highest is already ourself
	if not highest or highest == self then return end

	-- Get the position of the highest panel
	local replace = highest:GetZPos()

	-- Set the highest panel to our current position
	highest:SetZPos(self:GetZPos())

	-- Set our position to where the highest panel used to be
	self:SetZPos(replace)
end

function PANEL:Dock(i)
	self.m_iDock = i
	self:InvalidateLayout()
end

function PANEL:GetDock()
	return self.m_iDock
end

function PANEL:DockMargin(left, top, right, bottom)
	self.m_tDockMargins.left = left
	self.m_tDockMargins.top = top
	self.m_tDockMargins.right = right
	self.m_tDockMargins.bottom = bottom
end

function PANEL:GetDockMargin()
	return self.m_tDockMargins
end

function PANEL:DockPadding(left, top, right, bottom)
	self.m_tDockPadding.left = left
	self.m_tDockPadding.top = top
	self.m_tDockPadding.right = right
	self.m_tDockPadding.bottom = bottom
end

function PANEL:GetDockPadding()
	return self.m_tDockPadding
end

function PANEL:GetWidthPlusMargin()
	if not self:IsVisible() then return 0 end
	local margins = self:GetDockMargin()
	return margins.left + margins.right + self:GetWidth()
end

function PANEL:GetHeightPlusMargin()
	if not self:IsVisible() then return 0 end
	local margins = self:GetDockMargin()
	return margins.top + margins.bottom + self:GetHeight()
end

function PANEL:GetSizePlusMargin()
	local w, h = self:GetWidthPlusMargin(), self:GetHeightPlusMargin()

	--[[for _,child in ipairs(self.m_tChildren) do
		if child:IsVisible() then
			margins = child:GetDockMargin()
			padding = child:GetDockPadding()
			w = w + margins.left + margins.right + padding.left + padding.right
			h = h + margins.top + margins.bottom + padding.top + padding.bottom
		end
	end]]

	return w, h
end

--[[function PANEL:GetSpaceAround(panel)
	local margins = panel:GetDockMargin()
	local padding = panel:GetDockPadding()

	local w = margins.left + margins.right + padding.left + padding.right
	local h = margins.top + margins.bottom + padding.top + padding.bottom

	for _,child in ipairs(self.m_tChildren) do
		if child ~= panel and child:IsVisible() then
			local margins = child:GetDockMargin()
			local padding = child:GetDockPadding()
			w = w + margins.left + margins.right + padding.left + padding.right + child:GetWidth()
			h = h + margins.top + margins.bottom + padding.top + padding.bottom + child:GetHeight()
		end
	end

	local width, height = self:GetSize()

	return w, h
end]]

function PANEL:SetZPos(i)
	self.m_iZPos = i
	self:GetParent():ReorderChildren()
end

function PANEL:ReorderChildren()
	table.sort(self.m_tChildren, function(a, b) return a.m_iZPos < b.m_iZPos end)
end

function PANEL:GetZPos()
	return self.m_iZPos
end

function PANEL:CallAll(func, ...)
	if not self:IsVisible() then return end
	self[ func ](self, ...)
	for _,child in ipairs(self.m_tChildren) do
		child:CallAll(func, ...)
	end
end

function PANEL:CallSelfAndParents(func, ...)
	if not self:IsVisible() then return end
	if self[ func ](self, ...) then return end
	local parent = self.m_pParent
	if not parent then return end
	parent:CallSelfAndParents(func, ...)
end

function PANEL:Remove()
	local parent = self:GetParent()
	if parent then
		parent:OnChildRemoved(self)
	end

	self.m_bDeleted = true
	self:OnRemoved()

	for zpos, child in ipairs(self.m_tChildren) do
		child:Remove()
	end
end

function PANEL:Clear()
	for zpos, child in ipairs(self.m_tChildren) do
		child:Remove()
	end
end

function PANEL:InvalidateLayout()
	self.m_bValidated = false
	for _,child in ipairs(self.m_tChildren) do
		child:InvalidateLayout()
	end
end

function PANEL:InvalidateParent()
	if not self.m_pParent then return end
	self.m_pParent:InvalidateLayout()
end

function PANEL:MarkAsOrphan()
	self.m_bOrphaned = true
end

function PANEL:CleanupOrphans()
	for key, child in reversedipairs(self.m_tChildren) do
		child:CleanupOrphans()
		if child.m_bOrphaned then
			table.remove(self.m_tChildren, key)
		end
	end
end

function PANEL:CleanupDeleted()
	for key, child in reversedipairs(self.m_tChildren) do
		child:CleanupDeleted()
		if child.m_bDeleted then
			self.m_tChildren[key] = nil
			table.remove(self.m_tChildren, key)
		end
	end
end

function PANEL:SetParent(parent)
	if self.m_pParent then
		self:MarkAsOrphan()
	end
	self.m_pParent = parent
	if parent then
		table.insert(parent.m_tChildren, self)
		parent:OnChildAdded(self)
		self:SetZPos(#parent.m_tChildren)
	end
end

function PANEL:HasParent()
	return self:GetParent() ~= nil
end

function PANEL:GetParent()
	return self.m_pParent
end

function PANEL:GetParents()
	local parents = {}
	
	local parent = self:GetParent()
	
	while parent do
		table.insert(parents, parent)
		parent = parent:GetParent()
	end
	return parents
end

function PANEL:GetChildren()
	return self.m_tChildren
end

function PANEL:GetFamily(family)
	local family = family or {}
	
	local children = self.m_tChildren
	family[self] = children
	
	for _,child in ipairs(children) do
		child:GetFamily(family[self])
	end
	
	return family
end

function PANEL:SizeToScreen()
	self:SetSize(graphics.getPixelDimensions())
end

function PANEL:SizeToParent()
	local parent = self:GetParent()

	if parent then
		self:SetSize(parent:GetSize())
	end
end

function PANEL:SizeToChildren(doWidth, doHeight)
	local all = doWidth == nil and doHeight == nil
	local w,h = 0, 0
	local padding = self:GetDockPadding()

	local lw, lh = 0, 0

	for _,child in ipairs(self.m_tChildren) do
		if child:IsVisible() then
			local x, y = child:GetPos()
			local margin = child:GetDockMargin()
			local cw, ch = child:GetPixelSize()

			-- Position + size + margins = maximum bounds
			cw = x + cw + margin.left + margin.right
			ch = y + ch + margin.top + margin.bottom

			-- Update the largest widths and heights
			if cw > lw then lw = cw end
			if ch > lh then lh = ch end
		end
	end
	-- Don't use SetWidth/SetHeight so we don't invalidate the layout..
	if all or doWidth then self.m_iWidth = w + lw end
	if all or doHeight then self.m_iHeight = h + lh end
end

function PANEL:Add(class)
	return gui.create(class, self)
end

function PANEL:SetScale(x, y)
	y = y or x
	self.m_fScaleX, self.m_fScaleY = x, y
end

function PANEL:GetScale()
	return self.m_fScaleX, self.m_fScaleY
end

function PANEL:SetPos(x, y)
	self.m_iPosX, self.m_iPosY = math.floor(x + 0.5), math.floor(y + 0.5)
end

function PANEL:GetPos()
	return self.m_iPosX, self.m_iPosY
end

function PANEL:SetWorldPos(x, y)
	self.m_iWorldPosX, self.m_iWorldPosY = x, y
end

function PANEL:GetWorldPos()
	return self.m_iWorldPosX, self.m_iWorldPosY
end

function PANEL:LocalToWorld(x, y)
	local sx, sy = self:GetPos()
	x = x + sx
	y = y + sy
	
	local parent = self:GetParent()
	
	while parent do
		local px, py = parent:GetPos()
		x = x + px
		y = y + py
		parent = parent:GetParent()
	end
	
	return x, y
end

function PANEL:WorldToLocal(x, y)
	local sx, sy = self:LocalToWorld(0, 0)
	return x - sx, y - sy
end

function PANEL:SetX(x)
	self.m_iPosX = math.floor(x + 0.5)
end

function PANEL:GetX()
	return self.m_iPosX
end

function PANEL:SetY(y)
	self.m_iPosY = math.floor(y + 0.5)
end

function PANEL:GetY()
	return self.m_iPosY
end

function PANEL:SetSize(w, h)
	self:SetWidth(w)
	self:SetHeight(h)
	self:OnResize(w, h)
end

function PANEL:GetSize()
	return self:GetWidth(), self:GetHeight()
end

function PANEL:GetPixelSize()
	return math.max(0, self.m_iWidth), math.max(0, self.m_iHeight)
end

function PANEL:SetWidth(w)
	w = math.max(0, math.floor(w + 0.5))
	if self.m_iWidth ~= w then
		self.m_iWidth = w
		self:InvalidateLayout()
	end
end

function PANEL:GetActualWidth()
	return math.max(0, self.m_iWidth)
end

function PANEL:GetWidth()
	return self:GetActualWidth() * self.m_fScaleX
end

function PANEL:SetHeight(h)
	h = math.max(0, math.floor(h + 0.5))
	if self.m_iHeight ~= h then
		self.m_iHeight = h
		self:InvalidateLayout()
	end
end

function PANEL:GetActualHeight()
	return math.max(0, self.m_iHeight)
end

function PANEL:GetHeight()
	return self:GetActualHeight() * self.m_fScaleY
end

function PANEL:IsWorldPointInside(x, y)
	local px, py = self:LocalToWorld(0, 0)
	return x > px and x < px + self:GetWidth() and y > py and y < py + self:GetHeight()
end

function PANEL:Render()
	if not self:IsVisible() then return end

	local x, y = self:LocalToWorld(0, 0)
	local w, h = self:GetSize()
	
	local parent = self:GetParent()

	-- Start the scissor position and size with our own values
	local sx, sy = x, y
	local sw, sh = w, h

	while self.m_bScissorEnabled and parent do
		-- If we have a parent, fit the scissor to fit inside their bounds
		local px, py = parent:LocalToWorld(0, 0)
		local pw, ph = parent:GetSize()

		if sx < px then
			sw = math.max(0, sw + sx - px)
			sx = px
		end
		if sx + sw > px + pw then
			sw = math.max(0, sw - ((sx + sw) - (px + pw)))
			sx = math.min(sx, px + pw)
		end
		if sy < py then
			sh = math.max(0, sh + sy - py)
			sy = py
		end
		if sy + sh > py + ph then
			sh = math.max(0, sh - ((sy + sh) - (py + ph)))
			sy = math.min(sy, py + ph)
		end

		parent = parent:GetParent()
	end

	self:SetWorldPos(sx, sy)

	-- Only bother to render if the panel is visible within the scissor
	if math.max(x, sx) < math.min(x + w, sx + sw) and math.max(y, sy) < math.min(y + h, sy + sh) then
		local rsx, rsy = self:GetScale()

		if self.m_bScissorEnabled then
			graphics.setScissor(sx, sy, sw, sh)
		end

		graphics.push("all") -- Push the current graphics state
			graphics.translate(x, y) -- Translate so Paint has localized position values for drawing objects
			graphics.scale(rsx, rsy)

			local uw, uh = self:GetPixelSize()
			graphics.setColor(255, 255, 255, 255)
			self:PrePaint(uw, uh)
			graphics.setColor(255, 255, 255, 255)
			self:Paint(uw, uh)
			graphics.setColor(255, 255, 255, 255)
			self:PostPaint(uw, uh)

			graphics.origin()

			-- recently added panels are drawn last, thus, ontop of older panels
			for _, child in ipairs(self.m_tChildren) do
				child:Render()
			end

			graphics.translate(x, y) -- Translate so Paint has localized position values for drawing objects
			graphics.scale(rsx, rsy)
			graphics.setColor(255, 255, 255, 255)
			self:PaintOverlay(self:GetPixelSize())

			graphics.origin()
		graphics.pop() -- Reset the graphics state to what it was

		if self.m_bDebug then
			-- Debug the scissor rect
			graphics.setColor(255, 0, 0, 25)
			graphics.rectangle("fill", sx, sy, sw, sh)
		end
		
		graphics.setScissor()
	end
end

function PANEL:DisableScissor()
	self.m_bScissorEnabled = false
end

function PANEL:ValidateLayout()
	if self:IsVisible() and not self.m_bValidated then
		self.m_bValidated = true
		self:CenterLayout()
		self:DockLayout()
		self:PerformLayout()
	end

	for _,child in ipairs(self.m_tChildren) do
		child:ValidateLayout()
	end
end

function PANEL:CenterLayout()
	local parent = self:GetParent()

	local w, h = self:GetSize()
	local pw, ph = graphics.getPixelDimensions() -- Default to window size if no parent
	if parent then
		pw, ph = parent:GetSize()
	end

	local vertical = bit.band(self.m_iCenter, CENTER_VERTICAL) == CENTER_VERTICAL
	local horizontal = bit.band(self.m_iCenter, CENTER_HORIZONTAL) == CENTER_HORIZONTAL

	if vertical == true then
		self:SetY((ph / 2) - (h / 2))
	end
	if horizontal == true then
		self:SetX((pw / 2) - (w / 2))
	end
end

function PANEL:Center(vertical, horizontal)
	self:CenterVertical(vertical)
	self:CenterHorizontal(horizontal)
end

function PANEL:CenterVertical(center)
	self.m_iCenter = bit.bor(self.m_iCenter, CENTER_VERTICAL)
	self:InvalidateLayout()
end

function PANEL:CenterHorizontal(center)
	self.m_iCenter = bit.bor(self.m_iCenter, CENTER_HORIZONTAL)
	self:InvalidateLayout()
end

function PANEL:DockLayout()
	local x, y = 0, 0
	local w, h = self:GetPixelSize()
	
	local padding = self.m_tDockPadding
	
	for _,child in ipairs(self.m_tChildren) do
		local margin = child.m_tDockMargins
	
		local dx = x + padding.left
		local dy = y + padding.top
		local dw = w - (padding.left + padding.right)
		local dh = h - (padding.top + padding.bottom)
	
		local dock = child.m_iDock
		if dock ~= DOCK_NONE then
			local cw, ch = child:GetPixelSize()
			if(dock == DOCK_TOP) then
				child:SetPos(dx + margin.left, dy + margin.top)
				child:SetSize(dw - margin.left - margin.right, ch)
				if child:IsVisible() then
					local height = margin.top + margin.bottom + ch
					y = y + height
					h = h - height
				end
			elseif(dock == DOCK_LEFT) then
				child:SetPos(dx + margin.left, dy + margin.top)
				child:SetSize(cw, dh - margin.top - margin.bottom)
				if child:IsVisible() then
					local width = margin.left + margin.right + cw
					x = x + width
					w = w - width
				end
			elseif(dock == DOCK_RIGHT) then
				child:SetPos((dx + dw) - cw - margin.right, dy + margin.top)
				child:SetSize(cw, dh - margin.top - margin.bottom)
				if child:IsVisible() then
					local width = margin.left + margin.right + cw
					w = w - width
				end
			elseif(dock == DOCK_BOTTOM) then
				child:SetPos(dx + margin.left, (dy + dh) - ch - margin.bottom)
				child:SetSize(dw - margin.left - margin.right, ch)
				if child:IsVisible() then
					h = h - (ch + margin.bottom + margin.top)
				end
			end
		end
	end
	
	for _,child in ipairs(self.m_tChildren) do
		local dock = child.m_iDock
		
		if dock ~= DOCK_NONE then
			local margin = child.m_tDockMargins
		
			local dx = x + padding.left
			local dy = y + padding.top
			local dw = w - (padding.left + padding.right)
			local dh = h - (padding.top + padding.bottom)
			
			if(dock == DOCK_FILL) then
				child:SetPos(dx + margin.left, dy + margin.top)
				child:SetSize(dw - margin.left - margin.right, dh - margin.top - margin.bottom)
			end
		end
	end
end

function PANEL:GiveFocus()
	gui.setFocusedPanel(self)
end

function PANEL:MakePopup()
	self:BringToFront()
	self:GiveFocus()
end

function PANEL:HasFocus(checkchildren)
	if checkchildren then
		for _,child in ipairs(self.m_tChildren) do
			if child:HasFocus(checkchildren) then
				return true
			end
		end
	end
	return gui.getFocusedPanel() == self
end

function PANEL:IsHovered()
	return gui.getHoveredPanel() == self
end

function PANEL:GetHoveredChild(x, y, ignore)
	local panel = nil
	for _,child in reversedipairs(self.m_tChildren) do
		if child:IsVisible() and child:IsFocusable() and child:IsWorldPointInside(x, y) and ((ignore and child ~= ignore) or not ignore) then
			panel = child:GetHoveredPanel(x, y)
			break
		end
	end
	return panel
end

function PANEL:GetHoveredPanel(x, y, ignore)
	local panel = self
	for _,child in reversedipairs(self.m_tChildren) do
		if child:IsVisible() and child:IsFocusable() and child:IsWorldPointInside(x, y) and ((ignore and child ~= ignore) or not ignore) then
			panel = child:GetHoveredPanel(x, y)
			break
		end
	end
	return panel
end

-- Tries to get find a position that can fit "other" somehwere around ourself without clipping outside our world
function PANEL:SetPosAround(other, world)
	world = world or gui.getWorldPanel()

	local pw, ph = self:GetPixelSize()

	local ox, oy = other:GetWorldPos()
	local ow, oh = other:GetPixelSize()

	local sx, sy = world:GetWorldPos()
	local sw, sh = world:GetPixelSize()

	local canFitAbove = (oy - sy) >= ph
	local canFitBelow = ((sy + sh) - (oy + oh)) >= ph
	local canFitLeft = (ox - sx) >= pw
	local canFitRight = ((sx + sw) - (ox + ow)) >= pw

	local finalX, finalY = 0, 0
	local midX, midY = 0,0

	if canFitAbove or canFitBelow then -- Prefer above or below
		midX = ox + ow/2

		-- set our x position centered against our other
		finalX = midX - pw/2

		-- fit our x position within our world
		finalX = math.min(sx + sw - pw, math.max(sx, finalX))
		if canFitAbove then
			-- set y above
			finalY = oy - ph
			midY = oy
		else
			-- set y below
			finalY = oy + oh
			midY = finalY
		end
	elseif canFitLeft or canFitRight then -- Try left or right if above and below fails
		midY = oy + oh/2

		-- set our y position centered against our other
		finalY = midY - ph/2

		-- fit our y position within our world
		finalY = math.min(sy + sh - ph, math.max(sy, finalY))
		if canFitLeft then
			-- set y left
			finalX = ox - pw
			midX = ox
		else
			-- set y right
			finalX = ox + ow
			midX = finalX
		end
	end

	-- return our position as a local position within the given world
	finalX, finalY = world:WorldToLocal(finalX, finalY)
	self:SetPos(finalX, finalY)
	return self:WorldToLocal(midX, midY)
end

-- PANEL OVERRIDE DEFAULTS

function PANEL:PerformLayout()
	-- Called when we are Validating the layout.
	-- Good for manually positioning child panels.
end

function PANEL:PrePaint(w, h)
end

function PANEL:Paint(w, h)
	-- Called every frame, when we are drawing the panel to the screen.
	-- Used to draw custom things within the panel.
end

function PANEL:PostPaint(w, h)
end

function PANEL:PaintOverlay(w, h)
end

function PANEL:OnResize(w, h)
	-- Called when the size of the panel has changed.
	-- Good for manually positioning child panels, like in PerformLayout.
end

function PANEL:OnFocusChanged(b)
	-- Called when the panels focus has either been gained or lost
end

function PANEL:OnHoveredChanged(b)
	-- Called when the panels hovered state has either been gained or lost
end

function PANEL:OnKeyPressed(key, isrepeat)
	-- Called when the panel is focused, and a keyboard key has been pressed
end

function PANEL:OnKeyReleased(key)
	-- Called when the panel is focused, and a keyboard key has been released
end

function PANEL:OnHoveredKeyPressed(key, isrepeat)
	-- Called when the panel is hovered over, and a keyboard key has been pressed
end

function PANEL:OnHoveredKeyReleased(key)
	-- Called when the panel is hovered over, and a keyboard key has been released
end

function PANEL:OnTextInput(text)
	-- Called when the panel is focused.
	-- Good for a text input panel.
end

function PANEL:OnHoveredTextInput(text)
	-- Called when the panel is hovered.
	-- Good for a text input panel.
end

function PANEL:OnJoyPressed(joy, but)
	-- Override
end

function PANEL:OnJoyReleased(joy, but)
	-- Override
end

function PANEL:OnMouseMoved(x, y, dx, dy, istouch)
	--[[
	Called when when the mouse has been moved.

	number x
		The mouse position on the x-axis.
	number y
		The mouse position on the y-axis.
	number dx
		The amount moved along the x-axis since the last time love.mousemoved was called.
	number dy
		The amount moved along the y-axis since the last time love.mousemoved was called.

	Returning true will stop the event from going up the family tree
	Child->Parent->Parent->Parent->etc, etc..
	]]
	
	return false
end

function PANEL:OnMousePressed(x, y, button, istouch, presses)
	--[[
	Called when a mouse press event has been made.

	number x
		The mouse position on the x-axis.
	number y
		The mouse position on the y-axis.
	number dx
		The amount moved along the x-axis since the last time love.mousemoved was called.
	number dy
		The amount moved along the y-axis since the last time love.mousemoved was called.

	Returning true will stop the event from going up the family tree
	Child->Parent->Parent->Parent->etc, etc..
	]]
	
	return false
end

function PANEL:OnMouseReleased(x, y, button, istouch, presses)
	--[[
	Called when a mouse release event has been made.

	number x
		The mouse position on the x-axis.
	number y
		The mouse position on the y-axis.
	number dx
		The amount moved along the x-axis since the last time love.mousemoved was called.
	number dy
		The amount moved along the y-axis since the last time love.mousemoved was called.

	Returning true will stop the event from going up the family tree
	Child->Parent->Parent->Parent->etc, etc..
	]]
	
	return false
end

function PANEL:OnMouseWheeled(x, y)
	--[[
	Called when the scrollwheel has been turned.

	number x
		Amount of horizontal mouse wheel movement. Positive values indicate movement to the right.
	number y
		Amount of vertical mouse wheel movement. Positive values indicate upward movement.

	See an example in..
	gui/panels/scrollpanel.lua 
	&
	gui/panels/scrollbar.lua 

	Returning true will stop the event from going up the family tree
	Child->Parent->Parent->Parent->etc, etc..
    ]]

	return false
end

function PANEL:OnChildAdded(panel)
	-- Called when a panel has been added
end

function PANEL:OnRemoved()
	
end

function PANEL:OnChildRemoved(panel)
	-- Called when a panel has been removed
end

function PANEL:Think(dt)
	-- Called every frame
end

function PANEL:OnQuertyTooltip()
	-- Called when the user has hovered over the panel for more than a second
end
