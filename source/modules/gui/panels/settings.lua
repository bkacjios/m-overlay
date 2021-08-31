local PANEL = class.create("Settings", "Panel")

local log = require("log")
local json = require("serializer.json")
local notification = require("notification")
local music = require("music")
local overlay = require("overlay")

require("extensions.math")

SLIPPI_OFF = 1
SLIPPI_NETPLAY = 2
SLIPPI_REPLAY = 3

LOOPING_NONE = 0
LOOPING_MENU = 1
LOOPING_STAGE_TIMED = 2
LOOPING_STAGE_ENDLESS = 4

function PANEL:OnMouseMoved(x, y, dx, dy, istouch)
	local px, py = self.MAIN:GetPos()
	local pw, ph = self.MAIN:GetSize()

	if x < px or x > px + pw then
		self.MAIN:UnCenter()
		self.MAIN:SetPos(px, 256-24)
	else
		self.MAIN:Center()
	end
	
end

function PANEL:Settings()
	self:super() -- Initialize our baseclass

	self:DockMargin(0, 0, 0, 0)
	self:SizeToScreen()
	self:SetBackgroundColor(color_blank)
	self:SetBorderColor(color_blank)

	self.PORTSELECT = self:Add("PortSelect")
	self.SKINSELECT = self:Add("SkinSelect")

	self.COLORSELECT = self:Add("ColorSelector")
	self.COLORSELECT:SetSize(296 + 32, 256)
	self.COLORSELECT:Center()
	self.COLORSELECT:SetVisible(false)

	self.MAIN = self:Add("TabbedPanel")
	self.MAIN:SizeToParent()
	self.MAIN:SetSize(296 + 32, 196)
	self.MAIN:DockPadding(0, 0, 0, 0)
	self.MAIN:Center()

	self.GENERAL = self.MAIN:AddTab("General", "textures/gui/cog.png", true)

	self.GENERAL.LEFT = self.GENERAL:Add("Panel")
	self.GENERAL.LEFT:SetWidth(160)
	self.GENERAL.LEFT:Dock(DOCK_LEFT)
	self.GENERAL.LEFT:SetDrawPanel(false)

	self.GENERAL.RIGHT = self.GENERAL:Add("Panel")
	self.GENERAL.RIGHT:SetWidth(160)
	self.GENERAL.RIGHT:Dock(DOCK_RIGHT)
	self.GENERAL.RIGHT:SetDrawPanel(false)

	self.MELEE = self.MAIN:AddTab("Melee", "textures/gui/melee.png")

	self.MELEE.LEFT = self.MELEE:Add("Panel")
	self.MELEE.LEFT:SetWidth(160)
	self.MELEE.LEFT:Dock(DOCK_LEFT)
	self.MELEE.LEFT:SetDrawPanel(false)

	self.MELEE.RIGHT = self.MELEE:Add("Panel")
	self.MELEE.RIGHT:SetWidth(160)
	self.MELEE.RIGHT:Dock(DOCK_RIGHT)
	self.MELEE.RIGHT:SetDrawPanel(false)

	self.SLIPPI = self.MAIN:AddTab("Slippi", "textures/gui/slippi.png")

	self.SLIPPI.ICON = self.SLIPPI:Add("Image")
	self.SLIPPI.ICON:SetImage("textures/slippi.png")
	self.SLIPPI.ICON:SetPos(4, 0)
	self.SLIPPI.ICON:SetSize(155, 112)
	self.SLIPPI.ICON:CenterVertical()

	self.SLIPPI.LEFT = self.SLIPPI:Add("Panel")
	self.SLIPPI.LEFT:SetWidth(160)
	self.SLIPPI.LEFT:Dock(DOCK_LEFT)
	self.SLIPPI.LEFT:SetDrawPanel(false)

	self.SLIPPI.RIGHT = self.SLIPPI:Add("Panel")
	self.SLIPPI.RIGHT:SetWidth(160)
	self.SLIPPI.RIGHT:Dock(DOCK_RIGHT)
	self.SLIPPI.RIGHT:SetDrawPanel(false)

	self.SLIPPI.MODE = self.SLIPPI.RIGHT:Add("RadioPanel")
	self.SLIPPI.MODE:SetText("Slippi mode")
	self.SLIPPI.MODE:DockMargin(0,0,0,0)
	self.SLIPPI.MODE:Dock(DOCK_FILL)
	self.SLIPPI.MODE:SetWidth(100)

	local off = self.SLIPPI.MODE:AddOption(SLIPPI_OFF, "Off: Other games", true)
	off:SetTooltipParent(self.SLIPPI.MODE)
	off:SetTooltipTitle("OFF: OTHER GAMES")
	off:SetTooltipBody([[Use normal game detection. Supported game list can be found on the github README.]])
	local netplay = self.SLIPPI.MODE:AddOption(SLIPPI_NETPLAY, "Melee: Rollback")
	netplay:SetTooltipParent(self.SLIPPI.MODE)
	netplay:SetTooltipTitle("ROLLBACK")
	netplay:SetTooltipBody([[Allows the overlay to work properly when playing Slippi online. Will also actively change the overylay to display your current port.

WARNING: This tricks M'Overlay into thinking Melee is being played when an invalid game is detected. When playing other games, it is recommended to set this to OFF.]])
	local mirror = self.SLIPPI.MODE:AddOption(SLIPPI_REPLAY, "Melee: Replay/Mirror")
	mirror:SetTooltipParent(self.SLIPPI.MODE)
	mirror:SetTooltipTitle("REPLAY/MIRROR")
	mirror:SetTooltipBody([[Allows the overlay to work when viewing replays or mirroring gameplay from a console.]])

	self.SLIPPI.MODE.OnSelectOption = function(this, num)
		self.SLIPPI.ICON:SetImage(num == SLIPPI_OFF and "textures/slippi.png" or "textures/slippi_filled.png")
	end

	self.MELEE.MUSIC = self.MELEE.LEFT:Add("CheckBox")
	self.MELEE.MUSIC:SetText("Enable music")
	self.MELEE.MUSIC:Dock(DOCK_TOP)
	self.MELEE.MUSIC:SetTooltipTitle("MELEE MUSIC")
	self.MELEE.MUSIC:SetTooltipBody([[Enable/Disable custom music for Melee.]])

	function self.MELEE.MUSIC:OnToggle(on)
		if on then
			music.onStateChange()
		else
			music.kill()
		end
	end

	self.MELEE.MUSICLOOP = self.MELEE.RIGHT:Add("CheckPanel")
	self.MELEE.MUSICLOOP:SetText("Loop on..")
	self.MELEE.MUSICLOOP:DockMargin(0,0,0,0)
	self.MELEE.MUSICLOOP:Dock(DOCK_TOP)
	self.MELEE.MUSICLOOP:SetWidth(100)

	local menu = self.MELEE.MUSICLOOP:AddOption(LOOPING_MENU, "Menu")
	menu:SetTooltipParent(self.MELEE.MUSICLOOP)
	menu:SetTooltipTitle("LOOP MENU")
	menu:SetTooltipBody([[When entering the menus, it will select and play one song at random.

When the song ends or reaches a loop point, it will play again.]])
	local stage_timed = self.MELEE.MUSICLOOP:AddOption(LOOPING_STAGE_TIMED, "Stage (timed)")menu:SetTooltipParent(self.MELEE.MUSICLOOP)
	stage_timed:SetTooltipTitle("LOOP STAGE (TIMED)")
	stage_timed:SetTooltipBody([[When entering a stage that has a timer, it will select and play one song at random.

When the song ends or reaches a loop point, it will play again.]])
	local stage_endless = self.MELEE.MUSICLOOP:AddOption(LOOPING_STAGE_ENDLESS, "Stage (endless)")
	stage_endless:SetTooltipTitle("LOOP STAGE (ENDLESS)")
	stage_endless:SetTooltipBody([[When entering a stage that is endless, such as training mode or endless melee, it will select and play one song at random.

When the song ends or reaches a loop point, it will play again.]])
	
	
	function self.MELEE.MUSICLOOP:OnValueChanged(flags)
		music.onLoopChange(flags)
	end
	
	self.MELEE.MUSICSKIP = self.MELEE.LEFT:Add("GCBinderPanel")
	self.MELEE.MUSICSKIP:SetText("Skip track combo")
	self.MELEE.MUSICSKIP:Dock(DOCK_TOP)
	self.MELEE.MUSICSKIP:SetTooltipTitle("SKIP TRACK COMBO")
	self.MELEE.MUSICSKIP:SetTooltipBody([[This button will allow you to a set a button combination on your controller to skip the currently playing music track.

NOTE: This button is only usable when in a supported game.]])

	self.MELEE.VOLUME = self.MELEE.LEFT:Add("SliderPanel")
	self.MELEE.VOLUME:SetValue(50)
	self.MELEE.VOLUME:Dock(DOCK_BOTTOM)
	self.MELEE.VOLUME:DockMargin(0,0,0,0)
	self.MELEE.VOLUME:SetTooltipTitle("VOLUME")
	self.MELEE.VOLUME:SetTooltipBody([[Adjust the volume of the music.]])
	self.MELEE.VOLUME:SetTextFormat("Volume: %d%%")

	function self.MELEE.VOLUME:OnValueChanged(i)
		music.setVolume(i)
	end

	self.PORTTITLE = self.GENERAL.LEFT:Add("CheckBox")
	self.PORTTITLE:SetText("Port in title")
	self.PORTTITLE:Dock(DOCK_TOP)
	self.PORTTITLE:SetTooltipTitle("PORT IN TITLE")
	self.PORTTITLE:SetTooltipBody([[Show the current port number being displayed in the application title.]])

	self.ALWAYSPORT = self.GENERAL.LEFT:Add("CheckBox")
	self.ALWAYSPORT:SetText("Always show port")
	self.ALWAYSPORT:Dock(DOCK_TOP)
	self.ALWAYSPORT:SetTooltipTitle("ALWAYS SHOW PORT")
	self.ALWAYSPORT:SetTooltipBody([[Always show the current port in the bottom left of the overlay window.]])

	function self.PORTTITLE:OnToggle()
		love.updateTitle(love.getTitleNoPort())
	end

	self.DPAD = self.GENERAL.RIGHT:Add("CheckBox")
	self.DPAD:SetText("Show D-Pad")
	self.DPAD:Dock(DOCK_TOP)
	self.DPAD:SetTooltipTitle("DIRECTIONAL-PAD")
	self.DPAD:SetTooltipBody([[Enable/disable the directional pad on the overlay.]])

	self.START = self.GENERAL.RIGHT:Add("CheckBox")
	self.START:SetText("Show Start")
	self.START:Dock(DOCK_TOP)
	self.START:SetTooltipTitle("START BUTTON")
	self.START:SetTooltipBody([[Enable/disable the start button on the overlay.]])

	self.HIGH_CONTRAST = self.GENERAL.RIGHT:Add("CheckBox")
	self.HIGH_CONTRAST:SetText("High-contrast")
	self.HIGH_CONTRAST:Dock(DOCK_TOP)
	self.HIGH_CONTRAST:SetTooltipTitle("HIGH-CONTRAST")
	self.HIGH_CONTRAST:SetTooltipBody([[All buttons and joystick-gates with be filled with black for better viewing visibility.

20XX theme is unsupported]])

	self.USE_TRANASPARENCY = self.GENERAL.RIGHT:Add("CheckBox")
	self.USE_TRANASPARENCY:SetVisible(love.supportsGameCapture())
	self.USE_TRANASPARENCY:SetToggled(true)
	self.USE_TRANASPARENCY:SetText("Use transparency")
	self.USE_TRANASPARENCY:Dock(DOCK_TOP)
	self.USE_TRANASPARENCY:SetTooltipTitle("USE TRANSPARENCY")
	self.USE_TRANASPARENCY:SetTooltipBody([[Use a "transparent" background that will allow OBS to capture this panel and mask out the background.

This will only function correctly if you are capturing this window in OBS with a "Game Capture" element with transparency enabled.]])

	self.USE_TRANASPARENCY.OnToggle = function(this, on)
		self.TRANSPARENCY:SetVisible(on)
		self.BACKGROUNDCOLOR:SetVisible(not on)
	end

	self.TRANSPARENCY = self.GENERAL.RIGHT:Add("SliderPanel")
	self.TRANSPARENCY:SetVisible(love.supportsGameCapture())
	self.TRANSPARENCY:SetValue(100)
	self.TRANSPARENCY:Dock(DOCK_BOTTOM)
	self.TRANSPARENCY:DockMargin(0,0,0,0)
	self.TRANSPARENCY:SetTooltipTitle("TRANSPARENCY")
	self.TRANSPARENCY:SetTooltipBody([[Adjust how transparent the overlay is.

This will only function correctly if you are capturing this window in OBS with a "Game Capture" element with transparency enabled.]])
	self.TRANSPARENCY:SetTextFormat("Transparency - %d%%")

	self.BACKGROUNDCOLOR = self.GENERAL.RIGHT:Add("ColorButton")
	self.BACKGROUNDCOLOR:SetText("Background color")
	self.BACKGROUNDCOLOR:Dock(DOCK_BOTTOM)
	self.BACKGROUNDCOLOR:SetVisible(not self.USE_TRANASPARENCY:IsVisible())
	self.BACKGROUNDCOLOR:SetColor(color(34, 34, 34))
	self.BACKGROUNDCOLOR:SetTooltipTitle("BACKGROUND COLOR")
	self.BACKGROUNDCOLOR:SetTooltipBody([[Pick a color to change the background color of the overlay window.]])

	self.BACKGROUNDCOLOR.OnClick = function(this)
		self.COLORSELECT:SetColor(self.BACKGROUNDCOLOR:GetColor())
		self.COLORSELECT:SetVisible(true)
		self.COLORSELECT:BringToFront()
	end

	self.COLORSELECT:SetColorButton(self.BACKGROUNDCOLOR)

	self.CONFIGDIR = self.GENERAL.LEFT:Add("Button")
	self.CONFIGDIR:SetText("Open config directory")
	self.CONFIGDIR:Dock(DOCK_BOTTOM)
	self.CONFIGDIR:SetTooltipTitle("CONFIGURATION DIRECTORY")
	self.CONFIGDIR:SetTooltipBody([[This button will open the file explorer to M'Overlay's config directory.

This is also the same directory you use to place all your music for Melee.]])

	function self.CONFIGDIR:OnClick()
		love.system.openURL(("file://%s"):format(love.filesystem.getSaveDirectory()))
	end

	if love.supportsAttachableConsole() then
		self.DEBUG = self.GENERAL.LEFT:Add("CheckBox")
		self.DEBUG:SetText("Debug console")
		self.DEBUG:Dock(DOCK_BOTTOM)
		self.DEBUG:SetTooltipTitle("DEBUG CONSOLE")
		self.DEBUG:SetTooltipBody([[Enable/disable a debug console for developer and debugging purposes.]])

		function self.DEBUG:OnToggle(on)
			love.console(on)
		end
	end

	self.ABOUT = self.MAIN:AddTab("About", "textures/icon.png")
	self.ABOUT:SetBackgroundColor(color_purple)

	self.ABOUT.RIGHT = self.ABOUT:Add("Panel")
	self.ABOUT.RIGHT:SetDrawPanel(false)
	self.ABOUT.RIGHT:Dock(DOCK_RIGHT)
	self.ABOUT.RIGHT:SetWidth(160)

	local ICON = self.ABOUT:Add("Image")
	ICON:SetImage("textures/icon.png")
	ICON:SetPos(24, 0)
	ICON:SetSize(96, 96)
	ICON:CenterVertical()

	local VERSION = self.ABOUT.RIGHT:Add("Button")
	VERSION:SetText(love.getMOverlayVersion())
	VERSION:SetTextAlignmentX("center")
	VERSION:Dock(DOCK_TOP)
	VERSION:SetFont("fonts/melee-bold.otf", 12)

	function VERSION:OnClick()
		love.system.openURL(("https://github.com/bkacjios/m-overlay/tree/v%s"):format(love.getMOverlayVersion()))
	end

	self.ABOUT.SOCIALS = self.ABOUT.RIGHT:Add("Panel")
	self.ABOUT.SOCIALS:SetBGColor(color(215, 215, 215))
	self.ABOUT.SOCIALS:Dock(DOCK_BOTTOM)

	self.ABOUT.AUTHOR = self.ABOUT.SOCIALS:Add("Label")
	self.ABOUT.AUTHOR:SetText("Made by /bkacjios")
	self.ABOUT.AUTHOR:SetTextAlignmentX("center")
	self.ABOUT.AUTHOR:SizeToText()
	self.ABOUT.AUTHOR:Dock(DOCK_TOP)

	self.ABOUT.SOCIALS:SetHeight(self.ABOUT.AUTHOR:GetHeight() + 44)

	local GITHUB = self.ABOUT.SOCIALS:Add("Image")
	GITHUB:SetFocusable(true)
	GITHUB:SetSize(32, 32)
	GITHUB:Dock(DOCK_LEFT)
	GITHUB:SetImage("textures/social/github.png")
	GITHUB:SetTooltipTitle("GITHUB")
	GITHUB:SetTooltipBody([[https://github.com/bkacjios]])

	function GITHUB:OnClick()
		love.system.openURL("https://github.com/bkacjios")
	end

	local TWITTER = self.ABOUT.SOCIALS:Add("Image")
	TWITTER:SetFocusable(true)
	TWITTER:SetSize(32, 32)
	TWITTER:Dock(DOCK_LEFT)
	TWITTER:SetImage("textures/social/twitter.png")
	TWITTER:SetTooltipTitle("TWITTER")
	TWITTER:SetTooltipBody([[https://twitter.com/bkacjios]])

	function TWITTER:OnClick()
		love.system.openURL("https://twitter.com/bkacjios")
	end

	local TWITCH = self.ABOUT.SOCIALS:Add("Image")
	TWITCH:SetFocusable(true)
	TWITCH:SetSize(32, 32)
	TWITCH:Dock(DOCK_LEFT)
	TWITCH:SetImage("textures/social/twitch.png")
	TWITCH:SetTooltipTitle("TWITCH")
	TWITCH:SetTooltipBody([[https://twitch.tv/bkacjios]])

	function TWITCH:OnClick()
		love.system.openURL("https://twitch.tv/bkacjios")
	end

	local PAYPAL = self.ABOUT.SOCIALS:Add("Image")
	PAYPAL:SetFocusable(true)
	PAYPAL:SetSize(32, 32)
	PAYPAL:Dock(DOCK_LEFT)
	PAYPAL:SetImage("textures/social/paypal.png")
	PAYPAL:SetTooltipTitle("PAYPAL")
	PAYPAL:SetTooltipBody([[https://www.paypal.com/paypalme/bkacjios]])

	function PAYPAL:OnClick()
		love.system.openURL("https://www.paypal.com/paypalme/bkacjios")
	end

	self.m_sFileName = "config.json"

	--local test = self:Add("ColorPicker")
	--test:SetSize(256, 256)
end

function PANEL:UpdateSkins()
	self.SKINSELECT:UpdateSkins()
end

function PANEL:ChangeSkin(skin)
	self.SKINSELECT:ChangeSkin(skin)
end

function PANEL:GetSkin()
	return self.SKINSELECT:GetSkin()
end

function PANEL:GetPort()
	return self.PORTSELECT:GetPort()
end

function PANEL:ChangePort(port)
	self.PORTSELECT:ChangePort(port)
end

function PANEL:Toggle()
	self:GiveFocus()
	self:SetVisible(not self:IsVisible())
	if not self:IsVisible() then
		gui.hideTooltip()
		self:OnClosed()
	end
	self:Center()
end

function PANEL:GetSaveTable()
	return {
		["config-version"] = self:GetConfigVersion(),
		["port"] = overlay.getPort(),
		["skin"] = overlay.getSkin(),
		["slippi-mode"] = self:GetSlippiMode(),
		["port-in-title"] = self:IsPortTitleEnabled(),
		["always-show-port"] = self:AlwaysShowPort(),
		["high-contrast"] = self:IsHighContrast(),
		["enable-dpad"] = self:IsDPadEnabled(),
		["enable-start"] = self:IsStartEnabled(),
		["debugging"] = self:IsDebugging(),
		["use-transparency"] = self:UseTransparency(),
		["transparency"] = self:GetTransparency(),
		["melee-music"] = self:PlayStageMusic(),
		["melee-music-loop-flags"] = self:GetMusicLoopMode(),
		["melee-music-skip-buttons"] = self:GetMusicSkipMask(),
		["melee-music-volume"] = self:GetVolume(),
		["background-color"] = self:GetBackgroundColor(),
	}
end

function PANEL:GetConfigVersion()
	return "2.0.0"
end

function PANEL:GetConfigVersionNumbers()
	-- Returns 3 numbers: magor, minor, revision
	return string.match(self:GetConfigVersion(), "^(%d-)%.(%d-)%.(%d+)$")
end

function PANEL:UseTransparency()
	return self.USE_TRANASPARENCY:IsToggled()
end

function PANEL:GetBackgroundColor()
	return self.BACKGROUNDCOLOR:GetColor()
end

function PANEL:IsBinding()
	return self.MELEE.MUSICSKIP:IsBinding()
end

function PANEL:GetMusicSkipMask()
	return self.MELEE.MUSICSKIP:GetButtonCombo()
end

function PANEL:PlayStageMusic()
	return self.MELEE.MUSIC:IsToggled()
end

function PANEL:GetMusicLoopMode()
	return self.MELEE.MUSICLOOP:GetValue()
end

function PANEL:SetVolume(volume)
	return self.MELEE.VOLUME:SetValue(math.clamp(volume, 0, 100))
end

function PANEL:GetVolume()
	return self.MELEE.VOLUME:GetValue()
end

function PANEL:GetSlippiMode()
	return self.SLIPPI.MODE:GetOption()
end

function PANEL:IsSlippiNetplay()
	return self.SLIPPI.MODE:GetOption() == SLIPPI_NETPLAY
end

function PANEL:IsSlippiReplay()
	return self.SLIPPI.MODE:GetOption() == SLIPPI_REPLAY
end

function PANEL:IsPortTitleEnabled()
	return self.PORTTITLE:IsToggled()
end

function PANEL:AlwaysShowPort()
	return self.ALWAYSPORT:IsToggled()
end

function PANEL:IsHighContrast()
	return self.HIGH_CONTRAST:IsToggled()
end

function PANEL:IsDPadEnabled()
	return self.DPAD:IsToggled()
end

function PANEL:IsStartEnabled()
	return self.START:IsToggled()
end

function PANEL:IsDebugging()
	return self.DEBUG and self.DEBUG:IsToggled() or false
end

function PANEL:GetTransparency()
	return self.TRANSPARENCY and self.TRANSPARENCY:GetValue() or nil
end

function PANEL:OnClosed()
	self:SaveSettings()
end

local NEEDS_UPDATE_WRITE = false

function PANEL:NeedsWrite()
	for k,v in pairs(self:GetSaveTable()) do
		-- Return true if the last known settings state differs from the current
		if self.m_tSettings[k] == nil or self.m_tSettings[k] ~= v then
			return true
		end
	end
	if NEEDS_UPDATE_WRITE then
		NEEDS_UPDATE_WRITE = false
		return true
	end
	return false
end

function PANEL:SaveSettings()
	if not self:NeedsWrite() then return end -- Stop if we don't need to write any changes
	local f, err = filesystem.newFile(self.m_sFileName, "w")
	if f then
		log.warn("Writing to %s", self.m_sFileName)
		notification.warning(("Writing to %s"):format(self.m_sFileName))
		self.m_tSettings = self:GetSaveTable()
		f:write(json.encode(self.m_tSettings, true))
		f:flush()
		f:close()
	else
		log.error("Failed writing to %s (%s)", self.m_sFileName, err)
		notification.error(("Failed writing to %s (%s)"):format(self.m_sFileName, err))
	end
end

local function updatedConfigSetting(settings, oldkey, oldvalue, newkey, newvalue)
	settings[newkey] = newvalue
	log.debug("[CONFIG] Updating setting [%q = %s] to [%q = %s]", oldkey, oldvalue, newkey, newvalue)
end

function PANEL:LoadSettings()
	local settings = self:GetSaveTable()

	local f = filesystem.newFile(self.m_sFileName, "r")
	if f then
		for k,v in pairs(json.decode(f:read())) do
			if settings[k] ~= nil then -- We have a valid setting
				settings[k] = v -- Update value from config file

			-- CONVERT OLD SETTINGS INTO NEW
			elseif k == "hide-dpad" and type(v) == "boolean" then
				-- Renamed "hide-dpad" to "enable-dpad" when we added "enable-start"
				updatedConfigSetting(settings, k, v, "enable-dpad", not v)
			elseif k == "slippi-netplay" and v == true then
				-- At one point "slippi-netplay" was a boolean value for on/off
				updatedConfigSetting(settings, k, v, "slippi-mode", SLIPPI_NETPLAY)
			elseif k == "stage-music" or k == "stage-music-loop" or k == "music-volume" then
				-- prefix "melee-" to our old music configs
				updatedConfigSetting(settings, k, v, "melee-" .. k, v)
			elseif k == "melee-stage-music-loop" then
				if type(v) == "boolean" then
					-- Back when we only had a single checkbox for looping a stage
					-- this value was a boolean, convert to new flag.
					updatedConfigSetting(settings, k, v, "melee-music-loop-flags", LOOPING_STAGE_TIMED)
				elseif type(v) == "number" then
					-- Convert our old radio options for the new checkbox system
					local translate = {
						[1] = LOOPING_NONE, -- OFF
						[2] = LOOPING_MENU, -- MENU
						[3] = LOOPING_STAGE_TIMED, -- STAGE
						[4] = LOOPING_MENU + LOOPING_STAGE_TIMED, -- ALL
						[5] = LOOPING_STAGE_TIMED, -- ADAPTIVE
					}
					updatedConfigSetting(settings, k, v, "melee-music-loop-flags", translate[v] or LOOPING_NONE)
				end
			else
				log.debug("[CONFIG] Ignoring old setting config %q", k)
			end
		end
		f:close()
	end

	self.m_tSettings = settings

	overlay.setPort(settings["port"])
	overlay.setSkin(settings["skin"])

	self.PORTTITLE:SetToggled(settings["port-in-title"], true)
	self.ALWAYSPORT:SetToggled(settings["always-show-port"], true)
	self.HIGH_CONTRAST:SetToggled(settings["high-contrast"], true)
	self.DPAD:SetToggled(settings["enable-dpad"], true)
	self.START:SetToggled(settings["enable-start"], true)
	if self.DEBUG then
		self.DEBUG:SetToggled(love.hasConsole() or settings["debugging"] or false)
	end
	self.TRANSPARENCY:SetValue(settings["transparency"])
	self.SLIPPI.MODE:SetValue(settings["slippi-mode"])
	self.MELEE.MUSIC:SetToggled(settings["melee-music"], true)
	self.MELEE.MUSICLOOP:SetValue(settings["melee-music-loop-flags"] or LOOPING_NONE)
	self.MELEE.MUSICSKIP:UpdateButtonCombo(settings["melee-music-skip-buttons"])
	self.MELEE.VOLUME:SetValue(settings["melee-music-volume"])
	if love.supportsGameCapture() then
		self.USE_TRANASPARENCY:SetToggled(settings["use-transparency"], true)
	end
	self.BACKGROUNDCOLOR:SetColor(color(settings["background-color"]))

	-- If we made any changes during load, save them now..
	self:SaveSettings()
end
