local PANEL = {}

function PANEL:Initialize()
	-- Initialize values within Panel:Initialize()
	self:super()

	-- Display should have no padding or margin
	-- since it will match the size of the window
	self:DockPadding(0,0,0,0)
	self:DockMargin(0,0,0,0)

	-- Transparent for use with OBS game capture
	self:SetBGColor(color_blank)
	self:SetBorderColor(color_blank)

	self.m_pTaskBar = self:Add("Panel")
	self.m_pTaskBar:DockMargin(0, 0, 0, 0)
	self.m_pTaskBar:SetBGColor(color(200, 200, 200))
	self.m_pTaskBar:Dock(DOCK_TOP)
	self.m_pTaskBar:SetVisible(false)

	self.m_pInfoBar = self:Add("Panel")
	self.m_pInfoBar:DockMargin(0, 0, 0, 0)
	self.m_pInfoBar:SetBGColor(color(200, 200, 200))
	self.m_pInfoBar:Dock(DOCK_BOTTOM)
	self.m_pInfoBar:SetVisible(false)

	-- Object list when in editor mode
	-- TODO: Make a new class for this, maybe a list panel
	self.m_pObjectList = self:Add("Panel")
	self.m_pObjectList:DockMargin(4, 4, 0, 4)
	self.m_pObjectList:SetWidth(128 + 32)

	-- Dock to the left
	self.m_pObjectList:Dock(DOCK_LEFT)
	-- Not visible on startup
	self.m_pObjectList:SetVisible(false)

	-- The output display
	self.m_pSceneDisplay = self:Add("SceneDisplay")
	-- FILL so the panel will stretch and fit inside our window
	self.m_pSceneDisplay:Dock(DOCK_FILL)

	-- Test panel for testing drag
	local l = self:AddToScene("Panel")
	--l:SetText("Test")
	--l:SetTextColor(color_white)

	-- Member values
	self.m_bEditable = true
end

-- Special method to add a new element to our scene
function PANEL:AddToScene(name)
	-- Add the panel we want to add
	local panel = self.m_pSceneDisplay:Add(name)

	-- Add a matching button to our object list, for ordering/removing/settings and stuff?
	local but = self.m_pObjectList:Add("Button") -- TODO: Make a new class for this, maybe a list panel
	but:Dock(DOCK_TOP)
	but:SetText(name)

	-- Return the panel we added
	return panel
end

function PANEL:SetEditorMode(b)
	-- Set the mode..
	self.m_bEditable = b

	self.m_pTaskBar:SetVisible(b)
	self.m_pInfoBar:SetVisible(b)
	self.m_pObjectList:SetVisible(b)

	if b then
		-- WE ARE IN EDITOR MODE

		-- Set BG color to something pleasant, rather than being transparent
		self:SetBGColor(color(240, 240, 240))

		-- Add a simple margin to the display, so it matches the margin of the object list
		self.m_pSceneDisplay:DockMargin(32, 32, 32, 32)

		-- Fake the black background of the window, since it would normally be "transparent" for OBS capture
		-- This will now look black in OBS capture, rather than transparent
		self.m_pSceneDisplay:SetBGColor(color_black)
	else
		-- WE ARE IN DISPLAY MODE

		-- Reset everything for display mode
		self:SetBGColor(color_blank)
		self.m_pSceneDisplay:DockMargin(0, 0, 0, 0)
		self.m_pSceneDisplay:SetBGColor(color_blank)
	end

	-- Invalidate the layout so the panels get resized and moved properly
	self:InvalidateLayout()
end

function PANEL:GetUnusableSpace()
	local margins = self.m_pSceneDisplay:GetDockMargin()

	local w = margins.left + margins.right
	local h = margins.top + margins.bottom

	h = h + self.m_pTaskBar:GetHeightPlusMargin()
	h = h + self.m_pInfoBar:GetHeightPlusMargin()
	w = w + self.m_pObjectList:GetWidthPlusMargin()

	return w, h
end

function PANEL:IsInEditorMode()
	return self.m_bEditable
end

function PANEL:GetObjectList()
	return self.m_pObjectList
end

function PANEL:GetDisplay()
	return self.m_pSceneDisplay
end

gui.register("SceneEditor", PANEL, "Panel")