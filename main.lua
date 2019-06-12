package.path = package.path .. ";modules/?.lua;modules/?/init.lua"
love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";modules/?.lua;modules/?/init.lua")

local watcher = require("memory.watcher")
require("love2d")

local timer = love.timer
local graphics = love.graphics
local newImage = graphics.newImage

function love.load()
	love.window.setTitle("M'Overlay - Waiting for Dolphin.exe..")
	watcher.init()
	graphics.setBackgroundColor(0, 0, 0, 0)
end

local BUTTONS = {
	DPAD_LEFT = 0x0001,
	DPAD_RIGHT = 0x0002,
	DPAD_DOWN = 0x0004,
	DPAD_UP = 0x0008,
	Z = 0x0010,
	R = 0x0020,
	L = 0x0040,
	A = 0x0100,
	B = 0x0200,
	X = 0x0400,
	Y = 0x0800,
	START = 0x1000,
}

function love.update(dt)
	watcher.update("Dolphin.exe")
end

local mask_shader = love.graphics.newShader[[
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
			// a discarded pixel wont be applied as the stencil.
			discard;
		}
		return vec4(1.0);
	}
]]

local BUTTON_TEXTURES = {
	JOYSTICK = {
		GATE = newImage("textures/buttons/joystick-gate.png"),
		MASK = newImage("textures/buttons/joystick-mask.png"),
		STICK = newImage("textures/buttons/joystick-outline.png"),
	},
	CSTICK = {
		GATE = newImage("textures/buttons/c-stick-gate.png"),
		STICK = newImage("textures/buttons/c-stick.png"),
	},
	A = {
		OUTLINE = newImage("textures/buttons/a-outline.png"),
		PRESSED = newImage("textures/buttons/a-pressed.png"),
		COLOR = {0, 225, 150, 255},
		POSITION = {
			x = 12 + 64 + 256,
			y = 64
		}
	},
	B = {
		OUTLINE = newImage("textures/buttons/b-outline.png"),
		PRESSED = newImage("textures/buttons/b-pressed.png"),
		COLOR = {230, 0, 0, 255},
		POSITION = {
			x = 16 + 256,
			y = 108
		}
	},
	X = {
		OUTLINE = newImage("textures/buttons/x-outline.png"),
		PRESSED = newImage("textures/buttons/x-pressed.png"),
		COLOR = {255, 255, 255, 255},
		POSITION = {
			x = 138 + 256,
			y = 48
		}
	},
	Y = {
		OUTLINE = newImage("textures/buttons/y-outline.png"),
		PRESSED = newImage("textures/buttons/y-pressed.png"),
		COLOR = {255, 255, 255, 255},
		POSITION = {
			x = 60 + 256,
			y = 0
		}
	},
	Z = {
		OUTLINE = newImage("textures/buttons/z-outline.png"),
		PRESSED = newImage("textures/buttons/z-pressed.png"),
		COLOR = {165, 75, 165, 255},
		POSITION = {
			x = 128 + 256,
			y = -16
		}
	},
	START = {
		OUTLINE = newImage("textures/buttons/start-outline.png"),
		PRESSED = newImage("textures/buttons/start-pressed.png"),
		COLOR = {255, 255, 255, 255},
		POSITION = {
			x = 256,
			y = 42
		}
	}
}

local MAX_PORTS = 4
local PORT = 0

function love.gameLoaded()
	love.window.setTitle(string.format("M'Overlay - Player %d", PORT + 1))
end

function love.wheelmoved(x, y)
	if not watcher.isReady() then return end

	if y > 0 then
		PORT = PORT - 1
	elseif y < 0 then
		PORT = PORT + 1
	end
	PORT = PORT % MAX_PORTS
	love.gameLoaded()
end

function love.draw()
	local controller = watcher.controller[PORT + 1]

	if controller and controller.plugged ~= 0xFF then
		-- Draw Joystick

		local x, y = controller.joystick.x, 1 - controller.joystick.y

		graphics.setColor(255, 255, 255, 255)

		graphics.stencil(function()
			graphics.setShader(mask_shader)
			graphics.easyDraw(BUTTON_TEXTURES.JOYSTICK.MASK, 24 + (42 * x), 21 + (42 * y), 0, 128, 128, 0, 0)
			graphics.setShader()
		end, "replace", 1)
		graphics.setStencilTest("equal", 0)
			graphics.easyDraw(BUTTON_TEXTURES.JOYSTICK.GATE, 24, 64, 0, 128, 128)
		graphics.setStencilTest()

		graphics.easyDraw(BUTTON_TEXTURES.JOYSTICK.STICK, 24 + (42 * x), 21 + (42 * y), 0, 128, 128, 0, 0)

		-- Draw C-Stick

		local x, y = controller.cstick.x, 1 - controller.cstick.y

		graphics.setColor(255, 235, 0, 255)
		graphics.easyDraw(BUTTON_TEXTURES.CSTICK.GATE, 48 + 128, 64, 0, 128, 128)
		graphics.easyDraw(BUTTON_TEXTURES.CSTICK.STICK, 48 + 128 + (32 * x), 32 + (32 * y), 0, 128, 128, 0, 0)

		graphics.setColor(255, 255, 255, 255)

		-- Draw L Analog

		graphics.setLineStyle("rough")
		love.graphics.setLineWidth(2)

		graphics.rectangle("line", 24 + 14, 32, 100, 8)
		graphics.line(24 + 14 + 92, 32, 24 + 14 + 92, 40)

		graphics.rectangle("fill", 24 + 14, 32, 92 * controller.analog.float.l, 8)

		if bit.band(controller.buttons.pressed, BUTTONS.L) == BUTTONS.L then
			graphics.rectangle("fill", 24 + 14 + 92, 32, 8, 8)
		end

		-- Draw R Analog

		graphics.rectangle("line", 48 + 128 + 14, 32, 100, 8)
		graphics.line(48 + 128 + 14 + 8, 32, 48 + 128 + 14 + 8, 40)

		graphics.rectangle("fill", 48 + 128 + 14 + 8 + (92 * (1 - controller.analog.float.r)), 32, 92 * controller.analog.float.r, 8)

		if bit.band(controller.buttons.pressed, BUTTONS.R) == BUTTONS.R then
			graphics.rectangle("fill", 48 + 128 + 14, 32, 8, 8)
		end

		for button, flag in pairs(BUTTONS) do
			local texture = BUTTON_TEXTURES[button]
			if texture then
				local pos = texture.POSITION
				graphics.setColor(texture.COLOR)
				if bit.band(controller.buttons.pressed, flag) == flag then
					graphics.easyDraw(texture.PRESSED, pos.x, pos.y, 0, 128, 128)
				else
					graphics.easyDraw(texture.OUTLINE, pos.x, pos.y, 0, 128, 128)
				end
			end
		end
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
			love.timer.sleep(1 / FPS_LIMIT- frame_time)
		end
	end
end

function love.quit()
end