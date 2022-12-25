local downloader = require("downloader")

function love.load(args, unfilteredArgs)
	if love.filesystem.mount("application.love", "") then
		package.loaded.ssl = nil
		package.loaded.https = nil
		package.loaded.downloader = nil
		package.loaded.main = nil
		package.loaded.conf = nil
		love.conf = nil
		love.init()
		love.load(args, unfilteredArgs)
	else
		love.install()
	end
end

local STATUS = ""

local DOWNLOAD_SIZE = 0
local DOWNLOADED = 0

function love.install()
	downloader.download(
		"https://github.com/bkacjios/m-overlay/releases/latest/download/application.love",
		"application.love",

		function(event)
			if event.size then
				DOWNLOAD_SIZE = event.size
			elseif event.chunk then
				DOWNLOADED = DOWNLOADED + event.chunk
				STATUS = string.format("Downloading: %d%%", DOWNLOADED/DOWNLOAD_SIZE*100)
			elseif event.code and event.code == 200 then
				print("[UPDATER] Downloaded latest application.love")
				love.event.quit("restart")
			elseif event.error then
				print(string.format("[UPDATER] Update error: %s", event.error))
			end
		end)
end

function love.update(dt)
	downloader.update()
end

do
	local icon = love.graphics.newImage("textures/icon.png")
	local angleStart = math.pi * -0.5
	local angleEnd = math.pi * 2
	local font = love.graphics.newFont(12)

	function love.draw()
		local sw, sh = love.graphics.getPixelDimensions()

		local w  = icon:getWidth()
		local h = icon:getHeight()

		local cx, cy = sw/2, sh/2-(sh/16)

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(icon, cx, cy, 0, 0.5, 0.5, w/2, h/2)

		local downloadAng = angleStart + (angleEnd * (DOWNLOADED/DOWNLOAD_SIZE))

		love.graphics.setColor(34/255, 177/255, 76/255, 1)
		love.graphics.setLineWidth(8)
		love.graphics.arc("line", "open", cx, cy, sw/3, angleStart, downloadAng)

		local width	= font:getWidth(STATUS)
		local sy = sh-8-font:getHeight()

		love.graphics.setFont(font)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.print(STATUS, cx+1, sy+1, 0, 1, 1, width/2)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(STATUS, cx, sy, 0, 1, 1, width/2)
	end
end

function love.quit()
	downloader.close()
end