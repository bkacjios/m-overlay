local overlay = {
	m_tRegisteredSkins = {},
	m_fDisplayPortTime = 0,
}

local gui = require("gui")
local timer = love.timer

function overlay.init()
	PANEL_PORT_SELECT = gui.create("PortSelect")
	PANEL_PORT_SELECT:SetVisible(false)

	PANEL_SKIN_SELECT = gui.create("SkinSelect")
	PANEL_SKIN_SELECT:SetVisible(false)

	PANEL_SETTINGS = gui.create("Settings")
	PANEL_SETTINGS:SetVisible(false)

	overlay.loadSkins("overlay/skins")

	PANEL_SKIN_SELECT:UpdateSkins()
	
	PANEL_SETTINGS:LoadSettings()
end

function overlay.showPort(time)
	overlay.m_fDisplayPortTime = timer.getTime() + time
end

function overlay.isPortShowing()
	return overlay.m_fDisplayPortTime >= timer.getTime()
end

function overlay.getPort()
	return PANEL_PORT_SELECT:GetPort()
end

function overlay.setPort(port)
	PANEL_PORT_SELECT:ChangePort(((port-1) % MAX_PORTS) + 1)
end

function overlay.getSkin()
	return PANEL_SKIN_SELECT:GetSkin()
end

function overlay.setSkin(skin)
	return PANEL_SKIN_SELECT:ChangeSkin(skin)
end

function overlay.draw(controller)
	overlay.call("Paint", controller)
end

function overlay.call(func, controller, ...)
	local name = overlay.getSkin()
	local skin = overlay.m_tRegisteredSkins[name]
	if not skin then return end
	if not skin[func] then return error(("no function '%s' in skin '%s'"):format(func, name)) end
	skin[func](skin, controller, ...)
end

function overlay.registerSkin(name, tbl)
	overlay.m_tRegisteredSkins[name] = tbl
end

function overlay.getSkins()
	return overlay.m_tRegisteredSkins
end

do
	local lfs = love.filesystem

	function overlay.loadSkins(folder)
		for i, path in ipairs(lfs.getDirectoryItems(folder)) do
			local file = string.format("%s/%s", folder, path)

			if lfs.getInfo(file, "file") then
				local chunk, err = lfs.load(file)
				if err then
					return error(err)
				end

				-- Create a copy of our Lua environment, and merge it with some helper functions
				local env = table.merge(table.copy(_G), require("overlay.env"))

				-- Update the _G variable
				env._G = env

				-- Reset these to a fresh state, since the script will probably use one of them.
				env.SKIN = {}

				-- Set the environment to our copy of the global environment
				setfenv(chunk, env)
				chunk() -- Execute the file
			end
		end
	end
end

return overlay