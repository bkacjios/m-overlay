local memory = require("memory")
local color = require("util.color")

MATCH_NO_RESULT = 0x00
MATCH_GAME = 0x02
MATCH_STAGE_CLEAR = 0x03
MATCH_STAGE_FAILURE = 0x04
MATCH_STAGE_CLEAR3 = 0x05
MATCH_NEW_RECORD = 0x06
MATCH_NO_CONTEST = 0x07
MATCH_RETRY = 0x08
MATCH_GAME_CLEAR = 0x09

-- MAJOR FLAGS
MENU_TITLE_SCREEN = 0x00
MENU_MAIN_MENU = 0x01
MENU_VS_MODE = 0x02

	-- MINOR FLAGS
	MENU_VS_CSS = 0x0
	MENU_VS_SSS = 0x1
	MENU_VS_INGAME = 0x2
	MENU_VS_POSTGAME = 0x4

MENU_CLASSIC_MODE = 0x03

	MENU_CLASSIC_LEVEL_1_VS  = 0x00
	MENU_CLASSIC_LEVEL_1 = 0x01
	MENU_CLASSIC_LEVEL_2_VS = 0x02
	MENU_CLASSIC_LEVEL_2 = 0x03
	MENU_CLASSIC_LEVEL_3_VS = 0x04
	MENU_CLASSIC_LEVEL_3 = 0x05
	MENU_CLASSIC_LEVEL_4_VS = 0x06
	MENU_CLASSIC_LEVEL_4 = 0x07
	MENU_CLASSIC_LEVEL_5_VS = 0x08
	MENU_CLASSIC_LEVEL_5 = 0x09
	MENU_CLASSIC_LEVEL_5_VS = 0x10
	MENU_CLASSIC_LEVEL_5 = 0x09

	MENU_CLASSIC_LEVEL_16 = 0x20
	MENU_CLASSIC_LEVEL_16_VS = 0x21

	MENU_CLASSIC_LEVEL_24 = 0x30
	MENU_CLASSIC_LEVEL_24_VS = 0x31

	MENU_CLASSIC_BREAK_THE_TARGETS_INTRO = 0x16
	MENU_CLASSIC_BREAK_THE_TARGETS = 0x17

	MENU_CLASSIC_TROPHY_STAGE_INTRO = 0x28
	MENU_CLASSIC_TROPHY_STAGE_TARGETS = 0x29

	MENU_CLASSIC_RACE_TO_FINISH_INTRO = 0x40
	MENU_CLASSIC_RACE_TO_FINISH_TARGETS = 0x41

	MENU_CLASSIC_LEVEL_56 = 0x38
	MENU_CLASSIC_LEVEL_56_VS = 0x39

	MENU_CLASSIC_MASTER_HAND = 0x51

	MENU_CLASSIC_CONTINUE = 0x69
	MENU_CLASSIC_CSS = 0x70

MENU_ADVENTURE_MODE = 0x04

	MENU_ADVENTURE_MUSHROOM_KINGDOM_INTRO = 0x00
	MENU_ADVENTURE_MUSHROOM_KINGDOM = 0x01
	MENU_ADVENTURE_MUSHROOM_KINGDOM_LUIGI = 0x02
	MENU_ADVENTURE_MUSHROOM_KINGDOM_BATTLE = 0x03

	MENU_ADVENTURE_MUSHROOM_KONGO_JUNGLE_INTRO = 0x08
	MENU_ADVENTURE_MUSHROOM_KONGO_JUNGLE_TINY_BATTLE = 0x09
	MENU_ADVENTURE_MUSHROOM_KONGO_JUNGLE_GIANT_BATTLE = 0x0A

	MENU_ADVENTURE_UNDERGROUND_MAZE_INTRO = 0x10
	MENU_ADVENTURE_UNDERGROUND_MAZE = 0x11
	MENU_ADVENTURE_HYRULE_TEMPLE_BATTLE = 0x12

	MENU_ADVENTURE_BRINSTAR_INTRO = 0x18
	MENU_ADVENTURE_BRINSTAR = 0x19

	MENU_ADVENTURE_ESCAPE_ZEBES_INTRO = 0x1A
	MENU_ADVENTURE_ESCAPE_ZEBES = 0x1B
	MENU_ADVENTURE_ESCAPE_ZEBES_ESCAPE = 0x1C

	MENU_ADVENTURE_GREEN_GREENS_INTRO = 0x20
	MENU_ADVENTURE_GREEN_GREENS_KIRBY_BATTLE = 0x21
	MENU_ADVENTURE_GREEN_GREENS_KIRBY_TEAM_INTRO = 0x22
	MENU_ADVENTURE_GREEN_GREENS_KIRBY_TEAM_BATTLE = 0x23
	MENU_ADVENTURE_GREEN_GREENS_GIANT_KIRBY_INTRO = 0x24
	MENU_ADVENTURE_GREEN_GREENS_GIANT_KIRBY_BATTLE = 0x25

	MENU_ADVENTURE_CORNARIA_INTRO = 0x28
	MENU_ADVENTURE_CORNARIA_BATTLE_1 = 0x29
	MENU_ADVENTURE_CORNARIA_RAID = 0x2A
	MENU_ADVENTURE_CORNARIA_BATTLE_2 = 0x2B
	MENU_ADVENTURE_CORNARIA_BATTLE_3 = 0x2C

	MENU_ADVENTURE_POKEMON_STADIUM_INTRO = 0x30
	MENU_ADVENTURE_POKEMON_STADIUM_BATTLE = 0x31

	MENU_ADVENTURE_FZERO_GRAND_PRIX_CARS = 0x38
	MENU_ADVENTURE_FZERO_GRAND_PRIX_INTRO = 0x39
	MENU_ADVENTURE_FZERO_GRAND_PRIX_RACE = 0x3A
	MENU_ADVENTURE_FZERO_GRAND_PRIX_BATTLE = 0x3B

	MENU_ADVENTURE_ONETT_INTRO = 0x40
	MENU_ADVENTURE_ONETT_BATTLE = 0x41

	MENU_ADVENTURE_ICICLE_MOUNTAIN_INTRO = 0x48
	MENU_ADVENTURE_ICICLE_MOUNTAIN_CLIMB = 0x49

	MENU_ADVENTURE_BATTLEFIELD_INTRO = 0x50
	MENU_ADVENTURE_BATTLEFIELD_BATTLE = 0x51
	MENU_ADVENTURE_BATTLEFIELD_METAL_INTRO = 0x52
	MENU_ADVENTURE_BATTLEFIELD_METAL_BATTLE = 0x53

	MENU_ADVENTURE_FINAL_DESTINATION_INTRO = 0x58
	MENU_ADVENTURE_FINAL_DESTINATION_BATTLE = 0x59
	MENU_ADVENTURE_FINAL_DESTINATION_POSE = 0x5A
	MENU_ADVENTURE_FINAL_DESTINATION_WINNER = 0x5B

	MENU_ADVENTURE_CSS = 0x70

MENU_ALL_STAR_MODE = 0x05
	MENU_ALL_STAR_LEVEL_1 = 0x00
	MENU_ALL_STAR_REST_AREA_1 = 0x01
	MENU_ALL_STAR_LEVEL_2 = 0x02
	MENU_ALL_STAR_REST_AREA_2 = 0x03
	MENU_ALL_STAR_LEVEL_3 = 0x04
	MENU_ALL_STAR_REST_AREA_3 = 0x05
	MENU_ALL_STAR_LEVEL_4 = 0x06
	MENU_ALL_STAR_REST_AREA_4 = 0x07
	MENU_ALL_STAR_LEVEL_5 = 0x08
	MENU_ALL_STAR_REST_AREA_5 = 0x09
	MENU_ALL_STAR_LEVEL_6 = 0x10
	MENU_ALL_STAR_REST_AREA_6 = 0x11
	MENU_ALL_STAR_LEVEL_7 = 0x12
	MENU_ALL_STAR_REST_AREA_7 = 0x13
	MENU_ALL_STAR_LEVEL_8 = 0x14
	MENU_ALL_STAR_REST_AREA_8 = 0x15
	MENU_ALL_STAR_LEVEL_9 = 0x16
	MENU_ALL_STAR_REST_AREA_9 = 0x17
	MENU_ALL_STAR_LEVEL_10 = 0x18
	MENU_ALL_STAR_REST_AREA_10 = 0x19
	MENU_ALL_STAR_LEVEL_11 = 0x20
	MENU_ALL_STAR_REST_AREA_11 = 0x21
	MENU_ALL_STAR_LEVEL_12 = 0x22
	MENU_ALL_STAR_REST_AREA_12 = 0x23
	MENU_ALL_STAR_LEVEL_13 = 0x24
	MENU_ALL_STAR_REST_AREA_13 = 0x25
	MENU_ALL_STAR_LEVEL_14 = 0x26
	MENU_ALL_STAR_REST_AREA_14 = 0x27
	MENU_ALL_STAR_LEVEL_15 = 0x28
	MENU_ALL_STAR_REST_AREA_15 = 0x29
	MENU_ALL_STAR_LEVEL_16 = 0x30
	MENU_ALL_STAR_REST_AREA_16 = 0x31
	MENU_ALL_STAR_LEVEL_17 = 0x32
	MENU_ALL_STAR_REST_AREA_17 = 0x33
	MENU_ALL_STAR_LEVEL_18 = 0x34
	MENU_ALL_STAR_REST_AREA_18 = 0x35
	MENU_ALL_STAR_LEVEL_19 = 0x36
	MENU_ALL_STAR_REST_AREA_19 = 0x37
	MENU_ALL_STAR_LEVEL_20 = 0x38
	MENU_ALL_STAR_REST_AREA_20 = 0x39
	MENU_ALL_STAR_LEVEL_21 = 0x40
	MENU_ALL_STAR_REST_AREA_21 = 0x41
	MENU_ALL_STAR_LEVEL_22 = 0x42
	MENU_ALL_STAR_REST_AREA_22 = 0x43
	MENU_ALL_STAR_LEVEL_23 = 0x44
	MENU_ALL_STAR_REST_AREA_23 = 0x45
	MENU_ALL_STAR_LEVEL_24 = 0x46
	MENU_ALL_STAR_REST_AREA_24 = 0x47
	MENU_ALL_STAR_LEVEL_25 = 0x48
	MENU_ALL_STAR_REST_AREA_25 = 0x49
	MENU_ALL_STAR_LEVEL_26 = 0x50
	MENU_ALL_STAR_REST_AREA_26 = 0x51
	MENU_ALL_STAR_LEVEL_27 = 0x52
	MENU_ALL_STAR_REST_AREA_28 = 0x53
	MENU_ALL_STAR_LEVEL_29 = 0x54
	MENU_ALL_STAR_REST_AREA_29 = 0x55
	MENU_ALL_STAR_LEVEL_30 = 0x56
	MENU_ALL_STAR_REST_AREA_30 = 0x57
	MENU_ALL_STAR_LEVEL_31 = 0x58
	MENU_ALL_STAR_REST_AREA_31 = 0x59
	MENU_ALL_STAR_LEVEL_32 = 0x60
	MENU_ALL_STAR_REST_AREA_32 = 0x61

	MENU_ALL_STAR_CSS = 0x70

MENU_DEBUG = 0x06
MENU_SOUND_TEST = 0x07

MENU_VS_UNKNOWN = 0x08 -- SLIPPI UNRANKED
	MENU_VS_UNKNOWN_CSS = 0x00
	MENU_VS_UNKNOWN_SSS = 0x01
	MENU_VS_UNKNOWN_INGAME = 0x02
	MENU_VS_UNKNOWN_POSTGAME = 0x04

MENU_UNKOWN_1 = 0x09
MENU_CAMERA_MODE = 0x0A
MENU_TROPHY_GALLERY = 0x0B
MENU_TROPHY_LOTTERY = 0x0C
MENU_TROPHY_COLLECTION = 0x0D
MENU_START_MATCH = 0x0E

MENU_TARGET_TEST = 0x0F
	MENU_TARGET_TEST_CSS = 0x00
	MENU_TARGET_TEST_INGAME = 0x1

MENU_SUPER_SUDDEN_DEATH = 0x10
	MENU_SSD_CSS = 0x00
	MENU_SSD_SSS = 0x01
	MENU_SSD_INGAME = 0x02
	MENU_SSD_POSTGAME = 0x04

MENU_INVISIBLE_MELEE = 0x11
	MENU_INVISIBLE_MELEE_CSS = 0x00
	MENU_INVISIBLE_MELEE_SSS = 0x01
	MENU_INVISIBLE_MELEE_INGAME = 0x02
	MENU_INVISIBLE_MELEE_POSTGAME = 0x04

MENU_SLOW_MO_MELEE = 0x12
	MENU_SLOW_MO_MELEE_CSS = 0x00
	MENU_SLOW_MO_MELEE_SSS = 0x01
	MENU_SLOW_MO_MELEE_INGAME = 0x02
	MENU_SLOW_MO_MELEE_POSTGAME = 0x04

MENU_LIGHTNING_MELEE = 0x13
	MENU_LIGHTNING_MELEE_CSS = 0x00
	MENU_LIGHTNING_MELEE_SSS = 0x01
	MENU_LIGHTNING_MELEE_INGAME = 0x02
	MENU_LIGHTNING_MELEE_POSTGAME = 0x04

MENU_CHARACTER_APPROACHING = 0x14

MENU_CLASSIC_MODE_COMPLETE = 0x15
	MENU_CLASSIC_MODE_TROPHY = 0x00
	MENU_CLASSIC_MODE_CREDITS = 0x01
	MENU_CLASSIC_MODE_CHARACTER_VIDEO = 0x02
	MENU_CLASSIC_MODE_CONGRATS = 0x03

MENU_ADVENTURE_MODE_COMPLETE = 0x16
	MENU_ADVENTURE_MODE_TROPHY = 0x00
	MENU_ADVENTURE_MODE_CREDITS = 0x01
	MENU_ADVENTURE_MODE_CHARACTER_VIDEO = 0x02
	MENU_ADVENTURE_MODE_CONGRATS = 0x03

MENU_ALL_STAR_COMPLETE = 0x17
	MENU_ALL_STAR_TROPHY = 0x00
	MENU_ALL_STAR_CREDITS = 0x01
	MENU_ALL_STAR_CHARACTER_VIDEO = 0x02
	MENU_ALL_STAR_CONGRATS = 0x03

MENU_INTRO_VIDEO = 0x18
	MENU_INTRO_VIDEO_PLAYING = 0x0
	MENU_INTRO_VIDEO_DEMO_FIGHT = 0x1

MENU_ADVENTURE_MODE_CINEMEATIC = 0x19
MENU_CHARACTER_UNLOCKED = 0x1A

MENU_TOURNAMENT = 0x1B
	MENU_TOURNAMENT_CSS = 0x0
	MENU_TOURNAMENT_BRACKET = 0x1
	MENU_TOURNAMENT_INGAME = 0x4
	MENU_TOURNAMENT_POSTGAME = 0x6

MENU_TRAINING_MODE = 0x1C
	MENU_TRAINING_CSS = 0x0
	MENU_TRAINING_SSS = 0x1
	MENU_TRAINING_INGAME = 0x2

MENU_TINY_MELEE = 0x1D
	MENU_TINY_MELEE_CSS = 0x0
	MENU_TINY_MELEE_SSS = 0x1
	MENU_TINY_MELEE_INGAME = 0x2
	MENU_TINY_MELEE_POSTGAME = 0x4

MENU_GIANT_MELEE = 0x1E
	MENU_GIANT_MELEE_CSS = 0x0
	MENU_GIANT_MELEE_SSS = 0x1
	MENU_GIANT_MELEE_INGAME = 0x2
	MENU_GIANT_MELEE_POSTGAME = 0x4

MENU_STAMINA_MODE = 0x1F
	MENU_STAMINA_MODE_CSS = 0x0
	MENU_STAMINA_MODE_SSS = 0x1
	MENU_STAMINA_MODE_INGAME = 0x2
	MENU_STAMINA_MODE_POSTGAME = 0x4

MENU_HOME_RUN_CONTEST = 0x20
	MENU_HOME_RUN_CONTEST_CSS = 0x0
	MENU_HOME_RUN_CONTEST_INGAME = 0x1

MENU_10_MAN_MELEE = 0x21
	MENU_10_MAN_MELEE_CSS = 0x00
	MENU_10_MAN_MELEE_INGAME = 0x01

MENU_100_MAN_MELEE = 0x22
	MENU_100_MAN_MELEE_CSS = 0x00
	MENU_100_MAN_MELEE_INGAME = 0x01

MENU_3_MINUTE_MELEE = 0x23
	MENU_3_MINUTE_MELEE_CSS = 0x00
	MENU_3_MINUTE_MELEE_INGAME = 0x01

MENU_15_MINUTE_MELEE = 0x24
	MENU_15_MINUTE_MELEE_CSS = 0x00
	MENU_15_MINUTE_MELEE_INGAME = 0x01

MENU_ENDLESS_MELEE = 0x25
	MENU_ENDLESS_MELEE_CSS = 0x00
	MENU_ENDLESS_MELEE_INGAME = 0x01

MENU_CRUEL_MELEE = 0x26
	MENU_CRUEL_MELEE_CSS = 0x00
	MENU_CRUEL_MELEE_INGAME = 0x01
	
MENU_PROGRESSIVE_SCAN = 0x27
MENU_PLAY_INTRO_VIDEO = 0x28
MENU_MEMORY_CARD_OVERWRITE = 0x29

MENU_FIXED_CAMERA_MODE = 0x2A
	MENU_FIXED_CAMERA_MODE_CSS = 0x0
	MENU_FIXED_CAMERA_MODE_SSS = 0x1
	MENU_FIXED_CAMERA_MODE_INGAME = 0x2
	MENU_FIXED_CAMERA_MODE_POSTGAME = 0x4

MENU_EVENT_MATCH = 0x2B
	MENU_EVENT_MATCH_SELECT = 0x0
	MENU_EVENT_MATCH_INGAME = 0x1

MENU_SINGLE_BUTTON_MODE = 0x2C


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
		skin = {"green", "red", "blue", "white", "black"},
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
	[0x1A] = {
		name = "master_hand",
		skinless = true,
		series = "smash"
	},
	[0x1E] = {
		name = "crazy_hand",
		skinless = true,
		series = "smash"
	},
	[0x1D] = {
		name = "giga_bowser",
		skinless = true,
		series = "smash"
	},
	[0x21] = {
		name = "wireframe",
		skinless = true,
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
		else
			textures.stocks[cid] = newImage(("textures/stocks/%s.png"):format(info.name))
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
	if character_selections[id] and character_selections[id].skinless == true then
		return textures.stocks[id]
	end
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
	if id == 0x21 or not memory.player then return end
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

local char_replacement_map = {
	[0x8149] = "!", [0x8168] = "\"", [0x8194] = "#", [0x8190] = "$",
	[0x8193] = "%", [0x8195] = "&", [0x8166] = "'", [0x8169] = "(",
	[0x816A] = ")", [0x8196] = "*", [0x817B] = "+", [0x8143] = ",",
	[0x817C] = "-", [0x8144] = ".", [0x815E] = "/", [0x8146] = ":",
	[0x8147] = ";", [0x8183] = "<", [0x8181] = "=", [0x8184] = ">",
	[0x8148] = "?", [0x8197] = "@", [0x816D] = "[", [0x815F] = "\\",
	[0x816E] = "]", [0x814F] = "^", [0x8151] = "_", [0x814D] = "`",
	[0x816F] = "{", [0x8162] = "|", [0x8170] = "}", [0x8160] = "~",
}

function melee.convertStr(str)
	local niceStr = ""
	local i = 1
	while i <= #str do
		local c1 = string.sub(str, i, i)
		local b1 = string.byte(c1)

		if bit.band(b1, 0x80) == 0x80 then
			local c2 = string.sub(str, i + 1, i + 1)
			local b2 = string.byte(c2)

			local b16 = bit.bor(bit.lshift(b1, 8), bit.lshift(b2, 0))

			if char_replacement_map[b16] then
				niceStr = niceStr .. char_replacement_map[b16]
			end

			i = i + 2
		else
			niceStr = niceStr .. c1
			i = i + 1
		end
	end
	return niceStr
end

local STAGE_SERIES = {
	[0x02] = "Super Mario", -- Princess Peach's Castle
	[0x03] = "Super Mario", -- Rainbow Cruise
	[0x04] = "Donkey Kong", -- Kongo Jungle
	[0x05] = "Donkey Kong", -- Jungle Japes
	[0x06] = "The Legend of Zelda", -- Great Bay
	[0x07] = "The Legend of Zelda", -- Hyrule Temple
	[0x08] = "Metroid", -- Brinstar
	[0x09] = "Metroid", -- Brinstar Depths
	[0x0A] = "Yoshi", -- Yoshi's Story
	[0x0B] = "Yoshi", -- Yoshi's Island
	[0x0C] = "Kirby", -- Fountain of Dreams
	[0x0D] = "Kirby", -- Green Greens
	[0x0E] = "Star Fox", -- Corneria
	[0x0F] = "Star Fox", -- Venom
	[0x10] = "Pokémon", -- Pokémon Stadium
	[0x11] = "Pokémon", -- Poké Floats
	[0x12] = "F-Zero", -- Mute City
	[0x13] = "F-Zero", -- Big Blue
	[0x14] = "Earthbound", -- Onett
	[0x15] = "Earthbound", -- Fourside
	[0x16] = "Ice Climbers", -- Icicle Mountain
	[0x18] = "Super Mario", -- Mushroom Kingdom
	[0x19] = "Super Mario", -- Mushroom Kingdom 2
	[0x1B] = "Game & Watch", -- Flat Zone
	[0x1C] = "Kirby", -- Dream Land N64
	[0x1D] = "Yoshi", -- Yoshi's Island N64
	[0x1E] = "Donkey Kong", -- Kongo Jungle N64
	[0x24] = "Super Smash Bros", -- Battlefield
	[0x25] = "Super Smash Bros", -- Final Destination
	[0x26] = "Super Smash Bros", -- Trophy Collection

	-- Singleplayer stages
	[0x1F] = "Super Mario", -- Mushroom Kingdom
	[0x20] = "The Legend of Zelda", -- Underground Maze
	[0x21] = "Metroid", -- Escape Zebes
	[0x22] = "F-Zero", -- F-Zero Grand Prix
	[0x26] = "Super Smash Bros", -- Trophy Collection
	[0x27] = "Super Smash Bros", -- Race to the Finish
	[0x42] = "Super Smash Bros", -- All-Star Rest Area
	[0x43] = "Super Smash Bros", -- Home-Run Contest
	[0x44] = "Super Mario", -- Trophy Tussel - Goomba
	[0x45] = "Pokémon", -- Trophy Tussel - Entei
	[0x46] = "The Legend of Zelda", -- Trophy Tussel - Majora's Mask


}

local STAGE_NAMES = {
	[0x02] = "Princess Peach's Castle",
	[0x03] = "Rainbow Cruise",
	[0x04] = "Kongo Jungle",
	[0x05] = "Jungle Japes",
	[0x06] = "Great Bay",
	[0x07] = "Hyrule Temple",
	[0x08] = "Brinstar",
	[0x09] = "Brinstar Depths",
	[0x0A] = "Yoshi's Story",
	[0x0B] = "Yoshi's Island",
	[0x0C] = "Fountain of Dreams",
	[0x0D] = "Green Greens",
	[0x0E] = "Corneria",
	[0x0F] = "Venom",
	[0x10] = "Pokémon Stadium",
	[0x11] = "Poké Floats",
	[0x12] = "Mute City",
	[0x13] = "Big Blue",
	[0x14] = "Onett",
	[0x15] = "Fourside",
	[0x16] = "Icicle Mountain",
	[0x18] = "Mushroom Kingdom",
	[0x19] = "Mushroom Kingdom 2",
	[0x1B] = "Flat Zone",
	[0x1C] = "Dream Land N64",
	[0x1D] = "Yoshi's Island N64",
	[0x1E] = "Kongo Jungle N64",
	[0x24] = "Battlefield",
	[0x25] = "Final Destination",
}

local BREAK_THE_TARGETS_STAGES = {
	[0x28] = "Mario Target Test",
	[0x29] = "Captain Falcon Target Test",
	[0x2A] = "Young Link Target Test",
	[0x2B] = "Donkey Kong Target Test",
	[0x2C] = "Dr. Mario Target Test",
	[0x2D] = "Falco Target Test",
	[0x2E] = "Fox Target Test",
	[0x2F] = "Ice Climbers Target Test",
	[0x30] = "Kirby Target Test",
	[0x31] = "Bowser Target Test",
	[0x32] = "Link Target Test",
	[0x33] = "Luigi Target Test",
	[0x34] = "Marth Target Test",
	[0x35] = "Mewtwo Target Test",
	[0x36] = "Ness Target Test",
	[0x37] = "Peach Target Test",
	[0x38] = "Pichu Target Test",
	[0x39] = "Pikachu Target Test",
	[0x3A] = "Jigglypuff Target Test",
	[0x3B] = "Samus Target Test",
	[0x3C] = "Sheik Target Test",
	[0x3D] = "Yoshi Target Test",
	[0x3E] = "Zelda Target Test",
	[0x3F] = "Mr. G&W Target Test",
	[0x40] = "Roy Target Test",
	[0x41] = "Ganondorf Target Test",

}

local SINGLEPLAYER_STAGES = {
	[0x1F] = "Mushroom Kingdom",
	[0x20] = "Underground Maze",
	[0x21] = "Escape Zebes",
	[0x22] = "F-Zero Grand Prix",
	[0x26] = "Trophy Collection",
	[0x27] = "Race to the Finish",
	[0x42] = "All-Star Rest Area",
	[0x43] = "Home-Run Contest",
	[0x44] = "Trophy Tussle - Goomba",
	[0x45] = "Trophy Tussle - Entei",
	[0x46] = "Trophy Tussle - Majora's Mask",
}

function melee.isBTTStage(id)
	return BREAK_THE_TARGETS_STAGES[id] ~= nil
end

function melee.isSinglePlayerStage(id)
	return SINGLEPLAYER_STAGES[id] ~= nil
end

function melee.getSinglePlayerStages()
	return SINGLEPLAYER_STAGES
end

function melee.getAllStages()
	return STAGE_NAMES
end

function melee.getStageName(id)
	return STAGE_NAMES[id] or SINGLEPLAYER_STAGES[id] or BREAK_THE_TARGETS_STAGES[id]
end

function melee.getAllStageSeries()
	return STAGE_SERIES
end

function melee.getStageSeries(id)
	return STAGE_SERIES[id]
end

return melee