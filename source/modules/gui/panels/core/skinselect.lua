local PANEL = {}

function PANEL:Initialize()
	self:super()

	self:MakeAccessor("Skin", "m_iSkin", 1)

	self:DockPadding(1, 1, 1, 1)
	self:SetSize(80, 53)
	self:SetPos(512-80, 0)
	self:SetBorderColor(color_clear)
	self:SetBackgroundColor(color(0, 0, 0, 100))
	self:CenterVertical()

	self.DEFAULT = self:Add("Checkbox")
	self.DEFAULT:SetText("Default")
	self.DEFAULT:DockMargin(1, 1, 1, 1)
	self.DEFAULT:Dock(DOCK_TOP)
	self.DEFAULT:SetToggleable(false)
	self.DEFAULT:SetToggled(true)
	self.DEFAULT:SetRadio(true)

	self.TWENTY = self:Add("Checkbox")
	self.TWENTY:SetText("20XX")
	self.TWENTY:DockMargin(1, 1, 1, 1)
	self.TWENTY:Dock(DOCK_TOP)
	self.TWENTY:SetToggleable(false)
	self.TWENTY:SetRadio(true)

	self.DEFAULT.OnPressed = function()
		self:ChangeSkin(1)
	end

	self.TWENTY.OnPressed = function()
		self:ChangeSkin(2)
	end
end

function PANEL:ChangeSkin(skin)
	self.DEFAULT:SetToggled(false)
	self.TWENTY:SetToggled(false)
	if skin == 1 then
		self.DEFAULT:SetToggled(true)
	elseif skin == 2 then
		self.TWENTY:SetToggled(true)
	end
	self:SetSkin(skin)
end

function PANEL:Toggle()
	self:SetVisible(not self:IsVisible())
end

gui.register("SkinSelect", PANEL, "Panel")