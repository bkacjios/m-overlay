local PANEL = class.create("RadioBox", "CheckBox")

function PANEL:RadioBox()
	-- Initialize our baseclass
	self:super()
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "RadioBox", self, w, h)
	self:PaintLabel(w, h)
end

function PANEL:OnClick()
	-- Override
end

function PANEL:OnToggle(on)
	-- Override
end