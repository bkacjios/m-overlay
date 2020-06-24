local PANEL = {}

function PANEL:Initialize()
	self:super()

	self:MakeAccessor("Enabled", "m_bEnabled", true)
	self:MakeAccessor("BorderColor", "m_cBorderColor", color_blank)
	self:MakeAccessor("BackgroundColor", "m_cBackgroundColor", color_blank)
	self:MakeAccessor("BGColor", "m_cBackgroundColor", color_blank)

	gui.skinHook("Init", "Panel", self)
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "Panel", self, w, h)
end

function PANEL:PostPaint(w, h)
	if not self:IsEnabled() then
		graphics.setColor(color(0, 0, 0, 100))
		graphics.rectangle("fill", 0, 0, w, h)
	end
end

gui.register("Panel", PANEL, "Base")