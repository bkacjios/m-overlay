local memory = require("memory")

PANEL.BUTTONS = {
	Z = 0x0010,
	R = 0x0020,
	L = 0x0040,
	A = 0x0100,
	B = 0x0200,
	X = 0x0400,
	Y = 0x0800,
	D_LEFT = 0x0001,
	D_RIGHT = 0x0002,
	D_DOWN = 0x0004,
	D_UP = 0x0008,
	START = 0x1000,
	UP = 0x10000,
	DOWN = 0x20000,
	LEFT = 0x40000,
	RIGHT = 0x80000,
	C_UP = 0x100000,
	C_DOWN = 0x200000,
	C_LEFT = 0x400000,
	C_RIGHT = 0x800000,
}

function PANEL:Initialize()
	self:super()

	self.m_bBinding = false

	self:MakeAccessor("ButtonCombo", "m_bButtonCombo", self.BUTTONS.D_DOWN)
	
	memory.hook("controller.*.buttons.pressed", self, self.OnButtonPressed)
end

function PANEL:IsBinding()
	return self.m_bBinding
end

function PANEL:UpdateButtonCombo(buttons)
	if buttons == 0x0 then buttons = self.BUTTONS.D_DOWN end
	self.m_bButtonCombo = buttons
	self:UpdateButtonLabel()
end

function PANEL:UpdateButtonLabel()
	local pressed = {}

	for name, mask in pairs(self.BUTTONS) do
		if bit.band(self.m_bButtonCombo, mask) == mask then
			table.insert(pressed, name)
		end
	end

	-- Show the current button combination
	self:SetText(table.concat(pressed, "+"))
end

function PANEL:OnButtonPressed(port, buttons)
	-- Stop if not in binding mode
	if self.m_bBinding == false then return end

	-- Once they let go of all buttons, end the binding process
	if buttons == 0x0 then
		self.m_bBinding = false
		return
	end

	-- Only allow addition of buttons (Once the button is pressed it is locked in for this session)
	if buttons > self.m_bButtonCombo or buttons >= PANEL.BUTTONS.UP then
		self.m_bButtonCombo = buttons
		self:UpdateButtonLabel()
	end
end

function PANEL:Paint(w, h)
	self:super("Paint", w, h)
	if self.m_bBinding then
		graphics.setLineStyle("rough")
		graphics.setLineWidth(3)
		graphics.setColor(color(0, 162, 232))
		graphics.innerRectangle(0, 0, w, h)
	end
end

function PANEL:OnClick()
	self:SetText("...")
	self.m_bBinding = true
	self.m_bButtonCombo = 0x0
end

gui.register("GCBind", PANEL, "Button")