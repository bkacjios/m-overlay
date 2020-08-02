local PANEL = {}

local log = require("log")
local json = require("serializer.json")
local notification = require("notification")
local music = require("music")

function PANEL:Initialize()
	self:super()

	--self:SetTitle("Settings")
	--self:DockPadding(1, 32, 1, 1)
	--self:SetHideOnClose(true)
	self:SetSize(296 + 36, 196 + 28 + 24)
	self:Center()

	local LEFT = self:Add("Panel")
	LEFT:DockMargin(0,0,0,0)
	LEFT:DockPadding(4,4,4,4)
	--LEFT:SetBorderColor(color_black)
	LEFT:SetBackgroundColor(color_clear)
	LEFT:SetWidth(164)
	LEFT:Dock(DOCK_LEFT)

	local GLABEL = LEFT:Add("Label")
	GLABEL:SetText("General")
	GLABEL:SetTextAlignment("center")
	GLABEL:SizeToText()
	GLABEL:SetHeight(20)
	GLABEL:Dock(DOCK_TOP)

	local RIGHT = self:Add("Panel")
	RIGHT:DockMargin(0,0,0,0)
	RIGHT:DockPadding(0,0,0,0)
	--RIGHT:DockPadding(4,28,4,4)
	--RIGHT:SetBorderColor(color_black)
	--RIGHT:SetBackgroundColor(color(33, 186, 69))
	RIGHT:SetWidth(164)
	RIGHT:Dock(DOCK_RIGHT)

	self.SLIPPI = RIGHT:Add("Panel")
	self.SLIPPI:DockMargin(0,0,0,0)
	self.SLIPPI:DockPadding(4,28,4,4)
	self.SLIPPI:SetBackgroundColor(color(33, 186, 69))
	self.SLIPPI:SetWidth(164)
	self.SLIPPI:SetHeight(84)
	self.SLIPPI:Dock(DOCK_TOP)

	local SLIPPIICON = self.SLIPPI:Add("Image")
	SLIPPIICON:SetImage("textures/SlippiLogo.png")
	SLIPPIICON:SetPos(0, 4)
	SLIPPIICON:SetSize(32, 24)
	SLIPPIICON:Center(false, true)

	self.MELEE = RIGHT:Add("Panel")
	self.MELEE:DockMargin(0,0,0,0)
	self.MELEE:DockPadding(4,28,4,4)
	self.MELEE:SetBackgroundColor(color(189, 15, 23))
	self.MELEE:SetWidth(164)
	self.MELEE:SetHeight(132+28)
	self.MELEE:Dock(DOCK_TOP)

	local MELEEICON = self.MELEE:Add("Image")
	MELEEICON:SetImage("textures/melee.png")
	MELEEICON:SetPos(0, 4)
	MELEEICON:SetSize(160, 32)
	MELEEICON:Center(false, true)

	self.SLIPPI.MODE = self.SLIPPI:Add("HorizontalSelect")
	self.SLIPPI.MODE:Dock(DOCK_TOP)

	SLIPPI_OFF = self.SLIPPI.MODE:AddOption("Off", true) -- 1
	SLIPPI_NETPLAY = self.SLIPPI.MODE:AddOption("Rollback/Netplay") -- 2
	SLIPPI_REPLAY = self.SLIPPI.MODE:AddOption("Replay/Mirror") -- 3

	function self.SLIPPI.MODE:OnSelectOption(num)
		self:GetParent():SetBackgroundColor(num == SLIPPI_OFF and color(100, 100, 100) or color(33, 186, 69))
		self:GetParent().AUTOPORT:SetEnabled(num == SLIPPI_NETPLAY)
	end

	self.SLIPPI.AUTOPORT = self.SLIPPI:Add("Checkbox")
	self.SLIPPI.AUTOPORT:SetEnabled(false)
	self.SLIPPI.AUTOPORT:SetText("Auto detect port")
	self.SLIPPI.AUTOPORT:Dock(DOCK_TOP)

	self.MELEE.MUSIC = self.MELEE:Add("Checkbox")
	self.MELEE.MUSIC:SetText("Music")
	self.MELEE.MUSIC:Dock(DOCK_TOP)

	function self.MELEE.MUSIC:OnToggle(on)
		if on then
			music.onStateChange()
		else
			music.kill()
		end
		self:GetParent().MUSICLOOP:SetEnabled(on)
		self:GetParent().VOLUME:SetEnabled(on)
	end

	self.MELEE.MUSICLOOP = self.MELEE:Add("HorizontalSelect")
	self.MELEE.MUSICLOOP:Dock(DOCK_TOP)

	LOOPING_OFF = self.MELEE.MUSICLOOP:AddOption("Playlist mode", true) -- 1
	LOOPING_MENU = self.MELEE.MUSICLOOP:AddOption("Loop menu") -- 2
	LOOPING_STAGE = self.MELEE.MUSICLOOP:AddOption("Loop stage") -- 3
	LOOPING_ALL = self.MELEE.MUSICLOOP:AddOption("Loop all") -- 4

	function self.MELEE.MUSICLOOP:OnSelectOption(num)
		music.onLoopChange(num)
	end

	self.MELEE.MUSICSKIP = self.MELEE:Add("GCBind")
	self.MELEE.MUSICSKIP:Dock(DOCK_TOP)

	local VOLLABEL = self.MELEE:Add("Label")
	VOLLABEL:SetText("Music volume")
	VOLLABEL:SizeToText()
	VOLLABEL:Dock(DOCK_TOP)

	self.MELEE.VOLUME = self.MELEE:Add("Slider")
	self.MELEE.VOLUME:SetValue(50)
	self.MELEE.VOLUME:Dock(DOCK_TOP)

	function self.MELEE.VOLUME:OnValueChanged(i)
		music.setVolume(i)
		VOLLABEL:SetText(("Music Volume - %d%%"):format(i))
	end

	self.PORTTITLE = LEFT:Add("Checkbox")
	self.PORTTITLE:SetText("Port in title")
	self.PORTTITLE:Dock(DOCK_TOP)

	self.ALWAYSPORT = LEFT:Add("Checkbox")
	self.ALWAYSPORT:SetText("Always show port")
	self.ALWAYSPORT:Dock(DOCK_TOP)

	function self.PORTTITLE:OnToggle()
		love.updateTitle(love.getTitleNoPort())
	end

	self.DPAD = LEFT:Add("Checkbox")
	self.DPAD:SetText("Hide D-PAD")
	self.DPAD:Dock(DOCK_TOP)

	if love.system.getOS() == "Windows" then
		self.DEBUG = LEFT:Add("Checkbox")
		self.DEBUG:SetText("Debug console")
		self.DEBUG:Dock(DOCK_TOP)

		function self.DEBUG:OnToggle(on)
			if on then
				love.openConsole()
			else
				love.closeConsole()
			end
		end
	end

	local TLABEL = LEFT:Add("Label")
	TLABEL:SetText("Transparency")
	TLABEL:SizeToText()
	TLABEL:Dock(DOCK_TOP)

	self.TRANSPARENCY = LEFT:Add("Slider")
	self.TRANSPARENCY:SetValue(100)
	self.TRANSPARENCY:Dock(DOCK_TOP)

	function self.TRANSPARENCY:OnValueChanged(i)
		TLABEL:SetText(("Transparency - %d%%"):format(i))
	end

	self.CONFIGDIR = LEFT:Add("Button")
	self.CONFIGDIR:SetText("Open config directory")
	self.CONFIGDIR:Dock(DOCK_TOP)

	function self.CONFIGDIR:OnClick()
		love.system.openURL(("file://%s"):format(love.filesystem.getSaveDirectory()))
	end

	self.m_sFileName = "config.json"
end

function PANEL:Toggle()
	self:SetVisible(not self:IsVisible())
	if not self:IsVisible() then
		self:OnClosed()
	end
	self:Center()
end

function PANEL:GetSaveTable()
	return {
		["slippi-mode"] = self:GetSlippiMode(),
		["slippi-auto-detect-port"] = self:IsSlippiAutoPortEnabled(),
		["port-in-title"] = self:IsPortTitleEnabled(),
		["always-show-port"] = self:AlwaysShowPort(),
		["hide-dpad"] = self:IsDPADHidden(),
		["debugging"] = self:IsDebugging(),
		["transparency"] = self:GetTransparency(),
		["melee-stage-music"] = self:PlayStageMusic(),
		["melee-stage-music-loop"] = self:GetMusicLoopMode(),
		["melee-stage-music-skip-buttons"] = self:GetMusicSkipMask(),
		["melee-music-volume"] = self:GetVolume(),
	}
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

function PANEL:GetVolume()
	return self.MELEE.VOLUME:GetValue()
end

function PANEL:GetSlippiMode()
	return self.SLIPPI.MODE:GetSelection()
end

function PANEL:IsSlippiNetplay()
	return self.SLIPPI.MODE:GetSelection() == SLIPPI_NETPLAY
end

function PANEL:IsSlippiReplay()
	return self.SLIPPI.MODE:GetSelection() == SLIPPI_REPLAY
end

function PANEL:IsSlippiAutoPortEnabled()
	return self.SLIPPI.AUTOPORT:IsToggled()
end

function PANEL:IsPortTitleEnabled()
	return self.PORTTITLE:IsToggled()
end

function PANEL:AlwaysShowPort()
	return self.ALWAYSPORT:IsToggled()
end

function PANEL:IsDPADHidden()
	return self.DPAD:IsToggled()
end

function PANEL:IsDebugging()
	return self.DEBUG and self.DEBUG:IsToggled() or false
end

function PANEL:GetTransparency()
	return self.TRANSPARENCY:GetValue()
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
		notification.warning(("Writing to %s"):format(self.m_sFileName))
		self.m_tSettings = self:GetSaveTable()
		f:write(json.encode(self.m_tSettings, true))
		f:flush()
		f:close()
	else
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

	self.PORTTITLE:SetToggle(settings["port-in-title"] or false, true)
	self.ALWAYSPORT:SetToggle(settings["always-show-port"] or false, true)
	self.DPAD:SetToggle(settings["hide-dpad"] or false, true)
	if self.DEBUG then self.DEBUG:SetToggle(settings["debugging"] or false) end
	self.TRANSPARENCY:SetValue(settings["transparency"] or 100)
	self.SLIPPI.MODE:SelectOption(settings["slippi-mode"] or 0, true)
	self.SLIPPI.AUTOPORT:SetToggle(settings["slippi-auto-detect-port"] or false, true)
	self.MELEE.MUSIC:SetToggle(settings["melee-stage-music"] or false, true)
	self.MELEE.MUSICLOOP:SelectOption(settings["melee-stage-music-loop"] or LOOPING_OFF, true)
	self.MELEE.MUSICSKIP:UpdateButtonCombo(settings["melee-stage-music-skip-buttons"] or 0x0004)
	self.MELEE.VOLUME:SetValue(settings["melee-music-volume"] or 50)
end

gui.register("Settings", PANEL, "Panel")