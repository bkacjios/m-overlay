local gui = {
	m_tRegisteredSkins = {},
	m_pWorldPanel = nil,
	m_pHoveredPanel = nil,
	m_pFocusedPanel = nil,
	m_pTooltip = nil,
	m_strSkin = "dark",
}

DOCK_NONE = 0
DOCK_TOP = 1
DOCK_LEFT = 2
DOCK_BOTTOM = 4
DOCK_RIGHT = 8
DOCK_FILL = 16

CENTER_NONE = 0
CENTER_VERTICAL = 1
CENTER_HORIZONTAL = 2

local object = require("class.object")

require("extensions.table")

function gui.setFocusedPanel(panel)
	gui.m_pFocusedPanel:OnFocusChanged(false)
	gui.m_pFocusedPanel = panel
	gui.m_pFocusedPanel:SetInteracted(true)
	gui.m_pFocusedPanel:OnFocusChanged(true)
	gui.hideTooltip()
end

function gui.getFocusedPanel()
	return gui.m_pFocusedPanel
end

function gui.getTooltip()
	return gui.m_pTooltip
end

function gui.setTooltip(panel, title, body)
	gui.m_pTooltip:SetTitle(title)
	gui.m_pTooltip:SetBody(body)
	-- Position our tooltip somewhere around the hovered object

	gui.m_pTooltip:SetArrowPos(gui.m_pTooltip:SetPosAround(panel))
end

function gui.showTooltip()
	gui.m_pTooltip:SetVisible(true)
	gui.m_pTooltip:BringToFront()
	gui.m_fTooltipTimer = nil
end

function gui.hideTooltip()
	gui.m_pTooltip:SetVisible(false)
	gui.m_fTooltipTimer = nil
end

function gui.isToolTipVisible()
	return gui.m_pTooltip:IsVisible()
end

function gui.updateHoveredPanel()
	local hovered = gui.m_pWorldPanel:GetHoveredPanel(love.mouse.getPosition())
	local time = love.timer.getTime()

	if gui.m_pHoveredPanel ~= hovered then
		gui.m_pHoveredPanel:OnHoveredChanged(false)
		gui.m_pHoveredPanel:SetInteracted(false)
		gui.m_pHoveredPanel = hovered
		gui.m_pHoveredPanel:OnHoveredChanged(true)

		if not gui.m_pHoveredPanel:IsInteracted() then
			gui.m_fTooltipTimer = nil

			if gui.isToolTipVisible() then
				gui.hideTooltip()
				gui.m_fTooltipTimerCarryOver = time + 0.35
			end

			if gui.m_pHoveredPanel:QueryTooltip() then
				if gui.m_fTooltipTimerCarryOver and gui.m_fTooltipTimerCarryOver >= time then
					gui.showTooltip()
				else
					gui.m_fTooltipTimer = time + 0.75
				end
			end
		end
	end

	local mx, my = love.mouse.getPosition()
	if gui.m_fTooltipTimer and (gui.m_iTooltipMouseX ~= mx or gui.m_iTooltipMouseY ~= my) then
		-- Only start the tooltip timer once the mouse is completely still
		gui.m_fTooltipTimer = time + 0.75
		gui.m_iTooltipMouseX, gui.m_iTooltipMouseY = mx, my
	end
end

function gui.getHoveredPanel()
	return gui.m_pHoveredPanel
end

function gui.getMousePosition()
	return gui.m_pWorldPanel:WorldToLocal(love.mouse.getPosition())
end

function gui.resize(w, h)
	gui.m_pWorldPanel:SizeToScreen()
	gui.m_pWorldPanel:InvalidateLayout()
end

function gui.newSkin(name)
	local tbl = {}
	gui.m_tRegisteredSkins[name] = tbl
	return tbl
end

function gui.create(name, parent)
	local obj = object.new(name)
	obj:SetParent(parent or gui.m_pWorldPanel)
	return obj
end

function gui.setSkin(str)
	gui.m_strSkin = str
	gui.m_pWorldPanel:CallAll("SetAppliedSkin", false)
end

function gui.getSkin()
	return gui.m_strSkin
end

function gui.skinHook(hook, class, panel, ...)
	local skin = gui.m_tRegisteredSkins[gui.m_strSkin]
	if not skin then return end
	if not skin[hook .. class] then return error(("no function '%s' in skin '%s'"):format(hook .. class, gui.m_strSkin)) end
	skin[hook .. class](skin, panel, ...)
end

function gui.getWorldPanel()
	return gui.m_pWorldPanel
end

function gui.joyPressed(joy, but)
	if not gui.m_pFocusedPanel:OnJoyPressed(joy, but) then
		gui.m_pHoveredPanel:OnJoyPressed(joy, but)
	end
end

function gui.joyReleased(joy, but)
	if not gui.m_pFocusedPanel:OnJoyReleased(joy, but) then
		gui.m_pHoveredPanel:OnJoyReleased(joy, but)
	end
end

function gui.keyPressed(key, scancode, isrepeat)
	if not gui.m_pFocusedPanel:OnKeyPressed(key, isrepeat) then
		gui.m_pHoveredPanel:OnKeyPressed(key, isrepeat)
	end
end

function gui.keyReleased(key)
	if not gui.m_pFocusedPanel:OnKeyReleased(key) then
		gui.m_pHoveredPanel:OnKeyReleased(key)
	end
end

function gui.textInput(text)
	if not gui.m_pFocusedPanel:OnTextInput(text) then
		gui.m_pHoveredPanel:OnTextInput(text)
	end
end

do
	local INFO = love.graphics.newImage("textures/gui/information.png")

	function gui.render()
		if gui.m_pWorldPanel then
			gui.m_pWorldPanel:Render()
		end

		--[[local time = love.timer.getTime()
		if gui.m_fTooltipTimer and gui.m_fTooltipTimer > time then
			local mx, my = gui.getMousePosition()
			local start = -90
			local percent = 1-((gui.m_fTooltipTimer-time)/0.75)
			local progress = math.min(math.max(18, percent*360), 345)

			love.graphics.setLineStyle("smooth")
			love.graphics.setLineWidth(2)

			local r = 9

			love.graphics.setColor(color_black)
			love.graphics.circle("line", mx + 9 + r, my, r)
			love.graphics.setColor(color_blue)
			love.graphics.arc("line", mx + 9 + r, my, r, math.rad(start), math.rad(start+progress))
			love.graphics.setColor(color_white)
			love.graphics.easyDraw(INFO, mx + 9, my - r, 0, 18, 18)
		end]]
	end
end

function gui.mouseMoved(x, y, dx, dy, istouch)
	gui.updateHoveredPanel()

	-- We can't use callRecursive here since we localize the mouse x/y values to the current panel
	local panel = gui.getFocusedPanel()

	-- Localize mouse pos
	local lx, ly = panel:WorldToLocal(x,y)
	if not panel:OnMouseMoved(lx, ly, dx, dy, istouch) then
		local parent = panel:GetParent()
		while parent do
			-- Localize mouse pos
			lx, ly = parent:WorldToLocal(x, y)
			if parent:OnMouseMoved(lx, ly, dx, dy, istouch) then break end
			parent = parent:GetParent()
		end
	end
end

local function callRecursive(panel, func, ...)
	if panel then
		local ret = panel[func](panel, ...)
		if not ret then
			return callRecursive(panel:GetParent(), func, ...)
		else
			gui.hideTooltip()
			panel:SetInteracted(true)
			return ret
		end
	end
end

function gui.mousePressed(x, y, button, istouch, presses)
	local panel = gui.m_pHoveredPanel
	gui.setFocusedPanel(panel)

	local lx, ly = gui.m_pFocusedPanel:WorldToLocal(x,y)

	if not callRecursive(gui.m_pFocusedPanel, "OnMousePressed", lx, ly, button, istouch, presses) then
		lx, ly = gui.m_pHoveredPanel:WorldToLocal(x,y)
		callRecursive(gui.m_pHoveredPanel, "OnMousePressed", lx, ly, button, istouch, presses)
	end

	--[[local lx, ly = panel:WorldToLocal(x, y)
	if not panel:OnMousePressed(lx, ly, button, istouch, presses) then
		local parent = panel:GetParent()
		while parent do
			lx, ly = parent:WorldToLocal(x, y)
			if parent:OnMousePressed(lx, ly, button, istouch, presses) then break end
			parent = parent:GetParent()
		end
	end]]
end

function gui.mouseReleased(x, y, button, istouch, presses)
	local panel = gui.getFocusedPanel()
	local lx, ly = panel:WorldToLocal(x,y)

	if not callRecursive(gui.m_pFocusedPanel, "OnMouseReleased", lx, ly, button, istouch, presses) then
		lx, ly = gui.m_pHoveredPanel:WorldToLocal(x,y)
		callRecursive(gui.m_pHoveredPanel, "OnMouseReleased", lx, ly, button, istouch, presses)
	end

	--[[if not panel:OnMouseReleased(lx, ly, button, istouch, presses) then
		local parent = panel:GetParent()
		while parent do
			lx, ly = parent:WorldToLocal(x, y)
			if parent:OnMouseReleased(lx, ly, button, istouch, presses) then break end
			parent = parent:GetParent()
		end
	end]]
end

function gui.mouseWheeled(x, y)
	gui.updateHoveredPanel()
	if not callRecursive(gui.m_pFocusedPanel, "OnMouseWheeled", x, y) then
		callRecursive(gui.m_pHoveredPanel, "OnMouseWheeled", x, y)
	end
end

function gui.update(dt)
	gui.m_pWorldPanel:ValidateLayout()
	gui.m_pWorldPanel:CallAllVisible("Think", dt)
	gui.m_pWorldPanel:CallAllVisible("ApplySkin")

	local time = love.timer.getTime()

	if gui.m_fTooltipTimer and gui.m_fTooltipTimer <= time and not gui.isToolTipVisible() then
		gui.showTooltip()
	end

	gui.m_pWorldPanel:CleanupOrphans()
	gui.m_pWorldPanel:CleanupDeleted()
end

function gui.shutdown()
end

function gui.init()
	gui.loadSkins("modules/gui/skins")
	gui.loadClasses("modules/gui/panels")

	gui.m_pWorldPanel = gui.create("BasePanel")
	gui.m_pWorldPanel:DockMargin(0, 0, 0, 0)
	gui.m_pWorldPanel:DockPadding(0, 0, 0, 0)
	gui.m_pWorldPanel:SizeToScreen()
	gui.m_pWorldPanel:InvalidateLayout()
	gui.m_pWorldPanel:ValidateLayout()

	gui.m_pTooltip = gui.create("ToolTip")
	gui.m_pTooltip:SetZPos(math.huge) -- Always on top
	gui.m_pTooltip:SetVisible(false)

	gui.m_pHoveredPanel = gui.m_pWorldPanel
	gui.m_pFocusedPanel = gui.m_pWorldPanel
end

do
	local lfs = love.filesystem

	local function loadFilesWithGUIEnv(folder)
		for i, path in ipairs(lfs.getDirectoryItems(folder)) do
			local file = string.format("%s/%s", folder, path)

			if lfs.getInfo(file, "file") then
				local chunk, err = lfs.load(file)
				if err then
					return error(err)
				end

				-- Create a copy of our Lua environment, and merge it with some helper functions
				local env = table.merge(require("gui.env"), _G)

				-- Update the _G variable
				env._G = env

				-- Set the environment to our copy of the global environment
				setfenv(chunk, env)
				chunk() -- Execute the file
			end
		end
	end

	function gui.loadSkins(folder)
		loadFilesWithGUIEnv(folder)
	end

	function gui.loadClasses(folder)
		loadFilesWithGUIEnv(folder)
	end
end

return gui