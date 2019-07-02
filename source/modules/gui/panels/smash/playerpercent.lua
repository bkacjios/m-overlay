local memory = require("memory.watcher")

function PANEL:Initialize()
	self:super()

	self:SetSize(200, 200)

	self.m_pFontPercent = graphics.newFont("fonts/FOT-RodinPro-UB.otf", 64)
	self.m_pFontDecimal = graphics.newFont("fonts/FOT-RodinPro-UB.otf", 24)

	self.m_tPercents = { entity = 0, partner = 0 }
	self.m_tDecimals = { entity = 0, partner = 0 }
	self.m_tLastUpdate = {}

	memory.hook("player.*.*.percent", self, self.UpdatePercent)

	self:MakeAccessor("Port", "m_iPort")
end

function PANEL:UpdatePercent(port, entity, percent)
	if self:GetPort() == port then
		self.m_tPercents[entity] = math.floor(percent)
		self.m_tDecimals[entity] = math.floor(percent%1*10)
		if self.m_tPercents[entity] < percent then
			self.m_tLastUpdate[entity] = timer.getTime()
		end
	end
end

function PANEL:GetEntityUpdateTime(entity)
	return self.m_tLastUpdate[entity] or 0
end

function PANEL:GetPlayer()
	return memory.player[self:GetPort()]
end

function PANEL:GetEntity()
	return melee.getPlayerEntity(self:GetPort())
end

do
	local lerp = math.lerp

	function PANEL:GetPercentColor(percent)
		if percent <= 10 then
			return color_white
		elseif percent <= 35 then
			local fade = (percent-10)/25
			return hsl(lerp(60, 50, fade), 1, lerp(1, 0.5, fade))
		elseif percent <= 100 then
			local fade = (percent-35)/65
			return hsl(lerp(50, 0, fade), 1, 0.5)
		elseif percent <= 200 then
			local fade = (percent-100)/100
			return hsl(lerp(360, 344, fade), 1, lerp(0.5, 0.33, fade))
		end
		local fade = (percent-200)/799
		return hsl(344, 1, lerp(0.33, 0.24, fade))
	end
end

function PANEL:Paint(w, h)
	local t = timer.getTime()

	local player = self:GetPlayer()

	if not melee.isEntityAlive(melee.getEntity(player)) then return end

	local active = melee.getActiveEntityName(player)

	local percent = self.m_tPercents[active]
	local decimal = string.format(".%i%%", self.m_tDecimals[active])

	local percentW = self.m_pFontPercent:getWidth(percent)
	local percentH = self.m_pFontPercent:getHeight()/2

	local decimalW = self.m_pFontDecimal:getWidth(decimal)
	local decimalH = self.m_pFontDecimal:getWidth(decimal)/2

	local x = w - decimalW - percentW + 6
	local y = h/2 - percentH/2

	local sx, sy = 0, 0
	if self:GetEntityUpdateTime(active) + 0.25 >= t then
		sx = math.random(-8, 8)
		sy = math.random(-8, 8)
	end

	local pX, pY = x + sx, y + sy

	graphics.setFont(self.m_pFontPercent)
	graphics.setColor(0, 0, 0, 255)
	graphics.textOutline(percent, 4, pX + 2, pY + 2, 0, 1, 1, 0, 0, -0.15, 0)
	graphics.setColor(self:GetPercentColor(percent))
	graphics.print(percent, pX, pY, 0, 1, 1, 0, 0, -0.15, 0)

	local dX, dY = sx + w - decimalW, h/2 + sy

	graphics.setFont(self.m_pFontDecimal)
	graphics.setColor(0, 0, 0, 255)
	graphics.textOutline(decimal, 2, dX + 1, dY + 1, 0, 1, 1, 0, 0, -0.15, 0)
	graphics.setColor(self:GetPercentColor(percent))
	graphics.print(decimal, dX, dY, 0, 1, 1, 0, 0, -0.15, 0)

	if player.character == CHARACTER.CLIMBERS and melee.isEntityAlive(player.partner) then
		percent = player.partner.percent
		local display = ("%.1f%%"):format(percent)

		local sx, sy = 0, 0
		if self:GetEntityUpdateTime("partner") + 0.25 >= t then
			sx = math.random(-8, 8)
			sy = math.random(-8, 8)
		end

		graphics.setColor(color_black)
		graphics.textOutlinef(display, 2, sx, y + percentH + sy, w, "right", 0, 1, 1, 0, 0, -0.15, 0)
		graphics.setColor(self:GetPercentColor(percent))
		graphics.printf(display, sx, y + percentH + sy, w, "right", 0, 1, 1, 0, 0, -0.15, 0)

		--graphics.setColor(color_white)
		--overlay.drawStockIcon(character, overlay.nana_skins[player.skin] or 0, percentH + 64, 112)
	end
end

gui.register("PlayerPercent", PANEL, "Panel")