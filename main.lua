love.filesystem.setRequirePath("?.lua;?/init.lua;modules/?.lua;modules/?/init.lua")

require("errorhandler")

require("extensions.love2d")
require("util.color")

local watcher = require("memory.watcher")
local gui = require("gui")

local graphics = love.graphics

function love.load()
	graphics.setBackgroundColor(0, 0, 0, 0) -- Transparent background for OBS
	love.window.setTitle("M'Overlay - Waiting for Dolphin.exe")

	gui.init()
	watcher.init()

	local display = gui.createScenePanel("ControllerDisplay")
	display:SetPort(1)

	local test = gui.createScenePanel("Label")
	test:SetFont("fonts/A-OTF-FolkPro-Heavy.otf")
	test:SetBGColor(color_white)
	test:SetText("THIS IS A TEST OVERLAY ELEMENT")
	test:SizeToText()

	local test = gui.createScenePanel("Label")
	test:SetBGColor(color_white)
	test:SetText("Hello world!")
	test:SizeToText()

	gui.saveSceneLayout("test.txt")
end

function love.update(dt)
	gui.tick(dt)
	watcher.update("Dolphin.exe") -- Look for Dolphin.exe
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
	gui.keyPressed(key, scancode, isrepeat)
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
	gui.mouseWheeled(x, y)
end

function love.draw()	
	gui.render()
end

function love.quit()
	gui.shutdown()
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
			love.timer.sleep(1 / FPS_LIMIT- frame_time)
		end
	end
end