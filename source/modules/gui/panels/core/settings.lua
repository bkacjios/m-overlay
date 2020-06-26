local PANEL = {}

local json = require("serializer.json")

function PANEL:Initialize()
	self:super()

	self:SetTitle("Settings")
	self:SetHideOnClose(true)
	self:SetSize(296 + 32, 196 + 28)
	self:Center()

	self.m_pLEFT = self:Add("Panel")
	self.m_pLEFT:SetBorderColor(color_clear)
	self.m_pLEFT:SetBackgroundColor(color_clear)
	self.m_pLEFT:SetWidth(154)
	self.m_pLEFT:Dock(DOCK_LEFT)

	self.m_pLLABEL = self.m_pLEFT:Add("Label")
	self.m_pLLABEL:SetText("General")
	self.m_pLLABEL:SizeToText()
	self.m_pLLABEL:Dock(DOCK_TOP)

	self.m_pRIGHT = self:Add("Panel")
	self.m_pRIGHT:SetBorderColor(color_clear)
	self.m_pRIGHT:SetBackgroundColor(color_clear)
	self.m_pRIGHT:SetWidth(154)
	self.m_pRIGHT:Dock(DOCK_RIGHT)

	self.m_pRLABEL = self.m_pRIGHT:Add("Label")
	self.m_pRLABEL:SetText("Slippi")
	self.m_pRLABEL:SizeToText()
	self.m_pRLABEL:Dock(DOCK_TOP)

	self.m_pSLIPPIREPLAY = self.m_pRIGHT:Add("Checkbox")
	self.m_pSLIPPIREPLAY:SetText("Slippi Replay")
	self.m_pSLIPPIREPLAY:Dock(DOCK_TOP)

	self.m_pSLIPPI = self.m_pRIGHT:Add("Checkbox")
	self.m_pSLIPPI:SetText("Slippi Netplay")
	self.m_pSLIPPI:Dock(DOCK_TOP)

	function self.m_pSLIPPI:OnToggle(on)
		self:GetParent():GetParent().m_pAUTOPORT:SetEnabled(on)
		self:GetParent():GetParent().m_pSLIPPINAME:SetEnabled(on)
	end

	self.m_pAUTOPORT = self.m_pRIGHT:Add("Checkbox")
	self.m_pAUTOPORT:SetEnabled(false)
	self.m_pAUTOPORT:SetText("Detect port")
	self.m_pAUTOPORT:Dock(DOCK_TOP)

	function self.m_pAUTOPORT:OnToggle(on)
		self:GetParent():GetParent().m_pSLIPPINAME:SetEnabled(on)
	end

	self.m_pSLIPPINAMELABEL = self.m_pRIGHT:Add("Label")
	self.m_pSLIPPINAMELABEL:SetText("Slippi Username")
	self.m_pSLIPPINAMELABEL:SizeToText()
	self.m_pSLIPPINAMELABEL:Dock(DOCK_TOP)

	self.m_pSLIPPINAME = self.m_pRIGHT:Add("TextEntry")
	self.m_pSLIPPINAME:SetEnabled(false)
	self.m_pSLIPPINAME:Dock(DOCK_TOP)

	self.m_pPORTTITLE = self.m_pLEFT:Add("Checkbox")
	self.m_pPORTTITLE:SetText("Port in title")
	self.m_pPORTTITLE:Dock(DOCK_TOP)

	self.m_pALWAYSPORT = self.m_pLEFT:Add("Checkbox")
	self.m_pALWAYSPORT:SetText("Always show port")
	self.m_pALWAYSPORT:Dock(DOCK_TOP)

	function self.m_pPORTTITLE:OnToggle()
		love.updateTitle(love.getTitleNoPort())
	end

	self.m_pDPAD = self.m_pLEFT:Add("Checkbox")
	self.m_pDPAD:SetText("Hide D-PAD")
	self.m_pDPAD:Dock(DOCK_TOP)

	self.m_pDEBUG = self.m_pLEFT:Add("Checkbox")
	self.m_pDEBUG:SetText("Debug mode")
	self.m_pDEBUG:Dock(DOCK_TOP)

	self.m_pTLABEL = self.m_pLEFT:Add("Label")
	self.m_pTLABEL:SetText("Transparency")
	self.m_pTLABEL:SizeToText()
	self.m_pTLABEL:Dock(DOCK_TOP)

	self.m_pTRANSPARENCY = self.m_pLEFT:Add("Slider")
	self.m_pTRANSPARENCY:SetValue(100)
	self.m_pTRANSPARENCY:Dock(DOCK_TOP)

	function self.m_pTRANSPARENCY:OnValueChanged(i)
		self:GetParent():GetParent().m_pTLABEL:SetText(("Transparency - %d%%"):format(i))
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
		["slippi-replay"] = self:IsSlippiReplay(),
		["slippi-netplay"] = self:IsSlippiNetplay(),
		["slippi-auto-detect-port"] = self:IsSlippiAutoPortEnabled(),
		["slippi-username"] = self:GetSlippiUsername(),
		["port-in-title"] = self:IsPortTitleEnabled(),
		["always-show-port"] = self:AlwaysShowPort(),
		["hide-dpad"] = self:IsDPADHidden(),
		["debugging"] = self:IsDebugging(),
		["transparency"] = self:GetTransparency(),
	}
end

function PANEL:IsSlippiReplay()
	return self.m_pSLIPPIREPLAY:IsToggled()
end

function PANEL:IsSlippiNetplay()
	return self.m_pSLIPPI:IsToggled()
end

function PANEL:IsSlippiAutoPortEnabled()
	return self.m_pAUTOPORT:IsToggled()
end

function PANEL:GetSlippiUsername()
	return self.m_pSLIPPINAME:GetText()
end

function PANEL:IsPortTitleEnabled()
	return self.m_pPORTTITLE:IsToggled()
end

function PANEL:AlwaysShowPort()
	return self.m_pALWAYSPORT:IsToggled()
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

function PANEL:OnClosed()
	self:SaveSettings()
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
		self.m_pSLIPPIREPLAY:SetToggle(settings["slippi-replay"] or false)
		self.m_pSLIPPI:SetToggle(settings["slippi-netplay"] or false)
		self.m_pAUTOPORT:SetToggle(settings["slippi-auto-detect-port"] or false)
		self.m_pSLIPPINAME:SetText(settings["slippi-username"] or "")
		self.m_pPORTTITLE:SetToggle(settings["port-in-title"] or false)
		self.m_pALWAYSPORT:SetToggle(settings["always-show-port"] or false)
		self.m_pDPAD:SetToggle(settings["hide-dpad"] or false)
		self.m_pDEBUG:SetToggle(settings["debugging"] or false)
		self.m_pTRANSPARENCY:SetValue(settings["transparency"] or 100)
	end
end

gui.register("Settings", PANEL, "Frame")