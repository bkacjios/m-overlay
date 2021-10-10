local PANEL = class.create("DebugInputs", "Panel")

function PANEL:DebugInputs()
	self:super()

	self.OPTIONS = self:Add("Panel")
	self.OPTIONS:Dock(DOCK_BOTTOM)
	self.OPTIONS:SetHeight(28)
	self.OPTIONS:DockPadding(0,0,0,0)
	self.OPTIONS:DockMargin(0,0,0,0)
	self.OPTIONS:SetBorderColor(color_blank)

	self.OKAY = self.OPTIONS:Add("ButtonIcon")
	self.OKAY:SetImage("textures/gui/disk.png")
	self.OKAY:Dock(DOCK_RIGHT)
	self.OKAY:SetText("Save")
	self.OKAY:SetWidth(64)

	self.OKAY.OnClick = function(this)
		self:SetVisible(false)
		self.OnClosed()
	end

	self.CHECKPANEL = self:Add("CheckPanel")
	self.CHECKPANEL:SetText("Debug inputs..")
	self.CHECKPANEL:DockMargin(0,0,0,0)
	self.CHECKPANEL:Dock(DOCK_FILL)

	local buttons = self.CHECKPANEL:AddOption(DEBUG_INPUT_BUTTONS, "Buttons")
	buttons:SetTooltipParent(self.CHECKPANEL)
	buttons:SetTooltipTitle("BUTTONS")
	buttons:SetTooltipBody([[Show the button values in hexadecimal.]])

	local joystick = self.CHECKPANEL:AddOption(DEBUG_INPUT_JOYSTICK, "Joystick")
	joystick:SetTooltipParent(self.CHECKPANEL)
	joystick:SetTooltipTitle("JOYSTICK")
	joystick:SetTooltipBody([[Show the joystick analog values.]])

	local cstick = self.CHECKPANEL:AddOption(DEBUG_INPUT_C_STICK, "C-Stick")
	cstick:SetTooltipParent(self.CHECKPANEL)
	cstick:SetTooltipTitle("C-STICK")
	cstick:SetTooltipBody([[Show the c-stick analog values.]])

	local triggers = self.CHECKPANEL:AddOption(DEBUG_INPUT_TRIGGERS, "Triggers")
	triggers:SetTooltipParent(self.CHECKPANEL)
	triggers:SetTooltipTitle("TRIGGERS")
	triggers:SetTooltipBody([[Show the L/R analog values.]])
end

function PANEL:GetValue()
	return self.CHECKPANEL:GetValue()
end

function PANEL:SetValue(...)
	return self.CHECKPANEL:SetValue(...)
end

function PANEL:OnClosed()
	-- OVERRIDE
end