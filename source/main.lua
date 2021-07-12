love.filesystem.setRequirePath("?.lua;?/init.lua;modules/?.lua;modules/?/init.lua")

math.randomseed(love.timer.getTime())

-- Read version file and strip any trailing whitespace
local VERSION = love.filesystem.read("version.txt"):match("^(%S+)")

function love.getMOverlayVersion()
	return VERSION or "0.0.0"
end

require("console")
require("errorhandler")
require("extensions.love")

local log = require("log")
local melee = require("melee")
local zce = require("zce")
local memory = require("memory")
local notification = require("notification")

local overlay = require("overlay")
local music = require("music")

local color = require("util.color")
local gui = require("gui")

local ease = require("ease")

local graphics = love.graphics
local newImage = graphics.newImage

local PORT_FONT = graphics.newFont("fonts/melee-bold.otf", 42)
local WAITING_FONT = graphics.newFont("fonts/melee-bold.otf", 24)
local DEBUG_FONT = graphics.newFont("fonts/melee-bold.otf", 12)

local GRADIENT = newImage("textures/gradient.png")
local DOLPHIN = newImage("textures/dolphin.png")
local GAME = newImage("textures/game.png")
local MELEE = newImage("textures/meleedisk.png")
local MELEELABEL = newImage("textures/meleedisklabel.png")
local SHADOW = newImage("textures/shadow.png")

MAX_PORTS = 4

local PORT_DISPLAY_OVERRIDE = nil

local PORT_TEXTURES = {
	[1] = newImage("textures/player1_color.png"),
	[2] = newImage("textures/player2_color.png"),
	[3] = newImage("textures/player3_color.png"),
	[4] = newImage("textures/player4_color.png")
}

local CODE_ENTERED = false

local CODE_POSITION = {
	[1] = 1,
	[2] = 1,
	[3] = 1,
	[4] = 1
}

local CODE = { -- Konami code
	0x0008, 0x0008,
	0x0004, 0x0004,
	0x0001, 0x0002,
	0x0001, 0x0002,
	0x0200, 0x0100, 0x1000
}

--[[local CODE2 = { -- Konami code using joysticks
	0x10000, 0x10000,
	0x20000, 0x20000,
	0x40000, 0x80000,
	0x40000, 0x80000,
	0x0200, 0x0100, 0x1000
}]]

local portless_title = ""
function love.updateTitle(str)
	local title = str
	portless_title = str
	if PANEL_SETTINGS:IsPortTitleEnabled() then
		title = string.format("%s (Port %d)", str, overlay.getPort())
	end
	love.window.setTitle(title)
end

function love.getTitleNoPort()
	return portless_title
end

memory.hook("romstring.akaneia", "Load Game Specific Textures", function(romname, romvalue)
	melee.loadRomSpecificTextures()
end)

function love.load(args, unfilteredArg)
	love.keyboard.setKeyRepeat(true)

	melee.loadTextures()
	gui.init()
	overlay.init()
	music.init()

	if memory.hasPermissions() then
		love.updateTitle("M'Overlay - Waiting for Dolphin...")
	else
		love.updateTitle("M'Overlay - Invalid permissions...")
		--notification.error()
	end

	-- Loop through all the commandline arguments
	for n, arg in pairs(args) do
		 -- Check for '--port=N' first..
		local portn = tonumber(string.match(arg, "%-%-port=(%d+)"))

		if arg == "--port" then -- Alternative '--port N'
			portn = tonumber(args[n+1]) -- Convert the next argument in the commandline to a number
		end

		if portn then -- A port number was specified..
			overlay.setPort(portn)
			break -- Done
		end
	end
end

memory.hook("menu.player_one_port", "Controller port that is acting as player 1", function(port)
	if melee.isSinglePlayerGame() or (memory.menu.major == MENU_VS_UNKNOWN and PANEL_SETTINGS:IsSlippiNetplay()) then
		overlay.setPort(port+1)
		log.debug("[AUTOPORT] Player \"one\" port changed %d", overlay.getPort())
	end
end)

memory.hook("menu.major", "Slippi Auto Port Switcher", function(major)
	if melee.isSinglePlayerGame() or (major == MENU_VS_UNKNOWN and PANEL_SETTINGS:IsSlippiNetplay()) then
		-- Switch back to whatever controller is controlling port 1, when not in a match
		overlay.setPort(memory.menu.player_one_port+1)
		log.debug("[AUTOPORT] Forcing port %d in menus", overlay.getPort())
	end
end)

memory.hook("menu.minor", "Slippi Auto Port Switcher", function(minor)
	-- MENU_VS_UNKNOWN = Slippi online
	if memory.menu.major == MENU_VS_UNKNOWN and PANEL_SETTINGS:IsSlippiNetplay() then
		if minor == MENU_VS_UNKNOWN_CSS or menu == MENU_VS_UNKNOWN_SSS then
			-- Switch back to whatever controller is controlling port 1, when not in a match
			overlay.setPort(memory.menu.player_one_port+1)
			log.debug("[AUTOPORT] Forcing port %d in menus", overlay.getPort())
			if minor == MENU_VS_UNKNOWN_CSS then
				-- Display the port info only when swiching back to CSS
				overlay.showPort(1.5) -- Show the port display number for 1.5 seconds
			end
		elseif minor == MENU_VS_UNKNOWN_VERSUS then
			PORT_DISPLAY_OVERRIDE = (memory.slippi.local_player.index % MAX_PORTS) + 1
			overlay.showPort(3) -- Show the port display number for 3 seconds
			log.debug("[AUTOPORT] Switching display icon to use port %d", overlay.getPort())
		elseif minor == MENU_VS_UNKNOWN_INGAME then
			-- Switch to the local player index whenever else
			PORT_DISPLAY_OVERRIDE = nil
			overlay.setPort(memory.slippi.local_player.index+1)
			log.debug("[AUTOPORT] Switching to slippi local player index %d", overlay.getPort())
		end
	end
end)

memory.hook("player.*.character", "Show port on character select", function(port, character)
	if memory.menu.minor == MENU_VS_CSS and port == overlay.getPort() then
		overlay.showPort(1.5) -- Show the port display number for 1.5 seconds
	end
end)

local snd = love.audio.newSource("sounds/main7b.wav", "static")

memory.hook("controller.*.buttons.pressed", "Konami code check", function(port, pressed)
	if pressed == 0x0 or port ~= overlay.getPort() then return end
	local pos = CODE_POSITION[port]
	if CODE[pos] == pressed then
		CODE_POSITION[port] = pos + 1
		if pos >= #CODE then
			CODE_ENTERED = not CODE_ENTERED
			snd:setVolume(0.25)
			snd:setPitch(CODE_ENTERED and 1 or 0.75)
			snd:play()
			log.warn("[KONAMI] %s developer stats..", CODE_ENTERED and "Showing" or "Hiding")
		end
	else
		CODE_POSITION[port] = 1
	end
end)

function love.update(dt)
	music.update()
	memory.update() -- Look for Dolphin.exe
	notification.update(8, 0)
	gui.update(dt)
end

function love.resize(w, h)
	gui.resize(w, h)
end

function love.joystickpressed(joy, but)
	gui.joyPressed(joy, but)
end

function love.joystickreleased(joy, but)
	gui.joyReleased(joy, but)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" and not isrepeat then
		PANEL_SETTINGS:Toggle()
		PANEL_PORT_SELECT:Toggle()
		PANEL_SKIN_SELECT:Toggle()
	end

	gui.keyPressed(key, scancode, isrepeat)

	local num = tonumber(string.match(key, "kp(%d)") or key)

	if not PANEL_SETTINGS:IsVisible() and num and num >= 1 and num <= 4 then
		overlay.setPort(num)
		PORT_DISPLAY_OVERRIDE = nil
		overlay.showPort(1.5) -- Show the port display number for 1.5 seconds
	end
end

function love.keyreleased(key)
	gui.keyReleased(key)
end

function love.textinput(text)
	gui.textInput(text)
end

function love.mousemoved(x, y, dx, dy, istouch)
	gui.mouseMoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
	gui.mousePressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	gui.mouseReleased(x, y, button, istouch, presses)
end

function love.wheelmoved(x, y)
	if PANEL_SETTINGS:IsVisible() then
		gui.mouseWheeled(x, y)
		return
	end

	local port = overlay.getPort()
	
	if y > 0 then
		port = port - 1
	elseif y < 0 then
		port = port + 1
	end
	overlay.setPort(port)
	overlay.showPort(1.5)
	PORT_DISPLAY_OVERRIDE = nil
end

function love.drawDeveloperInfo()
	local stats = love.graphics.getStats()
	stats.memory = collectgarbage("count")

	graphics.setFont(DEBUG_FONT)
	local i = 0
	for stat, val in pairs(stats) do
		local str

		if stat == "memory" or stat == "texturememory" then
			str = string.format("%s: %s", stat, string.toSize(val))
		else
			str = string.format("%s: %d", stat, val)
		end

		graphics.setColor(0, 0, 0, 255)
		graphics.textOutline(str, 2, 8, 8 + 14 * i)
		graphics.setColor(0, 255, 0, 255)
		graphics.print(str, 8, 8 + 14 * i)

		i = i + 1
	end
end

local DC_CON = newImage("textures/buttons/disconnected.png")

function love.drawControllerOverlay()
	local controller
	local port = overlay.getPort()

	-- Check if ZCE (dynamic controller address swapping)
	if zce.isZce() then
		if zce.isOot() then
			controller = memory.controller.oot[port]
		elseif zce.isMajora() then
			controller = memory.controller.mm[port]
		elseif zce.isZ1() then
			controller = memory.controller.z1[port]
		elseif zce.isZ2() then
			controller = memory.controller.z2[port]
		else
			controller = memory.controller.menu[port]
		end
	else
		controller = memory.controller[port]
	end

	if PANEL_SETTINGS:IsSlippiReplay() and melee.isInGame() then
		local player = memory.player[port]

		if not player then return end

		local entity

		if player.transformed == 256 then
			-- If the player has the "transformed" flag set, assume they are now controlling the "partner" entity
			entity = player.partner
		else
			entity = player.entity
		end
		
		controller = entity.controller
	end

	if controller then
		if controller.plugged and controller.plugged ~= (memory.game.pluggedValue or 0x00) then
			local sin = 128 + math.sin(love.timer.getTime()*2) * 128
			graphics.setColor(255, 0, 0, sin)
			graphics.easyDraw(DC_CON, 512-42-16, 256-42-16, 0, 42, 42)
		end

		overlay.draw(controller)
	end
end

do
	local icon_time_start
	local icon_time_show
	local icon_time_next

	local icon_rotate = 0

	local canvas = love.graphics.newCanvas()

	function love.drawTrobber(game)
		local t = love.timer.getTime()
		local dt = love.timer.getDelta()

		local lx = 0
		local ly = math.sin(t*3) * 4
		local rx = icon_rotate

		local rotate_speed = 0
		
		if not game then
			if not icon_time_start or icon_time_next < t then
				icon_time_start = t
				icon_time_show = t + 1
				icon_time_next = t + 2
			end

			local anim = 0
			if icon_time_show > t then
				anim = ease.sigmoid(math.min(1, (t - icon_time_start)/1))
				lx = ease.lerp(0, -160, anim)
				ly = ease.lerp(0, 64, anim)
				rx = ease.lerp(0, -90, anim)
			else
				anim = ease.outback(math.min(1, (t - icon_time_show)/1))
				lx = ease.lerp(160, 0, anim)
				ly = ease.lerp(64, 0, anim)
				rx = ease.lerp(90, 0, anim)
			end
		else
			rotate_speed = math.sinlerp(0, 360*4*dt/2, t/2)
			icon_rotate = (icon_rotate + rotate_speed) % 360
		end

		graphics.setColor(255, 255, 255, 255)

		graphics.setCanvas(canvas)

		graphics.clear(0,0,0,0)
		if not game then
			graphics.setBlendMode("replace", "premultiplied")
		end

		graphics.setScissor(256-80-20, 0, 160+40, 256)

		local slippi = PANEL_SETTINGS:IsSlippiNetplay() or PANEL_SETTINGS:IsSlippiReplay()
		local icon = game and (slippi and MELEE or GAME) or DOLPHIN

		graphics.setColor(255, 255, 255, 255)
		graphics.easyDraw(icon, 256+lx, 64+40+ly, math.rad(rx), 80, 80, 0.5, 0.5)
		
		if game then
			local p = rotate_speed/13

			for i=0, 16 do
				local j = rotate_speed - i
				graphics.setColor(255, 255, 255, rotate_speed*4)
				graphics.easyDraw(slippi and MELEELABEL or icon, 256+lx, 64+40+ly, math.rad(rx-(i*p*4)), 80, 80, 0.5, 0.5)
			end
		end

		graphics.setScissor()

		if not game then
			graphics.setBlendMode("multiply", "premultiplied")

			graphics.easyDraw(GRADIENT, 256-80-20, 0, 0, 80, 256)
			graphics.easyDraw(GRADIENT, 256+80+20, 0, math.rad(180), 80, 256, 0, 1)
		end

		graphics.setCanvas()

		graphics.setBlendMode("alpha", "alphamultiply")

		if game then
			local sw = math.sinlerp(0.5, 1, t*3)
			graphics.setColor(125, 125, 125, 150)
			graphics.easyDraw(SHADOW, 256, 154, 0, 64*sw, 6*sw, 0.5, 0.5)
		end

		graphics.setColor(255, 255, 255, 255)
		graphics.draw(canvas)
	end
end

do
	local ellipses = {".", "..", "..."}

	function love.drawNotificationText(msg)
		local t = love.timer.getTime()

		local w = WAITING_FONT:getWidth(msg)
		local h = WAITING_FONT:getHeight()
		local x = 256 - (w/2)
		local y = 128+32

		local i = math.floor(t % #ellipses) + 1

		msg = msg .. ellipses[i]

		graphics.setFont(WAITING_FONT)
		graphics.setColor(0, 0, 0, 255)
		graphics.textOutline(msg, 3, x, y)
		graphics.setColor(255, 255, 255, 255)
		graphics.print(msg, x, y)
	end
end

function love.supportsGameCapture()
	return jit.os:lower() == "windows"
end

function love.draw()
	if not love.supportsGameCapture() then
		graphics.setBackgroundColor(100, 100, 100, 255)
	else
		-- Default to completely transparent, makes the overlay completely invisible when not in a game!
		local alpha = 0

		if (memory.initialized and memory.game) or PANEL_SETTINGS:IsVisible() then
			-- Only apply transparency when we are watching a games memory.
			alpha = 255 - ((PANEL_SETTINGS:GetTransparency() / 100) * 255)
		end

		-- Transparent background for OBS
		graphics.setBackgroundColor(0, 0, 0, alpha)

		-- Show a preview for transparency
		if PANEL_SETTINGS:IsVisible() then
			graphics.setBackgroundColor(255, 255, 255, alpha)

			for x=0, 512/32 do
				for y=0, 256/32 do
					graphics.setColor(240, 240, 240, 255)
					graphics.rectangle("fill", 32 * (x + (y%2)), 32 * (y + (x%2)), 32, 32)
				end
			end

			graphics.setColor(0, 0, 0, alpha)
			graphics.rectangle("fill", 0, 0, 512, 256)

			--[[graphics.setColor(0, 0, 0, 100)
			graphics.rectangle("fill", 512 - 20, 0, 20, 256)

			local rad = math.rad(90)

			graphics.setFont(DEBUG_FONT)
			graphics.setColor(0, 0, 0, 255)
			graphics.print(VERSION, 512 - 5, 5, rad)
			graphics.setColor(255, 255, 255, 255)
			graphics.print(VERSION, 512 - 4, 4, rad)]]
		end
	end

	if memory.initialized and memory.game and memory.controller then
		love.drawControllerOverlay()
	else
		if memory.hooked then
			love.drawTrobber(true)
			local slippi = PANEL_SETTINGS:IsSlippiNetplay() or PANEL_SETTINGS:IsSlippiReplay()
			love.drawNotificationText(slippi and "Waiting for melee" or "Waiting for game")
		else
			love.drawTrobber()
			love.drawNotificationText("Waiting for dolphin")
		end
	end

	-- Draw a temporary number to show that the user changed controller port
	if ((PANEL_SETTINGS:AlwaysShowPort() and memory.isInGame()) or overlay.isPortShowing()) then
		local port = overlay.getPort()
		if memory.isMelee() then
			local port = PORT_DISPLAY_OVERRIDE or port
			local portColor
			if melee.isTeams() then
				portColor = melee.getPlayerTeamColor(port)
			else
				portColor = melee.getPlayerColor(port)
			end
			portColor.a = 200
			graphics.setColor(portColor)
			melee.drawSeries(port, 8, 256 - 72 - 4, 0, 72, 72)
			graphics.setColor(255, 255, 255, 255)
			melee.drawStock(port, 40, 256 - 42, 0, 24, 24)
			graphics.easyDraw(PORT_TEXTURES[port], 12, 256 - 42 - 24, 0, 33, 14)
		else
			graphics.setFont(PORT_FONT)
			graphics.setColor(0, 0, 0, 255)
			graphics.textOutline(port, 3, 16, 256 - 42 - 16)
			graphics.setColor(255, 255, 255, 255)
			graphics.print(port, 16, 256 - 42 - 16)
		end
	end

	gui.render()
	notification.draw()
	if CODE_ENTERED then
		love.drawDeveloperInfo()
	end
end

local FPS_LIMIT = 60

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	return function()
		local frame_start = love.timer.getTime()

		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end
 
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
 
			if love.draw then love.draw() end
 
			love.graphics.present()
		end
 
		if love.timer then
			local frame_time = love.timer.getTime() - frame_start
			love.timer.sleep(1 / FPS_LIMIT - frame_time)
		end
	end
end

function love.quit()
	PANEL_SETTINGS:SaveSettings()
	gui.shutdown()
end