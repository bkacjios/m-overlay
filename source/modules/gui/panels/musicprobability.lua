local PANEL = class.create("MusicProbabilitySlider", "Panel")

function PANEL:MusicProbabilitySlider()
	self:super()

	self:SetHeight(56)

	self.m_pSlider = self:Add("SliderPanel")
	self.m_pSlider:Dock(DOCK_RIGHT)
	self.m_pSlider:SetWidth(128)

	self.m_pLabel = self:Add("Label")
	self.m_pLabel:Dock(DOCK_TOP)
	self.m_pLabel:SetTextAlignmentX("left")

	self:InheritMethods(self.m_pLabel)
	self:InheritMethods(self.m_pSlider)
	self:SetTextFormat("%d%%")
end

local PANEL = class.create("MusicProbability", "Panel")

local music = require("music")

function PANEL:UpdatePlaylist()
	local playlist = music.getPlaylist()

	self.PLAYLIST:Clear()

	for k, file in pairs(playlist) do
		local slider = self.PLAYLIST:Add("MusicProbabilitySlider")
		slider:Dock(DOCK_TOP)
		slider.m_strFilePath = file.FILEPATH
		slider:SetText(file.FILENAME)
		slider:SizeToText()
		slider:SetValue(music.getFileProbability(slider.m_strFilePath))
		slider:SetNeedsFocus(true)
	end
end

function PANEL:GetProbabilityTable()
	local tbl = {}
	for k, child in ipairs(self.PLAYLIST:GetCanvas():GetChildren()) do
		tbl[child.m_strFilePath] = child:GetValue()
	end
	return tbl
end

function PANEL:MusicProbability()
	self:super()

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
	self.ZERO:SetWidth(56)

	self.ZERO.OnClick = function(this)
		for k, child in ipairs(self.PLAYLIST:GetCanvas():GetChildren()) do
			child:SetValue(0)
		end
	end

	self.RESET = self.OPTIONS:Add("ButtonIcon")
	self.RESET:SetImage("textures/gui/arrow_undo.png")
	self.RESET:TextMargin(24, 0, 0, 0)
	self.RESET:Dock(DOCK_LEFT)
	self.RESET:SetText("Reset")
	self.RESET:SetWidth(68)

	self.RESET.OnClick = function(this)
		for k, child in ipairs(self.PLAYLIST:GetCanvas():GetChildren()) do
			child:SetValue(music.getFileProbability(child.m_strFilePath))
		end
	end

	self.MAX = self.OPTIONS:Add("ButtonIcon")
	self.MAX:SetImage("textures/gui/bullet_arrow_up.png")
	self.MAX:TextMargin(24, 0, 0, 0)
	self.MAX:Dock(DOCK_LEFT)
	self.MAX:SetText("Max")
	self.MAX:SetWidth(56)

	self.MAX.OnClick = function(this)
		for k, child in ipairs(self.PLAYLIST:GetCanvas():GetChildren()) do
			child:SetValue(100)
		end
	end

	self.OKAY = self.OPTIONS:Add("ButtonIcon")
	self.OKAY:SetImage("textures/gui/disk.png")
	self.OKAY:Dock(DOCK_RIGHT)
	self.OKAY:SetText("Save")
	self.OKAY:SetWidth(64)

	self.OKAY.OnClick = function(this)
		self:SetVisible(false)
		music.updateFileProbabilities(self:GetProbabilityTable())
		music.saveFileProbabilities()
	end

	self.CANCEL = self.OPTIONS:Add("ButtonIcon")
	self.CANCEL:SetImage("textures/gui/cancel.png")
	self.CANCEL:Dock(DOCK_RIGHT)
	self.CANCEL:SetText("Cancel")
	self.CANCEL:SetWidth(76)

	self.CANCEL.OnClick = function(this)
		self:SetVisible(false)
	end
end