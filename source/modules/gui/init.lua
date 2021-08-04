local gui = {
	m_tRegisteredSkins = {},
	m_pWorldPanel = nil,
	m_pHoveredPanel = nil,
	m_pFocusedPanel = nil,
	m_pTooltip = nil,
	m_strSkin = "default",
}

DOCK_NONE = 0
DOCK_TOP = 1
DOCK_LEFT = 2
DOCK_BOTTOM = 4
DOCK_RIGHT = 8
DOCK_FILL = 16

local class = require("class")

require("extensions.table")

function gui.setFocusedPanel(panel)
	gui.m_pFocusedPanel:OnFocusChanged(false)
	gui.m_pFocusedPanel = panel
	gui.m_pFocusedPanel:OnFocusChanged(true)
end

function gui.getFocusedPanel()
	return gui.m_pFocusedPanel
end

function gui.getTooltip()
	return gui.m_pTooltip
end

function gui.setTooltip(title, body)
	gui.m_pTooltip:SetTitle(title)
	gui.m_pTooltip:SetBody(body)
	gui.m_pTooltip:SetPos(gui.getPosAround(gui.m_pHoveredPanel, gui.m_pTooltip))
end

function gui.showTooltip()
	gui.m_pTooltip:SetVisible(true)
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
	if gui.m_pHoveredPanel ~= hovered then
		gui.hideTooltip()

		gui.m_pHoveredPanel:OnHoveredChanged(false)
		gui.m_pHoveredPanel = hovered
		gui.m_pHoveredPanel:OnHoveredChanged(true)

		if gui.m_pHoveredPanel:OnQuertyTooltip() then
			gui.m_fTooltipTimer = love.timer.getTime() + 0.5
		end
	end
end

function gui.getHoveredPanel()
	return gui.m_pHoveredPanel
end

function gui.getMousePosition()
	return gui.getWorldPanel():WorldToLocal(love.mouse.getPosition())
end

function gui.resize(w, h)
	gui.getWorldPanel():SizeToScreen()
	gui.getWorldPanel():InvalidateLayout()
end

function gui.registerSkin(name, tbl)
	gui.m_tRegisteredSkins[name] = tbl
end

function gui.register(name, tbl, base)
	class.register(name, base)(tbl)
end

function gui.create(name, parent)
	local obj = class.new(name)
	obj:SetParent(parent or gui.m_pWorldPanel)
	return obj
end

function gui.setSkin(str)
	gui.m_strSkin = str
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

function gui.getPosAround(panel, other)
	local ow, oh = other:GetPixelSize()

	local px, py = panel:GetWorldPos()
	local pw, ph = panel:GetPixelSize()

	local sx, sy = gui.m_pWorldPanel:GetWorldPos()
	local sw, sh = gui.m_pWorldPanel:GetPixelSize()

	local canFitAbove = (py - sy) >= oh
	local canFitBelow = ((sy + sh) - (py + ph)) >= oh
	local canFitLeft = (px - sx) >= ow
	local canFitRight = ((sx + sw) - (px + pw)) >= ow

	local finalX, finalY = 0, 0

	if canFitAbove or canFitBelow then
		finalX = math.min(sx + sw - ow, math.max(px + pw/2 - ow/2, sx))
		if canFitAbove then
			finalY = py - oh
		else
			finalY = py + ph
		end

		return finalX, finalY
	end

	if canFitLeft or canFitRight then
		finalY = math.min(sy + sh - oh, math.max(py + ph/2 - oh/2, sy))
		if canFitLeft then
			finalX = px - ow
		else
			finalX = px + pw
		end

		return finalX, finalY
	end

	return finalX, finalY
end

function gui.joyPressed(joy, but)
	gui.getHoveredPanel():OnJoyPressed(joy, but)
end

function gui.joyReleased(joy, but)
	gui.getHoveredPanel():OnJoyReleased(joy, but)
end

function gui.keyPressed(key, scancode, isrepeat)
	if key == "escape" and not isrepeat then
	end
	gui.m_pFocusedPanel:OnKeyPressed(key, isrepeat)
	gui.getHoveredPanel():OnHoveredKeyPressed(key, isrepeat)
end

function gui.keyReleased(key)
	gui.m_pFocusedPanel:OnKeyReleased(key)
	gui.getHoveredPanel():OnHoveredKeyReleased(key)
end

function gui.textInput(text)
	gui.m_pFocusedPanel:OnTextInput(text)
	gui.getHoveredPanel():OnHoveredTextInput(text)
end

function gui.render()
	if gui.m_pWorldPanel then
		gui.m_pWorldPanel:Render()
	end
end

function gui.mouseMoved(x, y, dx, dy, istouch)
	gui.updateHoveredPanel()
	local panel = gui.getFocusedPanel()
	local lx, ly = panel:WorldToLocal(x,y)
	if not panel:OnMouseMoved(lx, ly, dx, dy, istouch) then
		local parent = panel:GetParent()
		while parent do
			lx, ly = parent:WorldToLocal(x, y)
			if parent:OnMouseMoved(lx, ly, dx, dy, istouch) then break end
			parent = parent:GetParent()
		end
	end
end

function gui.mousePressed(x, y, button, istouch, presses)
	local panel = gui.getHoveredPanel()
	gui.setFocusedPanel(panel)

	local lx, ly = panel:WorldToLocal(x, y)
	if not panel:OnMousePressed(lx, ly, button, istouch, presses) then
		local parent = panel:GetParent()
		while parent do
			lx, ly = parent:WorldToLocal(x, y)
			if parent:OnMousePressed(lx, ly, button, istouch, presses) then break end
			parent = parent:GetParent()
		end
	end
end

function gui.mouseReleased(x, y, button, istouch, presses)
	local panel = gui.getFocusedPanel()
	local lx, ly = panel:WorldToLocal(x,y)
	if not panel:OnMouseReleased(lx, ly, button, istouch, presses) then
		local parent = panel:GetParent()
		while parent do
			lx, ly = parent:WorldToLocal(x, y)
			if parent:OnMouseReleased(lx, ly, button, istouch, presses) then break end
			parent = parent:GetParent()
		end
	end
end

function gui.mouseWheeled(x, y)
	gui.updateHoveredPanel()

	local panel = gui.getHoveredPanel()
	if not panel:OnMouseWheeled(x, y) then
		local parent = panel:GetParent()
		while parent do
			if parent:OnMouseWheeled(x, y) then break end
			parent = parent:GetParent()
		end
	end
end

function gui.update(dt)
	gui.m_pWorldPanel:ValidateLayout()
	gui.m_pWorldPanel:CallAll("Think", dt)

	if gui.m_fTooltipTimer and gui.m_fTooltipTimer <= love.timer.getTime() and not gui.isToolTipVisible() then
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
	class.init() -- Initialize all classes, sets inheritance

	gui.m_pWorldPanel = gui.create("Panel")
	gui.m_pWorldPanel:DockMargin(0, 0, 0, 0)
	gui.m_pWorldPanel:DockPadding(0, 0, 0, 0)
	gui.m_pWorldPanel:SetBGColor(color_blank)
	gui.m_pWorldPanel:SetBorderColor(color_blank)
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
				local env = table.merge(table.copy(_G), require("gui.env"))

				-- Update the _G variable
				env._G = env

				-- Reset these to a fresh state, since the script will probably use one of them.
				env.PANEL = {}
				env.SKIN = {}

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