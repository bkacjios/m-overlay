local PANEL = class.create("ToolTip", "BasePanel")

PANEL:ACCESSOR("Enabled", "m_bEnabled", true)
PANEL:ACCESSOR("ArrowX", "m_iArrowX", 0)
PANEL:ACCESSOR("ArrowY", "m_iArrowY", 0)

PANEL.ToolTipColor = color(240, 240, 240)

function PANEL:ToolTip()
	self:super() -- Initialize our baseclass
	self:SetFocusable(false) -- Ignore focus

	self:SetSize(256, 256)
	self:DockPadding(8, 8, 8, 0)

	self.m_pTitle = self:Add("Label")
	self.m_pTitle:Dock(DOCK_TOP)
	self.m_pTitle:SetLineHeight(0.75)
	self.m_pTitle:SetTextColor(color_red)

	self.m_pBody = self:Add("Label")
	self.m_pBody:Dock(DOCK_FILL)
	self.m_pBody:SetWrapped(true)
	self.m_pBody:SetFont("fonts/melee.otf", 11)
	self.m_pBody:SetLineHeight(0.75)
	self.m_pBody:SetPos(8, 16+24)
	self.m_pBody:SetSize(236, 228)
end

function PANEL:SetArrowPos(x, y)
	self.m_iArrowX = x
	self.m_iArrowY = y
end

function PANEL:GetArrowPos()
	return math.max(5, math.min(self:GetWidth() - 5, self.m_iArrowX)), math.max(5, math.min(self:GetHeight() - 5, self.m_iArrowY))
end

function PANEL:SetTitle(str)
	self.m_pTitle:SetText(str)
end

function PANEL:SetBody(str)
	self.m_pBody:SetText(str)
	self.m_pBody:HeightToText()
	self:SizeToChildren(false, true)
end

function PANEL:Paint(w, h)
	graphics.setColor(color(0, 0, 0, 75))
	graphics.roundRect(8, 8, w-8, h-8, 4)

	graphics.setColor(color_black)
	graphics.roundRect(4, 4, w-8, h-8, 4)

	local s1 = 5.65685424949 -- sqrt(4^2+4^2)
	local s2 = 7.07106781187 -- sqrt(5^2+5^2)

	graphics.setColor(self.ToolTipColor)

	graphics.push()
	graphics.translate(self:GetArrowPos()) -- move relative (0,0) to (x,y)
	graphics.rotate(math.rad(45)) -- rotate coordinate system around relative (0,0) (absolute (x,y))

	graphics.setColor(color_black)
	graphics.rectangle("fill", -s2/2, -s2/2, s2, s2) -- draw rectangle centered around relative (0,0)

	graphics.setColor(self.ToolTipColor)
	graphics.rectangle("fill", -s1/2, -s1/2, s1, s1) -- draw rectangle centered around relative (0,0)
	graphics.pop()

	graphics.setColor(self.ToolTipColor)
	graphics.roundRect(5, 5, w-10, h-10, 4)
end
