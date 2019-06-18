local gui = require("gui")

DOCK_NONE = 0
DOCK_TOP = 1
DOCK_LEFT = 2
DOCK_BOTTOM = 4
DOCK_RIGHT = 8
DOCK_FILL = 16

local PANEL = {}

local graphics = love.graphics

function PANEL:Initialize()
	self.m_tChildren = {}
	self.m_iPosX = 0
	self.m_iPosY = 0
	self.m_iWidth = 42
	self.m_iHeight = 24
	self.m_bHovered = false
	self.m_pParent = nil
	self.m_iZPos = 0
	self.m_bValidated = false
	self.m_bVisible = true
	self.m_bFocusable = true
	self.m_iDock = 0
	self.m_tDockMargins = { left = 4, top = 4, right = 4, bottom = 4 }
	self.m_tDockPadding = { left = 4, top = 4, right = 4, bottom = 4 }
end

function PANEL:GetClassName()
	return self.__classname
end

function PANEL:__tostring()
	return ("Panel[%q]"):format(self.__classname)
end

function PANEL:GetConfig()
	return {
		classname = self:GetClassName(),
		{
			pos = { self:GetPos() },
			size = { self:GetSize() },
			zpos = self:GetZPos(),
			dock = {
				mode = self.m_iDock,
				margins = self.m_tDockMargins,
				padding = self.m_tDockPadding,
			}
		}
	}
end

function PANEL:SetVisible(b)
	self.m_bVisible = b
end

function PANEL:IsVisible()
	return self.m_bVisible
end

function PANEL:SetFocusable(b)
	self.m_bFocusable = b
end

function PANEL:IsFocusable()
	return self.m_bFocusable
end

function PANEL:BringToFront()
	local parent = self.m_pParent
	if not parent then return end -- There's nothing for it to go in front of!
	
	local highest = 0
	for _,child in ipairs(parent.m_tChildren) do
		if child:GetZPos() > highest then
			highest = child:GetZPos()
		end
	end
	
	if self:GetZPos() > highest then return end
	self:SetZPos(highest + 1)
end

function PANEL:Dock(i)
	self.m_iDock = i
	self:InvalidateLayout()
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

function PANEL:SetZPos(i)
	self.m_iZPos = i
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
	self:SetParent()
	for _,child in ipairs(self.m_tChildren) do
		child:Remove()
	end
	self = nil
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

function PANEL:SetParent(parent)
	if self.m_pParent then
		for key, child in ipairs(self.m_pParent.m_tChildren) do
			if child == self then
				table.remove(self.m_pParent.m_tChildren, key)
				break
			end
		end
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

function PANEL:SizeToChildren(doWidth, doHeight)
	local w,h = 0, 0
	local padding = self:GetDockPadding()
	w = padding.left + padding.right
	h = padding.top + padding.bottom

	local lw, lh = 0, 0

	for _,child in ipairs(self.m_tChildren) do
		if child:IsVisible() then
			local x, y = child:GetPos()
			local margin = child:GetDockMargin()
			local cw, ch = child:GetSize()

			-- Position + size + margins = maximum bounds
			cw = x + cw + margin.left + margin.right
			ch = y + ch + margin.top + margin.bottom

			-- Update the largest widths and heights
			if cw > lw then lw = cw end
			if ch > lh then lh = ch end
		end
	end
	if doWidth then self:SetWide(w + lw) end
	if doHeight then self:SetTall(h + lh) end
end

function PANEL:Add(class)
	return gui.create(class, self)
end

function PANEL:SetPos(x, y)
	self.m_iPosX, self.m_iPosY = x, y
end

function PANEL:GetPos()
	return self.m_iPosX, self.m_iPosY
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
PANEL.LocalToScreen = PANEL.LocalToWorld

function PANEL:WorldToLocal(x, y)
	local sx, sy = self:LocalToScreen(0, 0)
	return x - sx, y - sy
end
PANEL.ScreenToLocal = PANEL.WorldToLocal

function PANEL:SetX(x)
	self.m_iPosX = x
end

function PANEL:GetX()
	return self.m_iPosX
end

function PANEL:SetY(y)
	self.m_iPosY = y
end

function PANEL:GetY()
	return self.m_iPosY
end

function PANEL:SetSize(w, h)
	self.m_iWidth, self.m_iHeight = w, h
end

function PANEL:GetSize()
	return self.m_iWidth, self.m_iHeight
end

function PANEL:SetWide(i)
	self.m_iWidth = i
end
PANEL.SetWidth = PANEL.SetWide

function PANEL:GetWide()
	return self.m_iWidth
end
PANEL.GetWidth = PANEL.GetWide

function PANEL:SetTall(i)
	self.m_iHeight = i
end
PANEL.SetHeight = PANEL.SetTall

function PANEL:GetTall()
	return self.m_iHeight
end
PANEL.GetHeight = PANEL.GetTall

function PANEL:IsWorldPointInside(x, y)
	local px, py = self:LocalToScreen(0, 0)
	return x > px and x < px + self:GetWide() and y > py and y < py + self:GetTall()
end

function PANEL:Render()
	if not self:IsVisible() then return end

	local x, y = self:LocalToScreen(0, 0)
	local w, h = self.m_iWidth, self.m_iHeight
	
	local parent = self:GetParent()
	
	-- Start the scissor position and size with our own values
	local sx, sy = x, y
	local sw, sh = w, h
	
	while parent do
		-- If we have a parent, fit the scissor to fit inside their bounds
		local px, py = parent:LocalToScreen(0, 0)
		local pw, ph = parent:GetSize()
		sx = math.max(sx, px)
		sy = math.max(sy, py)
		sw = math.min(sw, math.max(0, pw - (sx - px)))
		sh = math.min(sh, math.max(0, ph - (sy - py)))
		parent = parent:GetParent()
	end

	graphics.push() -- Push the current graphics state
		graphics.setScissor(sx, sy, sw, sh) -- Set our scissor so things can't be drawn outside the panel
			graphics.translate(x, y) -- Translate so Paint has localized position values for drawing objects
				graphics.setColor(255, 255, 255, 255) -- Default draw color to white
					self:Paint(w, h)
				graphics.setColor(255, 255, 255, 255)
			graphics.translate(0, 0)
		graphics.setScissor()
	graphics.pop() -- Reset the graphics state to what it was

	-- Order by ZPos
	-- smallest to largest, so recently added panels are drawn last, thus, ontop of older panels
	table.sort(self.m_tChildren, function(a, b) return a.m_iZPos < b.m_iZPos end)
	for _,child in ipairs(self.m_tChildren) do
		child:Render()
	end

	-- Debug the scissor rect
	--[[graphics.setColor(255, 0, 0, 25)
	graphics.rectangle("fill", sx, sy, sw, sh)]]
end

function PANEL:ValidateLayout()
	if not self.m_bValidated then
		self.m_bValidated = true
		self:DockLayout()
		self:PerformLayout()
	end

	for _,child in ipairs(self.m_tChildren) do
		child:ValidateLayout()
	end
end

function PANEL:Center(vertical, horizontal)
	local parent = self:GetParent()	

	local w, h = self:GetSize()
	local pw, ph = graphics.getPixelDimensions() -- Default to window size if no parent
	if parent then
		pw, ph = parent:GetSize()
	end

	-- If both vertical and horizontal aren't set, center to both?
	local all = not vertical and not horizontal

	if vertical or all then
		self:SetY((ph / 2) - (h / 2))
	end
	if horizontal or all then
		self:SetX((pw / 2) - (w / 2))
	end
end

function PANEL:CenterVertical()
	self:Center(true, false)
end

function PANEL:CenterHorizontal()
	self:Center(false, true)
end

function PANEL:DockLayout()
	local x, y = 0, 0
	local w, h = self:GetSize()
	
	local padding = self.m_tDockPadding
	
	for _,child in ipairs(self.m_tChildren) do
		local margin = child.m_tDockMargins
	
		local dx = x + padding.left
		local dy = y + padding.top
		local dw = w - (padding.left + padding.right)
		local dh = h - (padding.top + padding.bottom)
	
		local dock = child.m_iDock
		if dock ~= DOCK_NONE and child:IsVisible() then
			if(dock == DOCK_TOP) then
				child:SetPos(dx + margin.left, dy + margin.top)
				child:SetSize(dw - margin.left - margin.right, child:GetHeight())
				local height = margin.top + margin.bottom + child:GetHeight()
				y = y + height
				h = h - height
			elseif(dock == DOCK_LEFT) then
				child:SetPos(dx + margin.left, dy + margin.top)
				child:SetSize(child:GetWidth(), dh - margin.top - margin.bottom)
				local width = margin.left + margin.right + child:GetWidth()
				x = x + width
				w = w - width
			elseif(dock == DOCK_RIGHT) then
				child:SetPos((dx + dw) - child:GetWidth() - margin.right, dy + margin.top)
				child:SetSize(child:GetWide(), dh - margin.top - margin.bottom)
				local width = margin.left + margin.right + child:GetWidth()
				w = w - width
			elseif(dock == DOCK_BOTTOM) then
				child:SetPos(dx + margin.left, (dy + dh) - child:GetHeight() - margin.bottom)
				child:SetSize(dw - margin.left - margin.right, child:GetHeight())
				h = h - (child:GetHeight() + margin.bottom + margin.top)
			end
		end
	end
	
	for _,child in ipairs(self.m_tChildren) do
		local dock = child.m_iDock
		
		if dock ~= DOCK_NONE and child:IsVisible() then
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

function PANEL:HasFocus(recursive)
	if recursive then
		for _,child in ipairs(self.m_tChildren) do
			if child:HasFocus(true) then
				return true
			end
		end
	end
	return gui.FocusedPanel == self
end

function PANEL:IsHovered()
	return gui.getHoveredPanel() == self
end

function PANEL:GetHoveredPanel(x, y)
	table.sort(self.m_tChildren, function(a, b) return a.m_iZPos > b.m_iZPos end) -- The higher up ZPos panel should be first
	local panel = nil
	for _,child in ipairs(self.m_tChildren) do
		if child:IsVisible() and child:IsFocusable() and child:IsWorldPointInside(x, y) then
			panel = child:GetHoveredPanel(x, y)
			break
		end
	end
	table.sort(self.m_tChildren, function(a, b) return a.m_iZPos < b.m_iZPos end) -- Reset
	return panel or self
end

-- PANEL OVERRIDE DEFAULTS

function PANEL:PerformLayout()
	-- Override
end

function PANEL:Paint(w, h)
	-- Override
end

function PANEL:OnFocusChanged(b)
	-- Override
end

function PANEL:OnKeyPressed(key, hex)
	-- Override
end

function PANEL:OnKeyReleased(key)
	-- Override
end

function PANEL:OnTextInput(text)
	-- Override
end

function PANEL:OnJoyPressed(joy, but)
	-- Override
end

function PANEL:OnJoyReleased(joy, but)
	-- Override
end

function PANEL:OnMousePressed(x, y, but)
	-- Override
end

function PANEL:OnMouseReleased(x, y, but)
	-- Override
end

function PANEL:OnMouseWheeled(x, y)
	-- Override
	return false -- Returning false will pass the wheel event to its parent
end

function PANEL:OnChildAdded(panel)
	-- Override
end

function PANEL:OnChildRemoved(panel)
	-- Override
end

function PANEL:Think(dt)
	-- Override
end

gui.register("Base", PANEL)