local PANEL = {}

function PANEL:Initialize()	
	self:super()
	
	self:SetTitle("Settings")
	self:SetSize(256 + 128 + 8, 256 + 8)

	self.m_pSettings = self:Add("ScrollPanel")
	self.m_pSettings:Dock(DOCK_FILL)

	local text = self.m_pSettings:AddItem("TextEntry")
	text:Dock(DOCK_TOP)

	local width, height, flags = love.window.getMode()

	local resolution = self.m_pSettings:AddItem("HorizontalSelect")
	resolution:Dock(DOCK_TOP)
	for k, res in pairs(love.window.getFullscreenModes()) do
		resolution:AddOption(("%dx%d"):format(res.width, res.height), (res.width == width and res.height == height))
	end

	function resolution:OnSelectOption(num)
		local mode = love.window.getFullscreenModes()[num]
		love.window.setMode(mode.width, mode.height)
		gui.resize(mode.width, mode.height)
	end

	local fullscreen = self.m_pSettings:AddItem("HorizontalSelect")
	fullscreen:Dock(DOCK_TOP)
	fullscreen:AddOption("Fullscreen")
	fullscreen:AddOption("Windowed")

	local applybox = self.m_pSettings:AddItem("Panel")
	applybox:SetHeight(256)
	applybox:Dock(DOCK_TOP)
end

gui.register("SceneSettings", PANEL, "Frame")