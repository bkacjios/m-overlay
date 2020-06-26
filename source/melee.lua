local memory = require("memory")
local color = require("util.color")

local character_selections = {
	[0x00] = {
		name = "captain",
		skin = {"original", "black", "red", "white", "green", "blue"},
		team_skin = {3, 6, 5},
		series = "fzero"
	},
	[0x01] = {
		name = "donkey",
		skin = {"original", "black", "red", "blue", "green"},
		team_skin = {3, 4, 5},
		series = "donkey_kong"
	},
	[0x02] = {
		name = "fox",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "star_fox"
	},
	[0x03] = {
		name = "gamewatch",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "game_and_watch"
	},
	[0x04] = {
		name = "kirby",
		skin = {"original", "yellow", "blue", "red", "green", "white"},
		team_skin = {4, 3, 5},
		series = "kirby"
	},
	[0x05] = {
		name = "koopa",
		skin = {"green", "red", "blue", "black"},
		team_skin = {2, 3, 1},
		series = "mario"
	},
	[0x06] = {
		name = "link",
		skin = {"green", "red", "blue", "black", "white"},
		team_skin = {2, 3, 1},
		series = "zelda"
	},
	[0x07] = {
		name = "luigi",
		skin = {"green", "white", "blue", "red"},
		team_skin = {4, 3, 1},
		series = "mario"
	},
	[0x08] = {
		name = "mario",
		skin = {"red", "yellow", "black", "blue", "green"},
		team_skin = {1, 4, 5},
		series = "mario"
	},
	[0x09] = {
		name = "marth",
		skin = {"original", "red", "green", "black", "white"},
		team_skin = {2, 1, 3},
		series = "fire_emblem"
	},
	[0x10] = {
		name = "samus",
		skin = {"red", "pink", "black", "green", "blue"},
		team_skin = {1, 5, 4},
		series = "metroid"
	},
	[0x11] = {
		name = "yoshi",
		skin = {"green", "red", "blue", "yellow", "pink", "light_blue"},
		team_skin = {2, 3, 1},
		series = "yoshi"
	},
	[0x12] = {
		name = "zelda",
		skin = {"original", "red", "blue", "green", "white"},
		team_skin = {2, 3, 4},
		series = "zelda"
	},
	[0x13] = {
		name = "sheik",
		skin = {"original", "red", "blue", "green", "white"},
		team_skin = {2, 3, 4},
		series = "zelda"
	},
	[0x14] = {
		name = "falco",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "star_fox"
	},
	[0x15] = {
		name = "younglink",
		skin = {"green", "red", "blue", "black", "white"},
		team_skin = {2, 3, 1},
		series = "zelda"
	},
	[0x16] = {
		name = "mariod",
		skin = {"white", "red", "blue", "green", "black"},
		team_skin = {2, 3, 4},
		series = "mario"
	},
	[0x17] = {
		name = "roy",
		skin = {"original", "red", "blue", "green", "yellow"},
		team_skin = {2, 3, 4},
		series = "fire_emblem"
	},
	[0x18] = {
		name = "pichu",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x19] = {
		name = "ganon",
		skin = {"original", "red", "blue", "green", "purple"},
		team_skin = {2, 3, 4},
		series = "zelda"
	},
	[0x0A] = {
		name = "mewtwo",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x0B] = {
		name = "ness",
		skin = {"original", "yellow", "blue", "green"},
		team_skin = {1, 3, 4},
		series = "earthbound"
	},
	[0x0C] = {
		name = "peach",
		skin = {"original", "daisy", "white", "blue", "green"},
		team_skin = {1, 4, 5},
		series = "mario"
	},
	[0x0D] = {
		name = "pikachu",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x0E] = {
		name = "ice_climber",
		skin = {"original", "green", "orange", "red"},
		team_skin = {4, 1, 2},
		series = "ice_climbers"
	},
	[0x0F] = {
		name = "purin",
		skin = {"original", "red", "blue", "green", "crown"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x21] = {
		name = "wireframe",
		series = "smash"
	},
}


local textures = {
	series = {},
	stocks = {},
}

local graphics = love.graphics
local newImage = graphics.newImage

local melee = {}

function melee.loadtextures()
	for cid, info in pairs(character_selections) do
		textures.series[cid] = newImage(("textures/series/%s.png"):format(info.series))
		if info.skin then
			for sid, skin in ipairs(info.skin) do
				textures.stocks[cid] = textures.stocks[cid] or {}
				textures.stocks[cid][sid-1] = newImage(("textures/stocks/%s-%s.png"):format(info.name, skin))
			end
		end
	end
end


function melee.getCharacterID(port)
	if not memory.player then return end
	local player = memory.player[port]

	if not player then return end

	local character = player.character
	local transformed = player.transformed == 256

	-- Handle and detect Zelda/Sheik transformations
	if character == 0x13 then
		character = transformed and 0x12 or 0x13
	elseif character == 0x12 then
		character = transformed and 0x13 or 0x12
	end

	return character
end

function melee.getStockTexture(id, skin)
	if not textures.stocks[id] or not textures.stocks[id][skin] then
		return textures.stocks[0x21]
	end
	return textures.stocks[id][skin]
end

function melee.getSeriesTexture(id)
	if not textures.series[id] then
		return textures.series[0x21]
	end
	return textures.series[id]
end

function melee.drawSeries(port, ...)
	local id = melee.getCharacterID(port)
	if not id then return end
	local series = melee.getSeriesTexture(id)
	if not series then return end
	graphics.easyDraw(series, ...)
end

function melee.drawStock(port, ...)
	local id = melee.getCharacterID(port)
	if not memory.player then return end
	local player = memory.player[port]
	if not player or not id then return end
	local stock = melee.getStockTexture(id, player.skin)
	if not stock then return end
	graphics.easyDraw(stock, ...)
end

local TEAM_COLORS = {
	[0x00] = color(255, 0, 0, 255),		-- Red
	[0x01] = color(0, 100, 255, 255),	-- Blue
	[0x02] = color(0, 255, 0, 255),		-- Green
	[0x04] = color(200, 200, 200, 255),	-- CPU/Disabled
}

function melee.getPlayerTeamColor(port)
	if not memory.player then return end
	local player = memory.player[port]
	return TEAM_COLORS[player.team] or color_white
end

local PLAYER_COLORS = {
	[1] = color(245, 46, 46, 255),
	[2] = color(84, 99, 255, 255),
	[3] = color(255, 199, 23, 255),
	[4] = color(31, 158, 64, 255),
}

function melee.getPlayerColor(port)
	return PLAYER_COLORS[port] or color_white
end

return melee