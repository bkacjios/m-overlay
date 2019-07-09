local PANEL = {}

function PANEL:Initialize()
	-- Initialize values within Panel:Initialize()
	self:super()
	
	self:SetTitle("Canvas Settings")
	self:SetSize(256, 128)

	

	self.m_pSelectDialog = self:Add("Panel")
	self.m_pSelectDialog:Dock(DOCK_BOTTOM)
	self.m_pSelectDialog:DockPadding(0,0,0,0)
	self.m_pSelectDialog:DockMargin(0,0,0,0)
	self.m_pSelectDialog:SetBGColor(color_blank)
	self.m_pSelectDialog:SetBorderColor(color_blank)

	self.m_pCancel = self.m_pSelectDialog:Add("Button")
	self.m_pCancel:DockMargin(0,0,0,0)
	self.m_pCancel:Dock(DOCK_LEFT)
	self.m_pCancel:SetText("Cancel")

	self.m_pOkay = self.m_pSelectDialog:Add("Button")
	self.m_pOkay:DockMargin(0,0,0,0)
	self.m_pOkay:Dock(DOCK_RIGHT)
	self.m_pOkay:SetText("Apply")
end

gui.register("CanvasEditor", PANEL, "Frame")