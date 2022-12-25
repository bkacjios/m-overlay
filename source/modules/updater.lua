local updater = {}

local log = require("log")
local web = require("web")

local downloader = require("downloader")

local json = require("serializer.json")

local DOWNLOAD_SIZE = 0
local DOWNLOADED = 0

local STATUS = ""

local function versionNumber(tag)
	-- Split into: major, minor, revision, hotfix
	if not tag then
		return -1
	end
	local maj, min, rev, hot = tag:lower():match("v?(%d+)%.(%d+)%.(%d+)(%a?)")
	if not maj then
		return -1
	end
	local hotfix = 0
	if hot and #hot > 0 then
		-- 97 = a
		hotfix = string.byte(hot) - 96
	end
	return (tonumber(maj) * 10000) + (tonumber(min) * 1000) + (tonumber(rev) * 100) + hotfix
end

do
	local icon = love.graphics.newImage("textures/icon.png")
	local angleStart = math.pi * -0.5
	local angleEnd = math.pi * 2
	local font = love.graphics.newFont("fonts/melee.otf", 12)

	function updater.draw(sw, sh)
		local w  = icon:getWidth()
		local h = icon:getHeight()

		local cx, cy = sw/2, sh/2-(sh/16)

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(icon, cx, cy, 0, 0.5, 0.5, w/2, h/2)

		local downloadAng = angleStart + (angleEnd * (DOWNLOADED/DOWNLOAD_SIZE))

		love.graphics.setColor(34, 177, 76, 255)
		love.graphics.setLineWidth(8)
		love.graphics.arc("line", "open", cx, cy, sw/3, angleStart, downloadAng)

		local width	= font:getWidth(STATUS)
		local sy = sh-font:getHeight()

		love.graphics.setFont(font)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print(STATUS, cx+1, sy+1, 0, 1, 1, width/2)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print(STATUS, cx, sy, 0, 1, 1, width/2)
	end
end

function updater.check()
	local version = versionNumber(love.getMOverlayVersion())

	if version <= 0 then return end

	STATUS = "Checking for update.."

	web.get("https://api.github.com/repos/bkacjios/m-overlay/releases/latest", function(event)
		if event.success and event.code == 200 then
			local response = json.decode(event.response)
			if (response.tag_name) then
				local updateVersion = versionNumber(response.tag_name)
				if updateVersion > 0 and updateVersion > version then
					log.warn("[UPDATER] Application update available")
					for id, asset in pairs(response.assets) do
						if asset.name == "application.love" then
							log.info("[UPDATER] Download: %s", asset.browser_download_url)
							DOWNLOAD_SIZE = 0
							DOWNLOADED = 0
							downloader.download(asset.browser_download_url, asset.name, function(event)
								if event.size then
									DOWNLOAD_SIZE = event.size
								elseif event.chunk then
									DOWNLOADED = DOWNLOADED + event.chunk
									STATUS = string.format("Downloading: %d%%", DOWNLOADED/DOWNLOAD_SIZE*100)
								elseif event.code and event.code == 200 then
									log.error("[UPDATER] Updated to version %s", response.tag_name)
									love.event.quit("restart")
								elseif event.error then
									log.error("[UPDATER] Update error: %s", event.error)
								end
							end)
							return
						end
					end
				else
					log.info("[UPDATER] Application is up-to-date")
					STATUS = "No update required"
				end
			end
		else
			log.error("[UPDATER] Failed to get latest release information: %s", event.code)
			STATUS = string.format("Update error: %d", event.code)
		end
	end)
end

return updater