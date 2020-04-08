local gui = {
	m_tRegisteredSkins = {},
	m_pWorldPanel = nil,
	m_pSceneManager = nil,
	m_pFocusedPanel = nil,
	m_strSkin = "default",
	m_bEditorMode = false,
	m_tOrphans = {},
	m_tDeleted = {},
}

DOCK_NONE = 0
DOCK_TOP = 1
DOCK_LEFT = 2
DOCK_BOTTOM = 4
DOCK_RIGHT = 8
DOCK_FILL = 16

local json = require("serializer.json")
local class = require("class")
local nfd = require("nfd")

require("extensions.table")

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

function gui.newSceneLayout()
	
end

function gui.openSceneLayout()
	local file = nfd.open("json", "layout.json")

	if not file then return end

	local f, err = io.open(file, "r")
	assert(f, err)
	local layout = json.decode(f:read("*all"))
	f:close()

	print(table.tostring(layout))
	gui.loadConfig(layout)
end

function gui.getDefaultConfig()
	return {
		width = 512,
		height = 256,
		layout = {
			{
				classname = "ControllerDisplay",
				pos = {
					x = 0,
					y = 0,
					z = 1
				},
				size = {
					height = 256,
					width = 512
				},
				visible = true,
				accessors = {
					m_iPort = 1
				},
				scale = {
					x = 1,
					y = 1
				}
			}
		}
	}
end

function gui.loadConfig(config)
	local canvas = gui.getScenePanel():GetDisplay()
	canvas:Clear()
	canvas:SetSize(config.width, config.height)

	for i, panel in ipairs(config.layout) do
		local p = gui.createScenePanel(panel.classname)
		p:SetPos(panel.pos.x, panel.pos.y)
		p:SetZPos(panel.pos.z)
		p:SetSize(panel.size.width, panel.size.height)
		p:SetVisible(panel.visible)
		p:SetScale(panel.scale.x, panel.scale.y)
		for key, value in pairs(panel.accessors) do
			p.__accessors[key] = value
		end
	end
end

function gui.saveSceneLayout()
	local file = nfd.save("json", "layout.json")

	if not file then return end

	local canvas = gui.getScenePanel():GetDisplay()

	local config = {
		width = canvas:GetWidth(),
		height = canvas:GetHeight(),
		layout = {}
	}

	for k, child in ipairs(gui.m_pSceneManager:GetDisplay():GetChildren()) do
		config.layout[k] = child:GetConfig()
	end

	local data = json.encode(config, true)

	--assert(love.filesystem.write(file, data, #data))

	local f, err = io.open(file, "w")
	assert(f, err)

	f:write(data)
	f:close()
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
	if not skin then return end
	if not skin[hook .. class] then return error(("no function '%s' in skin '%s'"):format(hook .. class, gui.m_strSkin)) end
	skin[hook .. class](skin, panel, ...)
end

function gui.getInfoBar()
	return gui.m_pInfoBar
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
	-- Toggle editor mode
	gui.m_bEditorMode = not gui.m_bEditorMode

	local scene = gui.getScenePanel()

	-- Get the size of the display canvas
	local w, h = scene:GetDisplay():GetSize()

	-- Get the original window size and flags
	local ow, oh, flags = love.window.getMode()

	scene:SetEditorMode(gui.m_bEditorMode)

	local uw, uh = scene:GetUnusableSpace()

	-- Resize min/max bounds and toggle resizing
	flags.resizable = gui.m_bEditorMode

	if gui.m_bEditorMode then
		-- Readjust the window size to fit the taskbars and stuff
		w, h = w + uw, h + uh
		
		-- Minimum size we will allow
		flags.minwidth = 512 + uw
		flags.minheight = 256 + uh
	else
		flags.minwidth = w
		flags.minheight = h
	end

	love.window.setMode(w, h, flags)

	local world = gui.getWorldPanel()
	world:SizeToScreen()
	world:InvalidateLayout()
	world:ValidateLayout()
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

function gui.mouseMoved(x, y, dx, dy, istouch)
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
	local panel = gui.getHoveredPanel()
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
	gui.m_pWorldPanel:CleanupOrphans()
	gui.m_pWorldPanel:CleanupDeleted()
end

function gui.shutdown()
	-- TODO: Save layout of SceneDisplay GUI
end

function gui.init()
	gui.loadSkins("modules/gui/skins")
	gui.loadClasses("modules/gui/panels/core")
	gui.loadClasses("modules/gui/panels/editor")
	gui.loadClasses("modules/gui/panels/smash")
	class.init() -- Initialize all classes, sets inheritance

	gui.m_pWorldPanel = gui.create("Panel")
	gui.m_pWorldPanel:DockMargin(0, 0, 0, 0)
	gui.m_pWorldPanel:DockPadding(0, 0, 0, 0)
	gui.m_pWorldPanel:SetBGColor(color_blank)
	gui.m_pWorldPanel:SetBorderColor(color_blank)
	gui.m_pWorldPanel:SizeToScreen()

	gui.m_pFocusedPanel = gui.m_pWorldPanel

	gui.m_pSceneManager = gui.m_pWorldPanel:Add("SceneEditor")
	gui.m_pSceneManager:Dock(DOCK_FILL)
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
		require("gui.panels.base")
		loadFilesWithGUIEnv(folder)
	end
end

return gui