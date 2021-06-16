local PANEL = {}

local overlay = require("overlay")

function PANEL:Initialize()
	self:super()

	self:MakeAccessor("Skin", "m_strSkin", "default")

	self:DockPadding(1, 1, 1, 1)
	self:SetSize(80, 24)
	self:SetPos(512-80, 0)
	self:SetBorderColor(color_clear)
	self:SetBackgroundColor(color(0, 0, 0, 100))
	self:CenterVertical()

	self.SKIN_BUTTONS = {}
end

function PANEL:UpdateSkins()
	local numskins = 0
	for skin, tbl in pairs(overlay.getSkins()) do
		local SKIN = self:Add("Checkbox")
		SKIN:SetText(skin)
		SKIN:DockMargin(1, 1, 1, 1)
		SKIN:Dock(DOCK_TOP)
		SKIN:SetToggleable(false)
		SKIN:SetToggled(false)
		SKIN:SetRadio(true)

		SKIN.OnPressed = function()
			self:ChangeSkin(skin)
		end

		self.SKIN_BUTTONS[skin] = SKIN
		numskins = numskins + 1
	end

	self:SetSize(80, 26*numskins + 2)
end

function PANEL:ChangeSkin(skin)
	skin = self.SKIN_BUTTONS[skin] and skin or "default"
	if self.SKIN_BUTTONS[skin] then
		for name, pnl in pairs(self.SKIN_BUTTONS) do
			pnl:SetToggled(false)
		end
		self.SKIN_BUTTONS[skin]:SetToggled(true)
		self:SetSkin(skin)
	end
end

function PANEL:Toggle()
	self:SetVisible(not self:IsVisible())
end

gui.register("SkinSelect", PANEL, "Panel")