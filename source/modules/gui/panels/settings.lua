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

LOOPING_OFF = 1
LOOPING_MENU = 2
LOOPING_STAGE = 3
LOOPING_ALL = 4
LOOPING_ADAPT = 5

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
	self.MAIN:Center()
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
	netplay:SetTooltipBody([[Allows the overlay to work properly when playing Slippi online. Will also actively change the overylay to display your current port.]])
	local mirror = self.SLIPPI.MODE:AddOption(SLIPPI_REPLAY, "Melee: Replay/Mirror")
	mirror:SetTooltipParent(self.SLIPPI.MODE)
	mirror:SetTooltipTitle("REPLAY/MIRROR")
	mirror:SetTooltipBody([[Allows the overlay to work when viewing replays or mirroring gameplay from a console.]])

	self.SLIPPI.MODE.OnSelectOption = function(this, num)
		self.SLIPPI.ICON:SetImage(num == SLIPPI_OFF and "textures/slippi.png" or "textures/slippi_filled.png")
	end

	self.MELEE.MUSIC = self.MELEE.LEFT:Add("Checkbox")
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

	self.MELEE.MUSICLOOP = self.MELEE.RIGHT:Add("RadioPanel")
	self.MELEE.MUSICLOOP:SetText("Loop mode")
	self.MELEE.MUSICLOOP:DockMargin(0,0,0,0)
	self.MELEE.MUSICLOOP:Dock(DOCK_TOP)
	self.MELEE.MUSICLOOP:SetWidth(100)

	local off = self.MELEE.MUSICLOOP:AddOption(LOOPING_OFF, "Playlist mode", true)
	off:SetTooltipParent(self.MELEE.MUSICLOOP)
	off:SetTooltipTitle("PLAYLIST")
	off:SetTooltipBody([[When a song ends, it will play another song in a random order. The order in which songs are played are constantly shuffeled.]])
	local menu = self.MELEE.MUSICLOOP:AddOption(LOOPING_MENU, "Loop menu")
	menu:SetTooltipParent(self.MELEE.MUSICLOOP)
	menu:SetTooltipTitle("LOOP MENU")
	menu:SetTooltipBody([[When entering the menus, it will select and play one song at random. When the song ends or reaches a loop point, it will play again.]])
	local stage = self.MELEE.MUSICLOOP:AddOption(LOOPING_STAGE, "Loop stage")
	stage:SetTooltipParent(self.MELEE.MUSICLOOP)
	stage:SetTooltipTitle("LOOP STAGE")
	stage:SetTooltipBody([[When entering a stage, it will select and play one song at random. When the song ends or reaches a loop point, it will play again.]])
	local all = self.MELEE.MUSICLOOP:AddOption(LOOPING_ALL, "Loop menu & stage")
	all:SetTooltipParent(self.MELEE.MUSICLOOP)
	all:SetTooltipTitle("LOOP MENU & STAGE")
	all:SetTooltipBody([[When entering the menus or entering a stage, it will select and play one song at random. When the song ends or reaches a loop point, it will play again.]])
	local adapt = self.MELEE.MUSICLOOP:AddOption(LOOPING_ADAPT, "Adaptive")
	adapt:SetTooltipParent(self.MELEE.MUSICLOOP)
	adapt:SetTooltipTitle("ADAPTIVE")
	adapt:SetTooltipBody([[Will use playlist mode while in the menus or while in an infinite-time match. (Such as training mode)

If the stage has a timer, will loop only a single song.]])

	function self.MELEE.MUSICLOOP:OnSelectOption(num)
		music.onLoopChange(num)
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

	self.PORTTITLE = self.GENERAL.LEFT:Add("Checkbox")
	self.PORTTITLE:SetText("Port in title")
	self.PORTTITLE:Dock(DOCK_TOP)
	self.PORTTITLE:SetTooltipTitle("PORT IN TITLE")
	self.PORTTITLE:SetTooltipBody([[Show the current port number being displayed in the application title.]])

	self.ALWAYSPORT = self.GENERAL.LEFT:Add("Checkbox")
	self.ALWAYSPORT:SetText("Always show port")
	self.ALWAYSPORT:Dock(DOCK_TOP)
	self.ALWAYSPORT:SetTooltipTitle("ALWAYS SHOW PORT")
	self.ALWAYSPORT:SetTooltipBody([[Always show the current port in the bottom left of the overlay window.]])

	function self.PORTTITLE:OnToggle()
		love.updateTitle(love.getTitleNoPort())
	end

	self.DPAD = self.GENERAL.RIGHT:Add("Checkbox")
	self.DPAD:SetText("Show D-Pad")
	self.DPAD:Dock(DOCK_TOP)
	self.DPAD:SetTooltipTitle("DIRECTIONAL-PAD")
	self.DPAD:SetTooltipBody([[Enable/disable the directional pad on the overlay.]])

	self.START = self.GENERAL.RIGHT:Add("Checkbox")
	self.START:SetText("Show Start")
	self.START:Dock(DOCK_TOP)
	self.START:SetTooltipTitle("START BUTTON")
	self.START:SetTooltipBody([[Enable/disable the start button on the overlay.]])

	self.HIGH_CONTRAST = self.GENERAL.RIGHT:Add("Checkbox")
	self.HIGH_CONTRAST:SetText("High-contrast")
	self.HIGH_CONTRAST:Dock(DOCK_TOP)
	self.HIGH_CONTRAST:SetTooltipTitle("HIGH-CONTRAST")
	self.HIGH_CONTRAST:SetTooltipBody([[All buttons and joystick-gates with be filled with black for better viewing visibility.

20XX theme is unsupported]])

	self.USE_TRANASPARENCY = self.GENERAL.RIGHT:Add("Checkbox")
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
		self.BACKGROUNDCOLOR:InvalidateParents()
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
		self.DEBUG = self.GENERAL.LEFT:Add("Checkbox")
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

	local ICON = self.ABOUT:Add("Image")
	ICON:SetImage("textures/icon.png")
	ICON:SetPos(24, 0)
	ICON:SetSize(96, 96)
	ICON:CenterVertical()

	local VLABEL = self.ABOUT:Add("Button")
	VLABEL:SetDrawButton(false)
	VLABEL:SetText("M'Overlay - " .. love.getMOverlayVersion())
	VLABEL:SetTextAlignmentX("center")
	VLABEL:SetSize(176, 18)
	VLABEL:Dock(DOCK_RIGHT)
	VLABEL:SetTextColor(color_white)
	VLABEL:SetShadowColor(color_black)
	VLABEL:SetShadowDistance(1)
	VLABEL:SetFont("fonts/melee-bold.otf", 12)

	function VLABEL:OnClick()
		love.system.openURL(("https://github.com/bkacjios/m-overlay/tree/v%s"):format(love.getMOverlayVersion()))
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
	self:SetVisible(not self:IsVisible())
	if not self:IsVisible() then
		gui.hideTooltip()
		self:OnClosed()
	end
	self:Center()
end

function PANEL:GetSaveTable()
	return {
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
		["melee-stage-music"] = self:PlayStageMusic(),
		["melee-stage-music-loop"] = self:GetMusicLoopMode(),
		["melee-stage-music-skip-buttons"] = self:GetMusicSkipMask(),
		["melee-music-volume"] = self:GetVolume(),
		["background-color"] = self:GetBackgroundColor(),
	}
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
	return self.MELEE.MUSICLOOP:GetOption()
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

function PANEL:NeedsWrite()
	for k,v in pairs(self:GetSaveTable()) do
		-- Return true if the last known settings state differs from the current
		if self.m_tSettings[k] == nil or self.m_tSettings[k] ~= v then
			return true
		end
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

function PANEL:LoadSettings()
	local settings = self:GetSaveTable()

	local f = filesystem.newFile(self.m_sFileName, "r")
	if f then
		for k,v in pairs(json.decode(f:read())) do
			if settings[k] ~= nil then
				settings[k] = v
			elseif k == "hide-dpad" then
				settings["enable-dpad"] = not v
				log.debug("[CONFIG] Converting old config setting %q", k)
			elseif k == "slippi-netplay" and v == true then
				settings["slippi-mode"] = SLIPPI_NETPLAY
				log.debug("[CONFIG] Converting old config setting %q", k)
			elseif k == "stage-music" or k == "stage-music-loop" or k == "music-volume" then
				settings["melee-" .. k] = v
				log.debug("[CONFIG] Converting old config setting %q to %q", k, "melee-" .. k)
			else
				log.debug("[CONFIG] Ignoring old setting config %q", k)
			end
		end
		f:close()
	end

	if type(settings["melee-stage-music-loop"]) == "boolean" and settings["melee-stage-music-loop"] == true then
		settings["melee-stage-music-loop"] = LOOPING_STAGE
	end

	self.m_tSettings = settings

	overlay.setPort(settings["port"])
	overlay.setSkin(settings["skin"])

	self.PORTTITLE:SetToggle(settings["port-in-title"], true)
	self.ALWAYSPORT:SetToggle(settings["always-show-port"], true)
	self.HIGH_CONTRAST:SetToggle(settings["high-contrast"], true)
	self.DPAD:SetToggle(settings["enable-dpad"], true)
	self.START:SetToggle(settings["enable-start"], true)
	if self.DEBUG then
		self.DEBUG:SetToggle(love.hasConsole() or settings["debugging"] or false)
	end
	self.TRANSPARENCY:SetValue(settings["transparency"])
	self.SLIPPI.MODE:SetOption(settings["slippi-mode"])
	self.MELEE.MUSIC:SetToggle(settings["melee-stage-music"], true)
	self.MELEE.MUSICLOOP:SetOption(settings["melee-stage-music-loop"] or LOOPING_OFF)
	self.MELEE.MUSICSKIP:UpdateButtonCombo(settings["melee-stage-music-skip-buttons"])
	self.MELEE.VOLUME:SetValue(settings["melee-music-volume"])
	if love.supportsGameCapture() then
		self.USE_TRANASPARENCY:SetToggle(settings["use-transparency"], true)
	end
	self.BACKGROUNDCOLOR:SetColor(color(settings["background-color"]))
end
