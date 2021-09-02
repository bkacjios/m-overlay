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
		slider:SetValue(music.getFileProbability(file.FILEPATH))
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
	self.OPTIONS:SetHeight(32)
	self.OPTIONS:SetBGColor(color(215, 215, 215))
	--self.OPTIONS:SetBorderColor(color_blank)

	self.RESET = self.OPTIONS:Add("Button")
	self.RESET:Dock(DOCK_LEFT)
	self.RESET:SetText("Reset")
	self.RESET:SetWidth(56)

	self.RESET.OnClick = function(this)
		for k, child in ipairs(self.PLAYLIST:GetCanvas():GetChildren()) do
			child:SetValue(100)
		end
	end

	self.OKAY = self.OPTIONS:Add("Button")
	self.OKAY:Dock(DOCK_RIGHT)
	self.OKAY:SetText("Okay")
	self.OKAY:SetWidth(56)

	self.OKAY.OnClick = function(this)
		self:SetVisible(false)
		music.updateFileProbabilities(self:GetProbabilityTable())
		music.saveFileProbabilities()
	end

	self.CANCEL = self.OPTIONS:Add("Button")
	self.CANCEL:Dock(DOCK_RIGHT)
	self.CANCEL:SetText("Cancel")
	self.CANCEL:SetWidth(56)

	self.CANCEL.OnClick = function(this)
		self:SetVisible(false)
	end
end