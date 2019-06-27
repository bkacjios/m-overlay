local memory = require("memory.watcher")

require("smash.enums")

local util = require("smash.util")

local melee = {}

function melee.getTeamColor(id)
	return TEAM_COLORS[id] or TEAM_COLORS[0x04]
end

function melee.getPlayer(id)
	return memory.player[id]
end

function melee.getPortColor(port)
	if not port then return TEAM_COLORS[4] end
	local player = memory.player[port]
	return memory.teams and TEAM_COLORS[player.select.team] or PLAYER_COLORS[port-1]
end

function melee.getPlayerColor(player)
	if not player or not player.team then return TEAM_COLORS[4] end
	return memory.teams and TEAM_COLORS[player.team] or PLAYER_COLORS[player.port]
end

function melee.getPlayerEntityColor(entity)
	if not entity or not entity.team then return TEAM_COLORS[4] end
	return memory.teams and TEAM_COLORS[entity.team] or PLAYER_COLORS[entity.port]
end

function melee.getPlayerCharacterName(player)
	if not player then return "NULL" end
	local entity = melee.getEntity(player)
	return melee.getPlayerEntityCharacterName(entity)
end

function melee.getPlayerEntityCharacterName(entity)
	if not entity then return "NULL" end
	return util.getInternalCharacterName(entity.character)
end

function melee.getPlayerEntity(id)
	return melee.getEntity(melee.getPlayer(id))
end

function melee.isPlayerTransformed(player)
	return player.transformed == 256
end

function melee.getPlayerEntityAttacker(entity)
	if entity.attacker < 0 or entity.attacker >= 6 then
		return entity -- They killed themselves
	end
	local port = entity.attacker + 1
	return melee.getEntity(melee.getPlayer(port)), port
end

function melee.getEntity(player)
	local character = player.character
	local transformed = player.transformed == 256
	if (character == CHARACTER.ZELDA or character == CHARACTER.SHEIK) and transformed then
		-- If the character started as zelda or shiek, and they transformed
		-- return their partner entity (Which is the active entity)
		-- A player can start as Sheik by holding A when loading in, so their character ID would be Shiek instead of Zelda
		return player.partner
	else
		return player.entity
	end
end

-- action_state 0x0-0xA means the player is dead
-- action_state 0xB = Sleep (Dead/Waiting to respawn)
-- action_state 0xC = Respawning
-- action_state 0xD = Waiting on respawn platform

function melee.isEntityActive(entity)
	return entity and entity.action_state and entity.action_state ~= 0xB
end

function melee.isEntityAlive(entity)
	return entity and entity.action_state and entity.action_state > 0xB
end

function melee.isEntityRespawning(entity)
	return entity and entity.action_state and entity.action_state >= 0xC and entity.action_state <= 0xD
end

function melee.isEntityOffCamera(entity)
	if entity then
		local offset = memory.stage.offset
		local camera = memory.camera.limit
		local x, y = entity.position.x - offset.x, entity.position.y - offset.y
		if x <= camera.left or x >= camera.right or y <= camera.bottom or y >= camera.top then
			return true
		end
	end
	return false
end

function melee.setNametag(slot, string)
	-- Size of slot = 0x1A4
	-- Slot 1 = 0x0045D850
	-- Slot 2 = 0x0045D9F4
	memory.writeString(0x8045D850 + (0x1A4 * slot), string:sub(0,8))
end

function melee.getActivePlayers()
	local active = {}

	-- Add all active controller ports to a table..
	for port, player in pairs(memory.player) do
		if player.select.mode ~= PLAYER.DISABLED then
			table.insert(active, port)
		end
	end

	return active
end

function melee.getActiveTeams()
	local teams = {}

	-- Add all active teams to a table
	for port, player in pairs(memory.player) do
		local team = player.select.team
		if player.select.mode ~= PLAYER.DISABLED and not table.hasValue(teams, team) then
			table.insert(teams, team)
		end
	end

	return teams
end

return melee