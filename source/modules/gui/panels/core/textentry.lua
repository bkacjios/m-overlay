local PANEL = {}

local utf8 = require("extensions.utf8")

function PANEL:Initialize()
	self:super() -- Initialize our baseclass
	
	self.m_sText = ""
	self.m_iCaretPos = 0
	self.m_bSelectMode = false
	self.m_iSelectLeft = 0
	self.m_iSelectRight = 0
	self.m_bInsert = false
	self.m_cTextColor = color(0, 0, 0)
	self.m_cHighlightTextColor = color(0, 0, 0, 100)
	self.m_pFont = graphics.newFont() --love.graphics.newFont("resource/fonts/VeraMono.ttf", 12)
	self.m_pMouseBeam = love.mouse.getSystemCursor("ibeam")
	self.m_tCharacterSizes = {}
	self.m_tUndoBuffer = {}
	self.m_tRedoBuffer = {}
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

	local height = self.m_pFont:getHeight()
	local tw = self.m_pFont:getWidth(self.m_sText)
	local pw = self:GetWidth()

	if tw > pw then
		love.graphics.print(self.m_sText, pw-tw-6, h/2 - (height/2))
	else
		love.graphics.print(self.m_sText, 6, h/2 - (height/2))
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

	local pre = utf8.sub(self.m_sText, 1, self.m_iCaretPos)
	local caretPos = self.m_pFont:getWidth(pre)
	local caretChar = utf8.sub(self.m_sText, self.m_iCaretPos, self.m_iCaretPos)

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

end

function PANEL:OnMouseReleased(x, y, but)

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

function PANEL:ResetSelection()
	if not self.m_bSelectMode then return end
	self.m_iSelectLeft = 0
	self.m_iSelectRight	= 0
	self.m_bSelectMode = false
end

function PANEL:EnterSelectMode()
	if self.m_bSelectMode then return end
	self.m_iSelectLeft = self.m_iCaretPos
	self.m_iSelectRight	= self.m_iCaretPos
	self.m_bSelectMode = true
end

function PANEL:SetText(str)
	self.m_sText = str
	self:CaretGoToEnd()
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
	self:ResetSelection()
end

function PANEL:UpdateUndoBuffer()
	table.insert(self.m_tUndoBuffer, self.m_sText)
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
			self.m_sText = self:GetPreSelection() .. self:GetPostSelection()
			self.m_iCaretPos = math.min(self.m_iCaretPos, utf8.len(self.m_sText))
			self:ResetSelection()
		else
			self.m_iCaretPos = math.max(0, self.m_iCaretPos - 1)
			self.m_sText = self:GetPreCaret() .. self:GetPostCaret(1)
		end
		self:UpdateUndoBuffer()
	elseif key == "delete" then
		if self.m_iSelectLeft < self.m_iSelectRight then
			self.m_sText = self:GetPreSelection() .. self:GetPostSelection()
			self.m_iCaretPos = math.min(self.m_iCaretPos, utf8.len(self.m_sText))
			self:ResetSelection()
		else
			self.m_sText = self:GetPreCaret() .. self:GetPostCaret(1)
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
			self:ResetSelection()
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
			self:ResetSelection()
		end
		self.m_iCaretPos = pos
	elseif key == "insert" then
		self.m_bInsert = not self.m_bInsert
	elseif key == "up" then
	elseif key == "down" then
	elseif control then
		if key == "a" then
			self:EnterSelectMode()
			self.m_iSelectLeft = 0
			self.m_iSelectRight = utf8.len(self.m_sText)
			self.m_iCaretPos = self.m_iSelectRight
		elseif key == "x" then
			love.system.setClipboardText(self:GetSelection())
			self.m_sText = self:GetPreSelection() .. self:GetPostSelection()
			self:UpdateUndoBuffer()
			self.m_iCaretPos = math.min(self.m_iCaretPos, utf8.len(self.m_sText))
			self:ResetSelection()
		elseif key == "c" then
			love.system.setClipboardText(self:GetSelection())
		elseif key == "v" then
			self:OnTextInput(love.system.getClipboardText())
		elseif key == "y" then
			local pop = table.remove(self.m_tRedoBuffer) or ""
			if pop ~= "" then
				self.m_sText = pop
				self:CaretGoToEnd()
				self:ResetSelection()
				table.insert(self.m_tUndoBuffer, pop)
			end
		elseif key == "z" then
			local pop = table.remove(self.m_tUndoBuffer) or ""
			self.m_sText = self.m_tUndoBuffer[#self.m_tUndoBuffer] or ""
			self:CaretGoToEnd()
			self:ResetSelection()
			if pop ~= "" then
				table.insert(self.m_tRedoBuffer, pop)
			end
		end
	end
end

function PANEL:OnKeyReleased(key)
end

gui.register("TextEntry", PANEL, "Panel")