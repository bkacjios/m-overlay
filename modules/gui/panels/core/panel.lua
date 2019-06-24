local PANEL = {}

function PANEL:Initialize()
	self:super()

	self:MakeAccessor("BorderColor", "m_cBorderColor", color_blank)
	self:MakeAccessor("BackgroundColor", "m_cBackgroundColor", color_blank)
	self:MakeAccessor("BGColor", "m_cBackgroundColor", color_blank)

	gui.skinHook("Init", "Panel", self)
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "Panel", self, w, h)
end

gui.register("Panel", PANEL, "Base")