local gui = {
	m_tRegisteredSkins = {},
	m_pWorldPanel = nil,
	m_pTaskBar = nil,
	m_pObjectList = nil,
	m_pSceneDisplay = nil,
	m_pFocusedPanel = nil,
	m_strSkin = "default",
	m_bEditorMode = false,
}

local json = require("serializer.json")
local class = require("class")

function gui.setFocusedPanel(panel)
	gui.m_pFocusedPanel:OnFocusChanged(false)
	gui.m_pFocusedPanel = panel
	gui.m_pFocusedPanel:OnFocusChanged(true)
end

function gui.getFocusedPanel()
	return gui.m_pFocusedPanel
end

function gui.getHoveredPanel()
	return gui.m_pWorldPanel:GetHoveredPanel(love.mouse.getPosition())
end

function gui.saveSceneLayout(file)
	local layout = {}
	for k, child in ipairs(self.m_pSceneDisplay:GetChildren()) do
		layout[k] = child:GetConfig()
	end
end

function gui.loadSceneLayout(file)

end

function gui.resize(w, h)
	gui.getWorldPanel():SizeToScreen()
	gui.getWorldPanel():InvalidateLayout()

	--gui.m_pSceneDisplay:SizeToScreen()
	--gui.m_pWorldPanel:InvalidateLayout()
end

function gui.registerSkin(name, tbl)
	gui.m_tRegisteredSkins[name] = tbl
end

function gui.register(name, tbl, base)
	class.register(name, base)(tbl)
end

function gui.create(name, parent)
	local obj = class.new(name)
	obj:SetParent(parent or gui.m_pSceneDisplay)
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
	if not skin then print(hook, class, "NO SKIN", gui.m_strSkin) return end
	if not skin[hook .. class] then return error(("no function '%s' in skin '%s'"):format(hook .. class, gui.m_strSkin)) end
	skin[hook .. class](skin, panel, ...)
end

function gui.getTaskBar()
	return gui.m_pTaskBar
end

function gui.getWorldPanel()
	return gui.m_pWorldPanel
end

function gui.getScenePanel()
	return gui.m_pSceneDisplay
end

function gui.getObjectPanel()
	return gui.m_pObjectList
end

function gui.joyPressed(joy, but)
	gui.getHoveredPanel():OnJoyPressed(joy, but)
end

function gui.joyReleased(joy, but)
	gui.getHoveredPanel():OnJoyReleased(joy, but)
end

function gui.isInEditorMode()
	return gui.m_bEditorMode
end

function gui.toggleEditorMode()
	gui.m_bEditorMode = not gui.m_bEditorMode

	local world = gui.getWorldPanel()
	local scene = gui.getScenePanel()
	local taskbar = gui.getTaskBar()
	local objects = gui.getObjectPanel()

	local w, h = scene:GetSize()
	local ow, oh, flags = love.window.getMode()

	taskbar:SetVisible(gui.isInEditorMode())
	objects:SetVisible(gui.isInEditorMode())

	if gui.m_bEditorMode then
		scene:DockMargin(4, 4, 4, 4)
		scene:SetBGColor(color_black)
		world:SetBGColor(color(240, 240, 240))

		w = w + 8
		h = h + 8 + taskbar:GetHeight()

		flags.resizable = true
		flags.minwidth = 512 + 8 + objects:GetWidth()
		flags.minheight = 256 + 8 + taskbar:GetHeight()
	else
		scene:DockMargin(0, 0, 0, 0)
		scene:SetBGColor(color_blank)
		world:SetBGColor(color_blank)

		flags.minwidth = 512
		flags.minheight = 256
		flags.resizable = false
	end

	love.window.setMode(w, h, flags)
	world:SizeToScreen()
	world:InvalidateLayout()
end

function gui.keyPressed(key, scancode, isrepeat)
	if key == "escape" and not isrepeat then
		gui.toggleEditorMode()
	end
	gui.m_pFocusedPanel:OnKeyPressed(key, isrepeat)
end

function gui.keyReleased(key)
	gui.m_pFocusedPanel:OnKeyReleased(key)
end

function gui.textInput(text)
	gui.m_pFocusedPanel:OnTextInput(text)
end

function gui.render()
	if gui.m_pWorldPanel then
		gui.m_pWorldPanel:Render()
	end
end

function gui.mousePressed(x, y, but)
	local panel = gui.getHoveredPanel()
	gui.setFocusedPanel(panel)
	local x,y = panel:WorldToLocal(x,y)
	if not panel:OnMousePressed(x, y, but) then
		local parent = panel:GetParent()
		while parent do
			if parent:OnMousePressed(x, y, but) then break end
			parent = parent:GetParent()
		end
	end
end

function gui.mouseReleased(x, y, but)
	local panel = gui.getFocusedPanel()
	local x,y = panel:WorldToLocal(x,y)
	panel:OnMouseReleased(x, y, but)
end

function gui.mouseWheeled(x, y)
	local panel = gui.getFocusedPanel()
	if not panel:OnMouseWheeled(x, y) then
		local parent = panel:GetParent()
		while parent do
			if parent:OnMouseWheeled(x, y) then break end
			parent = parent:GetParent()
		end
	end
end

function gui.tick(dt)
	gui.m_pWorldPanel:ValidateLayout()
	gui.m_pWorldPanel:CallAll("Think", dt)
end

local lfs = love.filesystem

local function loadFilesWithGUIEnv(folder)
	for i, path in ipairs(lfs.getDirectoryItems(folder)) do
		local file = string.format("%s/%s", folder, path)

		if lfs.getInfo(file, "file") then
			local chunk, err = lfs.load(file)
			if err then
				return error(err)
			end
			setfenv(chunk, require("gui.env"))
			chunk()
		end
	end
end

function gui.init()
	gui.loadSkins("modules/gui/skins")
	gui.loadClasses("modules/gui/panels/core")
	gui.loadClasses("modules/gui/panels/smash")

	gui.m_pWorldPanel = gui.create("Panel")
	gui.m_pWorldPanel:DockMargin(0, 0, 0, 0)
	gui.m_pWorldPanel:DockPadding(0, 0, 0, 0)
	gui.m_pWorldPanel:SetBGColor(color_blank)
	gui.m_pWorldPanel:SetBorderColor(color_blank)
	gui.m_pWorldPanel:SizeToScreen()

	gui.m_pFocusedPanel = gui.m_pWorldPanel

	gui.m_pTaskBar = gui.m_pWorldPanel:Add("Panel")
	gui.m_pTaskBar:DockMargin(0, 0, 0, 0)
	gui.m_pTaskBar:DockPadding(0, 0, 0, 0)
	gui.m_pTaskBar:SetBGColor(color(200, 200, 200))
	gui.m_pTaskBar:Dock(DOCK_TOP)
	gui.m_pTaskBar:SetVisible(false)

	gui.m_pObjectList = gui.m_pWorldPanel:Add("Panel")
	gui.m_pObjectList:SetWidth(128 + 32)
	gui.m_pObjectList:Dock(DOCK_LEFT)
	gui.m_pObjectList:SetVisible(false)

	gui.m_pSceneDisplay = gui.m_pWorldPanel:Add("Panel")
	gui.m_pSceneDisplay:DockMargin(0, 0, 0, 0)
	gui.m_pSceneDisplay:DockPadding(0, 0, 0, 0)
	gui.m_pSceneDisplay:SetBGColor(color_blank)
	gui.m_pSceneDisplay:SetBorderColor(color_blank)

	gui.m_pSceneDisplay:SetBGColor(color_blank)
	gui.m_pSceneDisplay:Dock(DOCK_FILL)
end

function gui.loadSkins(folder)
	loadFilesWithGUIEnv(folder)
end

function gui.loadClasses(folder)
	require("gui.panels.base")
	loadFilesWithGUIEnv(folder)
end

return gui