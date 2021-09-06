local PANEL = class.create("MusicFileSlider", "Panel")

PANEL:ACCESSOR("FilePath", "m_strFilePath", "")

function PANEL:MusicFileSlider()
	self:super()

	self:SetHeight(56)

	self.m_pSlider = self:Add("SliderPanel")
	self.m_pSlider:Dock(DOCK_RIGHT)
	self.m_pSlider:SetWidth(128)
	self.m_pSlider:SetNeedsFocus(true)

	self.m_pFileName = self:Add("LabelIcon")
	self.m_pFileName:Dock(DOCK_FILL)
	self.m_pFileName:SetTextAlignmentX("left")
	self.m_pFileName:SetTextAlignmentY("center")
	self.m_pFileName:SetImage("textures/gui/page.png")
	self.m_pFileName:SetWrapped(true)
	self.m_pFileName:TextMargin(28, 7, 4, 4)

	self:InheritMethods(self.m_pSlider)
	self:SetTextFormat("%d%%")
end

function PANEL:SetFileName(str)
	self.m_pFileName:SetText(str)
end

function PANEL:GetFileName()
	return self.m_pFileName:GetText()
end

local PANEL = class.create("MusicDirectory", "Panel")

function PANEL:MusicDirectory()
	self:super()

	self.m_pDirectoryLabel = self:Add("ButtonIcon")
	self.m_pDirectoryLabel:SetFocusable(true)
	self.m_pDirectoryLabel:Dock(DOCK_TOP)
	self.m_pDirectoryLabel:SetTextAlignmentX("left")
	self.m_pDirectoryLabel:SetImage("textures/gui/folder_link.png")

	function self.m_pDirectoryLabel:OnClick()
		love.system.openURL(("file://%s/%s"):format(love.filesystem.getSaveDirectory(), self:GetText()))
	end

	self.m_pFiles = self:Add("Panel")
	self.m_pFiles:Dock(DOCK_FILL)
	self.m_pFiles:DockPadding(0,0,0,0)
	self.m_pFiles:DockMargin(0,0,0,0)
	self.m_pFiles:SetDrawPanel(false)
end

function PANEL:SetPath(str)
	self.m_pDirectoryLabel:SetText(str)
end

function PANEL:AddFile(name)
	local file = self.m_pFiles:Add("MusicFileSlider")
	file:Dock(DOCK_TOP)
	file:SetFileName(name)
	return file
end

function PANEL:GetFiles()
	return self.m_pFiles:GetChildren()
end

function PANEL:PerformLayout()
	self.m_pFiles:SizeToChildren(false, true)
	self:SizeToChildren(false, true)
end

function PANEL:Search(text)
	local numVis = 0
	for k, child in ipairs(self.m_pFiles:GetChildren()) do
		local vis = string.find(child:GetFileName():lower(), text:lower(), 1, true) ~= nil
		if vis then numVis = numVis + 1 end
		child:SetVisible(vis)
	end
	self:SetVisible(numVis > 0)
end

local PANEL = class.create("MusicProbability", "Panel")

local music = require("music")

local MODE_GLOBAL = 0
local MODE_STATE = 1

function PANEL:UpdatePlaylist()
	local mode = self.PROBMODE:GetOption()
	local playlistTree = music.getPlaylistTree()

	self.PLAYLIST:Clear()

	for folder, entries in pairs(playlistTree) do
		local directory = self.PLAYLIST:Add("MusicDirectory")
		directory:Dock(DOCK_TOP)
		directory:SetPath(folder)

		for k, entry in ipairs(entries) do
			local file = directory:AddFile(entry.FILENAME)
			local path = entry.FILEPATH

			file:SetFilePath(path)

			self.m_tblStateValues[MODE_GLOBAL][path] = music.getGlobalFileProbability(path)
			self.m_tblStateValues[MODE_STATE][path] = music.getStateFileProbability(path)

			file:SetValue(self.m_tblStateValues[mode][path])
		end
	end
end

function PANEL:GetTableValues()
	local tbl = {}
	for k, directory in ipairs(self.PLAYLIST:GetCanvas():GetChildren()) do
		for k, file in ipairs(directory:GetFiles()) do
			tbl[file:GetFilePath()] = file:GetValue()
		end
	end
	return tbl
end

function PANEL:SetTableValues(tbl)
	for k, directory in ipairs(self.PLAYLIST:GetCanvas():GetChildren()) do
		for k, file in ipairs(directory:GetFiles()) do
			local path = file:GetFilePath()
			if tbl[path] then
				file:SetValue(tbl[path])
			end
		end
	end
end

function PANEL:ResetAll(mode)
	for k, directory in ipairs(self.PLAYLIST:GetCanvas():GetChildren()) do
		for k, file in ipairs(directory:GetFiles()) do
			if file:IsVisible() then
				local path = file:GetFilePath()

				local value

				if mode == MODE_GLOBAL then
					value = music.getGlobalFileProbability(path)
				else
					value = music.getStateFileProbability(path)
				end

				file:SetValue(value)
			end
		end
	end
end

function PANEL:SetAllValue(value)
	for k, directory in ipairs(self.PLAYLIST:GetCanvas():GetChildren()) do
		for k, file in ipairs(directory:GetFiles()) do
			if file:IsVisible() then
				file:SetValue(value)
			end
		end
	end
end

function PANEL:MusicProbability()
	self:super()

	self.TOPBAR = self:Add("Panel")
	self.TOPBAR:Dock(DOCK_TOP)
	self.TOPBAR:SetHeight(28)
	self.TOPBAR:DockPadding(0,0,0,0)
	self.TOPBAR:DockMargin(0,0,0,0)
	self.TOPBAR:SetBorderColor(color_blank)

	self.SEARCH = self.TOPBAR:Add("TextEntry")
	self.SEARCH:Dock(DOCK_FILL)
	self.SEARCH:SetTextHint("Search..")

	self.SEARCH.OnTextChanged = function(this, text, add)
		self.PLAYLIST:SetScroll(0)
		for k, child in ipairs(self.PLAYLIST:GetCanvas():GetChildren()) do
			child:Search(text)
		end
		return true
	end

	self.m_tblStateValues = {
		[MODE_GLOBAL] = {},
		[MODE_STATE] = {},
	}

	self.REFRESH = self.TOPBAR:Add("ButtonIcon")
	self.REFRESH:SetImage("textures/gui/arrow_refresh.png")
	self.REFRESH:Dock(DOCK_RIGHT)
	self.REFRESH:SetText("Refresh")
	self.REFRESH:SetWidth(24)
	self.REFRESH:SetTooltipTitle("REFRESH")
	self.REFRESH:SetTooltipBody([[This button will refetch all the songs for the given state of the game.

NOTE: If you are on the menus, pressing this button will display all songs that can play on the menu. If you are on a stage, it will display all songs that can play when on that stage.]])

	self.PROBMODE = self.TOPBAR:Add("RadioPanel")
	self.PROBMODE:SetHorizontal(true)
	self.PROBMODE:SetDrawPanel(false)
	self.PROBMODE:SetDrawLabel(false)
	self.PROBMODE:Dock(DOCK_RIGHT)
	self.PROBMODE:DockMargin(0, 0, 0, 0)
	self.PROBMODE:DockPadding(0, 0, 0, 0)

	local global = self.PROBMODE:AddOption(MODE_GLOBAL, "Global", true)
	global:SetWidth(70)
	global:SetTooltipParent(self.PROBMODE)
	global:SetTooltipTitle("GLOBAL PROBABILITY")
	global:SetTooltipBody([[When in global mode, you can adjust the probability the given song will play at a global level. This will apply across all possible game states.

NOTE: A song that has been adjusted in "state" mode will override the probability of its "global" mode value.]])

	local state = self.PROBMODE:AddOption(MODE_STATE, "State")
	state:SetWidth(66)
	state:SetTooltipParent(self.PROBMODE)
	state:SetTooltipTitle("STATE PROBABILITY")
	state:SetTooltipBody([[When in state mode, you can adjust the probability the given song will play during the currently active state.

NOTE: A "state" refers to the state of the game, such as being on the menus, or within a stage. Each stage is considered its own "state" and will allow you to fine-tune the probability of a single song across multiple states.]])

	self.PROBMODE.OnSelectOption = function(this, mode, previous)
		self.m_tblStateValues[previous] = self:GetTableValues()
		self:SetTableValues(self.m_tblStateValues[mode])
	end

	self.REFRESH.OnClick = function(this)
		self:UpdatePlaylist()
	end

	self.PLAYLIST = self:Add("ScrollPanel")
	self.PLAYLIST:Dock(DOCK_FILL)
	self.PLAYLIST:DockPadding(0,0,0,0)

	self.OPTIONS = self:Add("Panel")
	self.OPTIONS:Dock(DOCK_BOTTOM)
	self.OPTIONS:SetHeight(28)
	self.OPTIONS:DockPadding(0,0,0,0)
	self.OPTIONS:DockMargin(0,0,0,0)
	self.OPTIONS:SetBorderColor(color_blank)

	self.ZERO = self.OPTIONS:Add("ButtonIcon")
	self.ZERO:SetImage("textures/gui/bullet_arrow_down.png")
	self.ZERO:TextMargin(24, 0, 0, 0)
	self.ZERO:Dock(DOCK_LEFT)
	self.ZERO:SetText("Zero")
	self.ZERO:SetWidth(24)
	self.ZERO:SetTooltipTitle("ZERO")
	self.ZERO:SetTooltipBody([[Sets all songs on this playlist to have 0% chance of playing.]])

	self.ZERO.OnClick = function(this)
		self:SetAllValue(0)
	end

	self.MID = self.OPTIONS:Add("ButtonIcon")
	self.MID:SetImage("textures/gui/bullet_arrow_center.png")
	self.MID:TextMargin(24, 0, 0, 0)
	self.MID:Dock(DOCK_LEFT)
	self.MID:SetText("Center")
	self.MID:SetWidth(24)
	self.MID:SetTooltipTitle("CENTER")
	self.MID:SetTooltipBody([[Sets all songs on this playlist to have 50% chance of playing.]])

	self.MID.OnClick = function(this)
		self:SetAllValue(50)
	end

	self.MAX = self.OPTIONS:Add("ButtonIcon")
	self.MAX:SetImage("textures/gui/bullet_arrow_up.png")
	self.MAX:TextMargin(24, 0, 0, 0)
	self.MAX:Dock(DOCK_LEFT)
	self.MAX:SetText("Max")
	self.MAX:SetWidth(24)
	self.MAX:SetTooltipTitle("MAX")
	self.MAX:SetTooltipBody([[Sets all songs on this playlist to have 100% chance of playing.]])

	self.MAX.OnClick = function(this)
		self:SetAllValue(100)
	end

	self.RESET = self.OPTIONS:Add("ButtonIcon")
	self.RESET:SetImage("textures/gui/arrow_undo.png")
	self.RESET:TextMargin(24, 0, 0, 0)
	self.RESET:Dock(DOCK_LEFT)
	self.RESET:SetText("Reset")
	self.RESET:SetWidth(24)
	self.RESET:SetTooltipTitle("RESET")
	self.RESET:SetTooltipBody([[Sets all songs on this playlist to their previously known value.]])

	self.RESET.OnClick = function(this)
		self:ResetAll(self.PROBMODE:GetOption())
	end

	self.OKAY = self.OPTIONS:Add("ButtonIcon")
	self.OKAY:SetImage("textures/gui/disk.png")
	self.OKAY:Dock(DOCK_RIGHT)
	self.OKAY:SetText("Save")
	self.OKAY:SetWidth(64)
	self.OKAY:SetTooltipTitle("SAVE")
	self.OKAY:SetTooltipBody([[Save all changes to disk and exit.]])

	self.OKAY.OnClick = function(this)
		self:SetVisible(false)
		self.m_tblStateValues[self.PROBMODE:GetOption()] = self:GetTableValues()
		music.updateGlobalProbabilities(self.m_tblStateValues[MODE_GLOBAL])
		music.updateStateProbabilities(self.m_tblStateValues[MODE_STATE])
		music.saveProbabilities()
	end

	self.CANCEL = self.OPTIONS:Add("ButtonIcon")
	self.CANCEL:SetImage("textures/gui/cancel.png")
	self.CANCEL:Dock(DOCK_RIGHT)
	self.CANCEL:SetText("Cancel")
	self.CANCEL:SetWidth(76)
	self.CANCEL:SetTooltipTitle("CANCEL")
	self.CANCEL:SetTooltipBody([[Disregard any changes made and exit.]])

	self.CANCEL.OnClick = function(this)
		self:SetVisible(false)
	end
end