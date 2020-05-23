local PANEL = {}

local json = require("serializer.json")

function PANEL:Initialize()
	self:super()
	self:SetTitle("Settings")
	self:SetDraggable(false)
	self:SetHideOnClose(true)
	self:Dock(DOCK_FILL)
	self:DockMargin(128, 32, 128, 32)
	self:SetVisible(false)

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

	self.m_sFileName = "config.json"
end

function PANEL:GetSaveTable()
	return {
		["hide-dpad"] = self:IsDPADHidden(),
		["debugging"] = self:IsDebugging(),
	}
end

function PANEL:IsDPADHidden()
	return self.m_pDPAD:IsToggled()
end

function PANEL:IsDebugging()
	return self.m_pDEBUG:IsToggled()
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
		self.m_pDPAD:SetToggled(settings["hide-dpad"])
		self.m_pDEBUG:SetToggled(settings["debugging"])
	end
end

gui.register("Settings", PANEL, "Frame")