local PANEL = class.create("TextEntryContext", "Panel")

PANEL:ACCESSOR("TextEntry", "m_pTextEntry")

function PANEL:TextEntryContext()
	self:super() -- Initialize baseclass
	self:DisableScissor()
	self:SetVisible(false)

	self.COPY = self:Add("Button")
	self.COPY:Dock(DOCK_TOP)
	self.COPY:SetText("Copy")

	self.COPY.OnClick = function(this)
		self.m_pTextEntry:Copy()
	end

	self.PASTE = self:Add("Button")
	self.PASTE:Dock(DOCK_TOP)
	self.PASTE:SetText("Paste")

	self.PASTE.OnClick = function(this)
		self.m_pTextEntry:Paste()
	end
end

function PANEL:PerformLayout()
	self:SizeToChildren()
end

function PANEL:OnFocusChanged(focus)
	if not focus then
		-- Hide when clicking an option/clicking off
		self:SetVisible(false)
	end
end

local PANEL = class.create("TextEntry", "Panel")
local utf8 = require("extensions.utf8")

PANEL:ACCESSOR("HoveredInput", "m_bHoveredInput", false)
PANEL:ACCESSOR("TextHint", "m_sTextHint", "")

function PANEL:TextEntry()
	self:super() -- Initialize our baseclass

	self.m_pContext = gui.create("TextEntryContext")
	self.m_pContext:SetTextEntry(self)

	self.m_sText = ""
	self.m_iCaretPos = 0
	self.m_bSelectMode = false
	self.m_iSelectLeft = 0
	self.m_iSelectRight = 0
	self.m_bInsert = false
	self.m_cTextColor = color(0, 0, 0)
	self.m_cTextHintColor = color_grey
	self.m_cHighlightTextColor = color(0, 150, 255, 100)
	self.m_pFont = graphics.newFont() --love.graphics.newFont("resource/fonts/VeraMono.ttf", 12)
	self.m_pMouseBeam = love.mouse.getSystemCursor("ibeam")
	self.m_tCharacterSizes = {}
	self.m_tUndoBuffer = {}
	self.m_tRedoBuffer = {}
end

function PANEL:ShowContext()
	self.m_pContext:SetVisible(true)
	self.m_pContext:GiveFocus()
	self.m_pContext:BringToFront()
	self.m_pContext:SetPos(gui.getMousePosition())
end

function PANEL:Think(dt)
	if self:IsHovered() and self:IsEnabled() then
		love.mouse.setCursor(self.m_pMouseBeam)
	else
		love.mouse.setCursor()
	end
end

function PANEL:GetText()
	return self.m_sText
end

function PANEL:Paint(w, h)
	gui.skinHook("Paint", "TextEntry", self, w, h)

	love.graphics.setColor(self.m_cTextColor)
	love.graphics.setFont(self.m_pFont)

	local drawText = self.m_sText

	if not self:HasFocus() and self.m_sText == "" then
		drawText = self.m_sTextHint
		love.graphics.setColor(self.m_cTextHintColor)
	end

	local height = self.m_pFont:getHeight()
	local tw = self.m_pFont:getWidth(drawText)
	local pw = self:GetWidth()

	if tw > pw then
		love.graphics.print(drawText, pw-tw-6, h/2 - (height/2))
	else
		love.graphics.print(drawText, 6, h/2 - (height/2))
	end

	if self.m_iSelectLeft < self.m_iSelectRight then
		local pre = self:GetPreSelection()
		local sel = self:GetSelection()
		local px = self.m_pFont:getWidth(pre)
		love.graphics.setColor(self.m_cHighlightTextColor)
		if tw > pw then
			love.graphics.rectangle("fill", px - tw + pw - 6, h/2 - (height/2), self.m_pFont:getWidth(sel), height)
		else
			love.graphics.rectangle("fill", px + 6, h/2 - (height/2), self.m_pFont:getWidth(sel), height)
		end
	end

	if not self:HasFocus() or not self:IsEnabled() then return end
	if math.floor(love.timer.getTime()*2) % 2 == 0 then return end -- Blink cursor on and off

	local pre = utf8.sub(drawText, 1, self.m_iCaretPos)
	local caretPos = self.m_pFont:getWidth(pre)
	local caretChar = utf8.sub(drawText, self.m_iCaretPos, self.m_iCaretPos)

	if tw > pw then
		caretPos = caretPos - tw + pw - 6
	else
		caretPos = caretPos + 6
	end

	if caretChar == "" then caretChar = " " end

	if self.m_bInsert then
		love.graphics.rectangle("fill", caretPos, h/2 + (height/2), self.m_pFont:getWidth(caretChar), 1)
	else
		love.graphics.rectangle("fill", caretPos, h/2 - (height/2), 1, height)
	end
end

function PANEL:PaintOverlay(w, h)
	gui.skinHook("PaintOverlay", "FocusPanel", self, w, h)
end

function PANEL:SetTextColor(c)
	self.m_cTextColor = c
end

function PANEL:OnMousePressed(x, y, but)
	if but == 1 then
		self:ExitSelection()
		self.m_bGrabbed = true
		self.m_iCaretPos = self:GetCaretPosFromMouse(x, y)
		self:EnterSelectMode()
		return true
	elseif but == 2 then
		self:ShowContext()
		return true
	end
end

function PANEL:OnMouseReleased(x, y, but)
	if but == 1 then
		self.m_bGrabbed = false
		self.m_iCaretPos = self:GetCaretPosFromMouse(x, y)
		return true
	end
end

function PANEL:OnMouseMoved(x, y, dx, dy, istouch)
	if self.m_bGrabbed then
		local pos = self:GetCaretPosFromMouse(x, y)

		if self.m_iCaretPos ~= pos then
			self.m_iCaretPos = pos

			self:EnterSelectMode()

			if dx < 0 then
				if self.m_iCaretPos >= 0 then
					if pos < self.m_iSelectLeft then
						self.m_iSelectLeft = pos -- move selection left
					else
						self.m_iSelectRight = pos -- deselect from the right of the selection
					end
				end
			elseif dx > 0 then
				if self.m_iCaretPos <= utf8.len(self.m_sText) then
					if pos > self.m_iSelectRight then
						self.m_iSelectRight = pos -- move selection right
					else
						self.m_iSelectLeft = pos -- deselect from the left of the selection
					end
				end
			end
		end
		return true
	end
end

function PANEL:CaretGoToEnd()
	self.m_iCaretPos = utf8.len(self.m_sText)
end

function PANEL:CaretGoToStart()
	self.m_iCaretPos = 0
end

function PANEL:GetPreCaret(offset)
	return utf8.sub(self.m_sText, 1, self.m_iCaretPos + (offset or 0))
end

function PANEL:GetPostCaret(offset)
	return utf8.sub(self.m_sText, self.m_iCaretPos + 1 + (offset or 0))
end

function PANEL:GetPreSelection()
	return utf8.sub(self.m_sText, 1, self.m_iSelectLeft)
end

function PANEL:GetSelection()
	return utf8.sub(self.m_sText, self.m_iSelectLeft + 1, self.m_iSelectRight) or ""
end

function PANEL:GetPostSelection()
	return utf8.sub(self.m_sText, self.m_iSelectRight + 1) or ""
end

function PANEL:GetCaretPosFromMouse(mx, my)
	local posx = 3
	local caret_pos = 0
	local smallest_pos = 0
	local smallest_diff = math.huge

	-- TODO: Support selection in Y axis..

	local diff = math.abs(mx - posx)
	if diff < smallest_diff then
		smallest_diff = diff
		smallest_pos = caret_pos
		caret_pos = caret_pos + 1
	end

	for c in self.m_sText:gfind("([%z\1-\127\194-\244][\128-\191]*)") do
		if not self.m_tCharacterSizes[c] then
			self.m_tCharacterSizes[c] = self.m_pFont:getWidth(c)
		end

		local width = self.m_tCharacterSizes[c]
		posx = posx + width

		local diff = math.abs(mx - posx)
		if diff < smallest_diff then
			smallest_diff = diff
			smallest_pos = caret_pos
			caret_pos = caret_pos + 1
		end
	end

	return smallest_pos
end

function PANEL:ExitSelection()
	if not self.m_bSelectMode then return end
	self.m_bSelectMode = false
	self:ResetSelection()
end

function PANEL:ResetSelection()
	self.m_iSelectLeft = 0
	self.m_iSelectRight	= 0
end

function PANEL:EnterSelectMode()
	if self.m_bSelectMode then return end
	self.m_iSelectLeft = self.m_iCaretPos
	self.m_iSelectRight	= self.m_iCaretPos
	self.m_bSelectMode = true
end

function PANEL:SelectAll()
	self:EnterSelectMode()
	self.m_iSelectLeft = 0
	self.m_iSelectRight = utf8.len(self.m_sText)
	self.m_iCaretPos = self.m_iSelectRight
end

function PANEL:SetText(str)
	self.m_sText = str
	self:ExitSelection()
	self:CaretGoToEnd()
end

function PANEL:ChangeText(str)
	self.m_sText = str
	self:OnTextChanged(str)
end

function PANEL:OnTextInput(text)
	if not self:IsEnabled() then return end

	for c in text:gfind("([%z\1-\127\194-\244][\128-\191]*)") do
		if not self.m_tCharacterSizes[c] then
			self.m_tCharacterSizes[c] = self.m_pFont:getWidth(c)
		end
	end

	if self.m_bSelectMode then
		self.m_sText = self:GetPreSelection() .. text .. self:GetPostSelection()
		self.m_iCaretPos = utf8.len(self:GetPreSelection() .. text)
	else
		self.m_sText = self:GetPreCaret() .. text .. self:GetPostCaret(self.m_bInsert and 1 or 0)
		self.m_iCaretPos = self.m_iCaretPos + utf8.len(text)
	end
	self:UpdateUndoBuffer()
	self:ExitSelection()

	self:OnTextChanged(self.m_sText, text)
	return true
end

function PANEL:UpdateUndoBuffer()
	table.insert(self.m_tUndoBuffer, self.m_sText)
end

function PANEL:Copy()
	love.system.setClipboardText(self:GetSelection())
end

function PANEL:Paste()
	self:OnTextInput(love.system.getClipboardText())
end

function PANEL:OnKeyPressed(key, isrepeat)
	if not self:IsEnabled() then return end

	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	local control = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")

	if key == "home" then
		self.m_iCaretPos = 0
	elseif key == "end" then
		self.m_iCaretPos = utf8.len(self.m_sText)
	elseif key == "backspace" then
		if self.m_iSelectLeft < self.m_iSelectRight then
			self:ChangeText(self:GetPreSelection() .. self:GetPostSelection())
			self.m_iCaretPos = math.min(self.m_iCaretPos, utf8.len(self.m_sText))
			self:ExitSelection()
		else
			self.m_iCaretPos = math.max(0, self.m_iCaretPos - 1)
			self:ChangeText(self:GetPreCaret() .. self:GetPostCaret(1))
		end
		self:UpdateUndoBuffer()
	elseif key == "delete" then
		if self.m_iSelectLeft < self.m_iSelectRight then
			self:ChangeText(self:GetPreSelection() .. self:GetPostSelection())
			self.m_iCaretPos = math.min(self.m_iCaretPos, utf8.len(self.m_sText))
			self:ExitSelection()
		else
			self:ChangeText(self:GetPreCaret() .. self:GetPostCaret(1))
		end
		self:UpdateUndoBuffer()
	elseif key == "left" then
		local pos = math.max(0, self.m_iCaretPos - 1)
		if shift then
			self:EnterSelectMode()
			if self.m_iCaretPos > 0 then
				if pos < self.m_iSelectLeft then
					self.m_iSelectLeft = pos -- move selection left
				else
					self.m_iSelectRight = pos -- deselect from the right of the selection
				end
			end
			self.m_iCaretPos = pos
		else
			if self.m_bSelectMode then
				self.m_iCaretPos = utf8.len(self:GetPreSelection())
			else
				self.m_iCaretPos = pos
			end
			self:ExitSelection()
		end
	elseif key == "right" then
		local pos = math.min(utf8.len(self.m_sText), self.m_iCaretPos + 1)
		if shift then
			self:EnterSelectMode()
			if self.m_iCaretPos < utf8.len(self.m_sText) then
				if pos > self.m_iSelectRight then
					self.m_iSelectRight = pos -- move selection right
				else
					self.m_iSelectLeft = pos -- deselect from the left of the selection
				end
			end
			self.m_iCaretPos = pos
		else
			if self.m_bSelectMode then
				self.m_iCaretPos = utf8.len(self:GetPreSelection() .. self:GetSelection())
			else
				self.m_iCaretPos = pos
			end
			self:ExitSelection()
		end
		self.m_iCaretPos = pos
	elseif key == "insert" then
		self.m_bInsert = not self.m_bInsert
	elseif key == "up" then
	elseif key == "down" then
	elseif control then
		if key == "a" then
			self:SelectAll()
		elseif key == "x" then
			self:Copy()
			self:ChangeText(self:GetPreSelection() .. self:GetPostSelection())
			self:UpdateUndoBuffer()
			self.m_iCaretPos = math.min(self.m_iCaretPos, utf8.len(self.m_sText))
			self:ExitSelection()
		elseif key == "c" then
			self:Copy()
		elseif key == "v" then
			self:Paste()
		elseif key == "y" then
			local pop = table.remove(self.m_tRedoBuffer) or ""
			if pop ~= "" then
				self:ChangeText(pop)
				self:CaretGoToEnd()
				self:ExitSelection()
				table.insert(self.m_tUndoBuffer, pop)
			end
		elseif key == "z" then
			local pop = table.remove(self.m_tUndoBuffer) or ""
			self:ChangeText(self.m_tUndoBuffer[#self.m_tUndoBuffer] or "")
			self:CaretGoToEnd()
			self:ExitSelection()
			if pop ~= "" then
				table.insert(self.m_tRedoBuffer, pop)
			end
		end
	end
	return true
end

function PANEL:OnKeyReleased(key)
	if not self:IsEnabled() then return end
	return true
end

function PANEL:OnTextChanged(text, add)

end
