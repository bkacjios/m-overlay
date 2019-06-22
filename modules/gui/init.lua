local gui = {
	m_tRegisteredSkins = {},
	m_pWorldPanel = nil,
	m_pTaskBar = nil,
	m_pSceneManager = nil,
	m_pFocusedPanel = nil,
	m_strSkin = "default",
	m_bEditorMode = false,
}

DOCK_NONE = 0
DOCK_TOP = 1
DOCK_LEFT = 2
DOCK_BOTTOM = 4
DOCK_RIGHT = 8
DOCK_FILL = 16

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
	for k, child in ipairs(gui.m_pSceneManager:GetDisplay():GetChildren()) do
		layout[k] = child:GetConfig()
	end

	local data = json.encode(layout, true)

	assert(love.filesystem.write(file, data, #data))

	--[[local f, err = io.open(file, "w")
	assert(f, err)

	f:write(data)
	f:close()]]
end

function gui.loadSceneLayout(file)

end

function gui.resize(w, h)
	gui.getWorldPanel():SizeToScreen()
	gui.getWorldPanel():InvalidateLayout()

	--gui.m_pSceneManager:SizeToScreen()
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
	obj:SetParent(parent or gui.m_pWorldPanel)
	return obj
end

function gui.createScenePanel(name)
	return gui.m_pSceneManager:AddToScene(name)
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
	return gui.m_pSceneManager
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

	local w, h = scene:GetDisplay():GetSize()
	local ow, oh, flags = love.window.getMode()

	taskbar:SetVisible(gui.isInEditorMode())

	scene:SetEditorMode(gui.m_bEditorMode)

	if gui.m_bEditorMode then
		w = w + 8
		h = h + 8 + taskbar:GetHeight()

		flags.resizable = true
		flags.minwidth = 512 + 8 + scene:GetObjectList():GetWidth()
		flags.minheight = 256 + 8 + taskbar:GetHeight()
	else
		scene:SetEditorMode(false)
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
	local lx, ly = panel:WorldToLocal(x,y)
	if not panel:OnMousePressed(lx, ly, but) then
		local parent = panel:GetParent()
		while parent do
			lx, ly = parent:WorldToLocal(x, y)
			if parent:OnMousePressed(lx, ly, but) then break end
			parent = parent:GetParent()
		end
	end
end

function gui.mouseReleased(x, y, but)
	local panel = gui.getFocusedPanel()
	local lx, ly = panel:WorldToLocal(x,y)
	if not panel:OnMouseReleased(x, y, but) then
		local parent = panel:GetParent()
		while parent do
			lx, ly = parent:WorldToLocal(x, y)
			if parent:OnMouseReleased(lx, ly, but) then break end
			parent = parent:GetParent()
		end
	end
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

	gui.m_pSceneManager = gui.m_pWorldPanel:Add("SceneEditor")
	gui.m_pSceneManager:Dock(DOCK_FILL)
end

function gui.loadSkins(folder)
	loadFilesWithGUIEnv(folder)
end

function gui.loadClasses(folder)
	require("gui.panels.base")
	loadFilesWithGUIEnv(folder)
end

return gui