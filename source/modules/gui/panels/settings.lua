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
	self.MAIN:SetSize(296 + 32, 176)
	self.MAIN:Center()
	self.MAIN:DockPadding(0, 0, 0, 0)
	self.MAIN:Center()

	self.GENERAL = self.MAIN:AddTab("General", "textures/gui/cog.png", true)
	self.GENERAL:SetBackgroundColor(color(200, 200, 200, 255))

	self.GENERAL.LEFT = self.GENERAL:Add("Panel")
	self.GENERAL.LEFT:SetWidth(158)
	self.GENERAL.LEFT:Dock(DOCK_LEFT)
	self.GENERAL.LEFT:SetBGColor(color_blank)
	self.GENERAL.LEFT:SetBorderColor(color_blank)
	self.GENERAL.LEFT:DockPadding(0, 0, 0, 0)

	self.GENERAL.RIGHT = self.GENERAL:Add("Panel")
	self.GENERAL.RIGHT:SetWidth(158)
	self.GENERAL.RIGHT:Dock(DOCK_RIGHT)
	self.GENERAL.RIGHT:SetBGColor(color_blank)
	self.GENERAL.RIGHT:SetBorderColor(color_blank)
	self.GENERAL.RIGHT:DockPadding(0, 0, 0, 0)

	self.SLIPPI = self.MAIN:AddTab("Slippi", "textures/gui/slippi.png")
	self.SLIPPI:SetBackgroundColor(color(33, 186, 69, 255))

	self.MELEE = self.MAIN:AddTab("Melee", "textures/gui/melee.png")
	self.MELEE:SetBackgroundColor(color(189, 15, 23, 255))

	self.MELEE.VOLUME = self.MELEE:Add("Slider")
	self.MELEE.VOLUME:SetValue(50)
	self.MELEE.VOLUME:Dock(DOCK_BOTTOM)
	self.MELEE.VOLUME:SetTooltipTitle("VOLUME")
	self.MELEE.VOLUME:SetTooltipBody([[Adjust the volume of the music.]])

	local VOLLABEL = self.MELEE:Add("Label")
	VOLLABEL:SetText("Music volume")
	VOLLABEL:SetTextAlignment("center")
	VOLLABEL:SizeToText()
	VOLLABEL:Dock(DOCK_BOTTOM)
	VOLLABEL:SetTextColor(color_white)
	VOLLABEL:SetShadowDistance(1)
	VOLLABEL:SetShadowColor(color_black)
	VOLLABEL:SetFont("fonts/melee-bold.otf", 12)

	function self.MELEE.VOLUME:OnValueChanged(i)
		music.setVolume(i)
		VOLLABEL:SetText(("Music Volume - %d%%"):format(i))
	end

	self.MELEE.LEFT = self.MELEE:Add("Panel")
	self.MELEE.LEFT:SetWidth(158)
	self.MELEE.LEFT:Dock(DOCK_LEFT)
	self.MELEE.LEFT:SetBGColor(color_blank)
	self.MELEE.LEFT:SetBorderColor(color_blank)
	self.MELEE.LEFT:DockPadding(0, 0, 0, 0)

	self.MELEE.RIGHT = self.MELEE:Add("Panel")
	self.MELEE.RIGHT:SetWidth(158)
	self.MELEE.RIGHT:Dock(DOCK_RIGHT)
	self.MELEE.RIGHT:SetBGColor(color_blank)
	self.MELEE.RIGHT:SetBorderColor(color_blank)
	self.MELEE.RIGHT:DockPadding(0, 0, 0, 0)

	self.SLIPPI.MODE = self.SLIPPI:Add("RadioPanel")
	self.SLIPPI.MODE:SetWidth(176)
	self.SLIPPI.MODE:Center(true, true)

	local off = self.SLIPPI.MODE:AddOption(SLIPPI_OFF, "Off: Other games", true)
	off:SetTooltipTitle("SLIPPI MODE")
	off:SetTooltipBody([[- Other games: Use normal game detection. Supported game list can be found on the github README.]])
	local netplay = self.SLIPPI.MODE:AddOption(SLIPPI_NETPLAY, "Melee: Rollback")
	netplay:SetTooltipTitle("SLIPPI MODE")
	netplay:SetTooltipBody([[- Rollback: Allows the overlay to work properly when playing Slippi online. Will also actively change the overylay to display your current port.]])
	local mirror = self.SLIPPI.MODE:AddOption(SLIPPI_REPLAY, "Melee: Replay/Mirror")
	mirror:SetTooltipTitle("SLIPPI MODE")
	mirror:SetTooltipBody([[- Replay/Mirror: Allows the overlay to work when viewing replays or mirroring gameplay from a console.]])

	function self.SLIPPI.MODE:OnSelectOption(num)
		self:GetParent():SetBackgroundColor(num == SLIPPI_OFF and color(100, 100, 100, 255) or color(33, 186, 69, 255))
		music.refreshRNGseed()
	end

	self.MELEE.MUSIC = self.MELEE.LEFT:Add("Checkbox")
	self.MELEE.MUSIC:SetText("Music")
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

	self.MELEE.MUSICLOOP = self.MELEE.LEFT:Add("HorizontalSelect")
	self.MELEE.MUSICLOOP:Dock(DOCK_TOP)

	self.MELEE.MUSICLOOP:SetTooltipTitle("MUSIC LOOP MODE")
	self.MELEE.MUSICLOOP:SetTooltipBody([[- Playlist mode: When a song ends, it will play another song in a random order.

-Loop menu: Will play one random song on a loop when in menus.

-Loop stage: Will play one random song on loop when playing on a stage.

-Loop all: Will play one random song on a loop when in the menu system or playing on a stage.
]])

	LOOPING_OFF = self.MELEE.MUSICLOOP:AddOption("Playlist mode", true) -- 1
	LOOPING_MENU = self.MELEE.MUSICLOOP:AddOption("Loop menu") -- 2
	LOOPING_STAGE = self.MELEE.MUSICLOOP:AddOption("Loop stage") -- 3
	LOOPING_ALL = self.MELEE.MUSICLOOP:AddOption("Loop all") -- 4

	function self.MELEE.MUSICLOOP:OnSelectOption(num)
		music.onLoopChange(num)
	end

	local SKIPLABEL = self.MELEE.RIGHT:Add("Label")
	SKIPLABEL:SetText("Skip track combo")
	SKIPLABEL:SetTextAlignment("center")
	SKIPLABEL:SizeToText()
	SKIPLABEL:SetHeight(24)
	SKIPLABEL:Dock(DOCK_TOP)
	SKIPLABEL:SetTextColor(color_white)
	SKIPLABEL:SetShadowDistance(1)
	SKIPLABEL:SetShadowColor(color_black)
	SKIPLABEL:SetFont("fonts/melee-bold.otf", 12)

	self.MELEE.MUSICSKIP = self.MELEE.RIGHT:Add("GCBind")
	self.MELEE.MUSICSKIP:Dock(DOCK_TOP)
	self.MELEE.MUSICSKIP:SetTooltipTitle("SKIP TRACK COMBO")
	self.MELEE.MUSICSKIP:SetTooltipBody([[This button will allow you to a set a button combination on your controller to skip the currently playing music track.

NOTE: This button is only usable when in a supported game.]])

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

	self.TRANSPARENCY = self.GENERAL.RIGHT:Add("Slider")
	self.TRANSPARENCY:SetValue(100)
	self.TRANSPARENCY:Dock(DOCK_BOTTOM)
	self.TRANSPARENCY:SetVisible(love.supportsGameCapture())
	self.TRANSPARENCY:SetTooltipTitle("TRANSPARENCY")
	self.TRANSPARENCY:SetTooltipBody([[Adjust how transparent the overlay is. This will only function correctly if you are capturing this window in OBS with a "Game Capture" element with transparency enabled.]])

	local TLABEL = self.GENERAL.RIGHT:Add("Label")

	function self.TRANSPARENCY:OnValueChanged(i)
		TLABEL:SetText(("Transparency - %d%%"):format(i))
	end

	TLABEL:SetText("Transparency")
	TLABEL:SizeToText()
	TLABEL:SetHeight(24)
	TLABEL:Dock(DOCK_BOTTOM)
	TLABEL:SetTextColor(color_white)
	TLABEL:SetShadowDistance(1)
	TLABEL:SetShadowColor(color_black)
	TLABEL:SetFont("fonts/melee-bold.otf", 12)
	TLABEL:SetVisible(love.supportsGameCapture())

	self.BACKGROUNDCOLOR = self.GENERAL.RIGHT:Add("ColorButton")
	self.BACKGROUNDCOLOR:SetText("Background color")
	self.BACKGROUNDCOLOR:Dock(DOCK_BOTTOM)
	self.BACKGROUNDCOLOR:SetVisible(not love.supportsGameCapture())
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
	VLABEL:SetTextAlignment("center")
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
		["transparency"] = self:GetTransparency(),
		["melee-stage-music"] = self:PlayStageMusic(),
		["melee-stage-music-loop"] = self:GetMusicLoopMode(),
		["melee-stage-music-skip-buttons"] = self:GetMusicSkipMask(),
		["melee-music-volume"] = self:GetVolume(),
		["background-color"] = self:GetBackgroundColor(),
	}
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
	return self.MELEE.MUSICLOOP:GetSelection()
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
	self.MELEE.MUSICLOOP:SelectOption(settings["melee-stage-music-loop"] or LOOPING_OFF, true)
	self.MELEE.MUSICSKIP:UpdateButtonCombo(settings["melee-stage-music-skip-buttons"])
	self.MELEE.VOLUME:SetValue(settings["melee-music-volume"])
	self.BACKGROUNDCOLOR:SetColor(color(settings["background-color"]))
end
