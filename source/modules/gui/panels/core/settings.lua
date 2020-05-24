local PANEL = {}

local json = require("serializer.json")

function PANEL:Initialize()
	self:super()

	self:SetTitle("Settings")
	self:SetHideOnClose(true)
	self:SetSize(156, 160)
	self:Center()

	self.m_pDPAD = self:Add("Checkbox")
	self.m_pDPAD:SetText("Hide D-PAD")
	self.m_pDPAD:Dock(DOCK_TOP)

	function self.m_pDPAD:OnToggle()
		self:GetParent():SaveSettings()
	end

	self.m_pDEBUG = self:Add("Checkbox")
	self.m_pDEBUG:SetText("Debug mode")
	self.m_pDEBUG:Dock(DOCK_TOP)

	function self.m_pDEBUG:OnToggle()
		self:GetParent():SaveSettings()
	end

	self.m_pTLABEL = self:Add("Label")
	self.m_pTLABEL:SetText("Transparency")
	self.m_pTLABEL:SizeToText()
	self.m_pTLABEL:Dock(DOCK_TOP)

	self.m_pTRANSPARENCY = self:Add("Slider")
	self.m_pTRANSPARENCY:SetValue(100)
	self.m_pTRANSPARENCY:Dock(DOCK_TOP)

	function self.m_pTRANSPARENCY:OnValueChanged(i)
		self:GetParent().m_pTLABEL:SetText(("Transparency - %d%%"):format(i))
		self:GetParent():SaveSettings()
	end

	self.m_sFileName = "config.json"
end

function PANEL:Toggle()
	self:SetVisible(not self:IsVisible())
	self:Center()
end

function PANEL:GetSaveTable()
	return {
		["hide-dpad"] = self:IsDPADHidden(),
		["debugging"] = self:IsDebugging(),
		["transparency"] = self:GetTransparency(),
	}
end

function PANEL:IsDPADHidden()
	return self.m_pDPAD:IsToggled()
end

function PANEL:IsDebugging()
	return self.m_pDEBUG:IsToggled()
end

function PANEL:GetTransparency()
	return self.m_pTRANSPARENCY:GetValue()
end

function PANEL:SaveSettings()
	local f = filesystem.newFile(self.m_sFileName, "w")
	if f then
		f:write(json.encode(self:GetSaveTable(), true))
		f:flush()
		f:close()
	end
end

function PANEL:LoadSettings()
	local f = filesystem.newFile(self.m_sFileName, "r")
	if f then
		local settings = json.decode(f:read())
		f:close()
		self.m_pDPAD:SetToggled(settings["hide-dpad"] or false)
		self.m_pDEBUG:SetToggled(settings["debugging"] or false)
		self.m_pTRANSPARENCY:SetValue(settings["transparency"] or 0)
	end
end

gui.register("Settings", PANEL, "Frame")