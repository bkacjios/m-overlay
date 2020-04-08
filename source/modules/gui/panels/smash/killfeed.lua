local PANEL = {}

local memory = require("memory.watcher")
local state = require("smash.states")
local notification = require("notification")

function PANEL:Initialize()
	self:super()

	self:SetSize(512, 256)
	
	self:DockPadding(0,0,0,0)
	self:DockMargin(0,0,0,0)

	self.m_tLastPlayerHit = {}

	self:DisableScissor()

	memory.hook("player.*.*.percent", self, self.OnPlayerHit)
	memory.hook("player.*.*.action_state", self, self.OnPlayerAction)
end

function PANEL:OnRemoved()
	memory.unhook("player.*.*.percent", self)
	memory.unhook("player.*.*.action_state", self)
end

function PANEL:OnPlayerHit(num, type, percent)
	local player = memory.player[num][type]

	local attacker_port = player.attacker

	-- Attacker = 6 means if they die, it will be a SD
	if attacker_port < 0 or attacker_port >= 6 then
		self.m_tLastPlayerHit[num] = nil
		return
	end

	attacker_port = attacker_port + 1

	local attacker_player = melee.getPlayer(attacker_port)
	local attacker_entity = melee.getEntity(attacker_player)

	self.m_tLastPlayerHit[num] = { cid = attacker_entity.character, state = attacker_entity.action_state }

	print("HIT", melee.getPlayerEntityCharacterName(attacker_entity), attacker_entity.action_state, state.translateChar(attacker_entity.character, attacker_entity.action_state))
end

function PANEL:OnPlayerAction(num, type, state_id)
	if memory.menu ~= MENU.IN_GAME then return end

	local player_ent = memory.player[num][type]

	-- 0x8 and 0x8 = player hitting the camera
	-- 0xA = ice climbers hit camera
	-- This happens after they get marked as dead, so ignore so we don't get two messages

	if state_id >= 0x0 and state_id <= 0xA and state_id ~= 0x7 and state_id ~= 0x8 and state_id ~= 0xA then
		local killer = melee.getPlayerEntityAttacker(player_ent)
		local killed = player_ent

		local last_attack = self.m_tLastPlayerHit[num]

		local attack

		if last_attack and killer ~= killed then
			attack = state.translateChar(last_attack.cid, last_attack.state)
		--[[elseif last_attack and last_attack.state then
			print(num, "unknown move", ("%04X"):format(last_attack.state))]]
		end

		if not attack then
			if killer ~= killed then
				attack = "knocked out"
			else
				attack = "suicided"
			end
		end

		local p1_color = melee.getPlayerEntityColor(killer)
		local p1_name = melee.getPlayerEntityCharacterName(killer):upper()
		local p1_width = notification.font:getWidth(p1_name)

		local p2_name = melee.getPlayerEntityCharacterName(killed):upper()
		local p2_color = melee.getPlayerEntityColor(killed)
		local attack_width = notification.font:getWidth(attack)

		notification.add(20, 8, 0.5, function(height, fade)
			graphics.setFont(notification.font)

			graphics.setColor(0, 0, 0, 255 * fade)
			graphics.textOutline(p1_name, 1, 1, 1)
			graphics.setColor(p1_color.r, p1_color.g, p1_color.b, 255 * fade)
			graphics.print(p1_name, 0, 0)

			graphics.setColor(0, 0, 0, 255 * fade)
			graphics.textOutline(attack, 1, p1_width + 5, 1)
			graphics.setColor(255, 255, 255, 255 * fade)
			graphics.print(attack, p1_width + 4, 0)

			if killer ~= killed then
				graphics.setColor(0, 0, 0, 255 * fade)
				graphics.textOutline(p2_name, 1, p1_width + attack_width + 9, 1)
				graphics.setColor(p2_color.r, p2_color.g, p2_color.b, 255 * fade)
				graphics.print(p2_name, p1_width + attack_width + 8, 0)
			end
		end)
	end

	local cid = player_ent.character
	local attack = state.translateChar(cid, state_id)

	if attack then
		local name = melee.getPlayerEntityCharacterName(player_ent):upper()
		print(name, attack)
		--[[notification.add(16, 2, 0.5, function(height, fade)
			local color = melee.getPlayerEntityColor(player_ent)
			local name = melee.getPlayerEntityCharacterName(player_ent):upper()

			if not color then return end

			local nameW = notification.font:getWidth(name)

			graphics.setFont(notification.font)
			graphics.setColor(color.r, color.g, color.b, 255 * fade)
			graphics.print(name, 0, 0)

			graphics.setFont(notification.font)
			graphics.setColor(255, 255, 255, 255 * fade)
			graphics.print(attack, nameW + 4, 0)
		end)]]
	elseif num == 1 then
		print(num, type, ("%04X"):format(state_id))
	end
end

function PANEL:Think(dt)
	notification.update(0, 0)
end

function PANEL:Paint(w, h)
	notification.draw()
end

gui.register("KillFeed", PANEL, "Base")