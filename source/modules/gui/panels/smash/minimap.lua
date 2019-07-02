local memory = require("memory.watcher")

function PANEL:Initialize()
	self:super()

	self.m_pCircle = graphics.newImage("textures/circle.png")

	self.m_fFadeTime = 0.5
	self.m_fFadeEnd = 0

	self:SetSize(192, 256)
end

function PANEL:GetEntityUpdateTime(entity)
	return self.m_tLastUpdate[entity] or 0
end

function PANEL:GetPlayer()
	return memory.player[self:GetPort()]
end

function PANEL:Paint(w, h)
	local t = timer.getTime()

	for i=1,4 do
		local player = melee.getPlayer(i)
		if		(melee.isEntityActive(player.entity) and not melee.isEntityRespawning(player.entity) and melee.isEntityOffCamera(player.entity))
			or	(melee.isEntityActive(player.partner) and not melee.isEntityRespawning(player.partner) and melee.isEntityOffCamera(player.partner)) then
			self.m_fFadeEnd = t + self.m_fFadeTime
		end
	end

	if self.m_fFadeEnd < t then return end

	local fade = math.max(0, self.m_fFadeEnd - t) / self.m_fFadeTime

	local minimapPosx = w
	local minimapPosY = 0

	local zone = memory.stage.blastzone
	local stageW = zone.right - zone.left
	local stageH = zone.top - zone.bottom

	local camera = memory.camera.limit
	local offset = memory.stage.offset

	local cameraW = camera.right - camera.left
	local cameraH = camera.top - camera.bottom

	local minimapW = w
	local minimapH = minimapW*(stageH/stageW)

	local scale = minimapW/stageW

	graphics.setColor(0, 0, 0, 100 * fade)
	graphics.rectangle("fill", minimapPosx - minimapW, minimapPosY, minimapW, minimapH)
	graphics.setColor(255, 255, 255, 200 * fade)
	graphics.innerRectangle(minimapPosx - minimapW, minimapPosY, minimapW, minimapH)

	local top_x = 1 - (camera.left - zone.left) / stageW
	local top_y = 1 - (camera.top - zone.bottom) / stageH

	graphics.setColor(255, 255, 255, 200 * fade)
	graphics.rectangle("line", minimapPosx - (top_x*minimapW), minimapPosY + (top_y*minimapH), cameraW * scale, cameraH * scale)

	for i=4,1,-1 do
		local player = memory.player[i]

		local color = melee.getPlayerEntityColor(player.entity)

		if color then
			graphics.setColor(color.r, color.g, color.b, 255*fade)

			if melee.isEntityActive(player.entity) then
				local pos = player.position

				local x = 1 - (pos.x - offset.x - zone.left) / stageW
				local y = 1 - (pos.y - offset.y - zone.bottom) / stageH

				graphics.easyDraw(self.m_pCircle, minimapPosx - (x*minimapW), minimapPosY + (y*minimapH), 0, 12, 12, 0.5, 0.5)
			end
			if melee.isEntityActive(player.partner) then
				local pos = player.partner_position
				
				local x = 1 - (pos.x - offset.x - zone.left) / stageW
				local y = 1 - (pos.y - offset.y - zone.bottom) / stageH
				graphics.easyDraw(self.m_pCircle, minimapPosx - (x*minimapW), minimapPosY + (y*minimapH), 0, 12, 12, 0.5, 0.5)
			end
		end
	end
end

gui.register("MiniMap", PANEL, "Panel")