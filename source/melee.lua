local memory = require("memory")
local color = require("util.color")
local bit = require("bit")

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
SCENE_TITLE_SCREEN = 0x00

SCENE_MAIN_MENU = 0x01
	-- MENU FLAGS
	MENU_MAIN = 0x00
		SELECT_MAIN_1P = 0x00
		SELECT_MAIN_VS = 0x01
		SELECT_MAIN_TROPHY = 0x02
		SELECT_MAIN_OPTIONS = 0x03
		SELECT_MAIN_DATA = 0x04

	MENU_1P = 0x01
		SELECT_1P_REGULAR = 0x00
		SELECT_1P_EVENT = 0x01
		SELECT_1P_ONLINE = 0x2
		SELECT_1P_STADIUM = 0x03
		SELECT_1P_TRAINING = 0x04

	MENU_VS = 0x02
		SELECT_VS_MELEE = 0x00
		SELECT_VS_TOURNAMENT = 0x01
		SELECT_VS_SPECIAL = 0x02
		SELECT_VS_CUSTOM = 0x03
		SELECT_VS_NAMEENTRY = 0x04

	MENU_TROPHIES = 0x03
		SELECT_TROPHIES_GALLERY = 0x00
		SELECT_TROPHIES_LOTTERY = 0x01
		SELECT_TROPHIES_COLLECTION = 0x02

	MENU_OPTIONS = 0x04
		SELECT_OPTIONS_RUMBLE = 0x00
		SELECT_OPTIONS_SOUND = 0x01
		SELECT_OPTIONS_DISPLAY = 0x02
		SELECT_OPTIONS_UNKNOWN = 0x03
		SELECT_OPTIONS_LANGUAGE = 0x04
		SELECT_OPTIONS_ERASE_DATA = 0x05

	MENU_ONLINE = 0x08
		SELECT_ONLINE_DIRECT = 0x02
		SELECT_ONLINE_TEAMS = 0x03
		SELECT_ONLINE_LOGOUT = 0x05

	MENU_STADIUM = 0x09
		SELECT_STADIUM_TARGET_TEST = 0x00
		SELECT_STADIUM_HOMERUN_CONTEST = 0x01
		SELECT_STADIUM_MULTIMAN_MELEE = 0x02

	MENU_RUMBLE = 0x13
	MENU_SOUND = 0x14
	MENU_DISPLAY = 0x15
	MENU_UNKNOWN1 = 0x16
	MENU_LANGUAGE = 0x17

SCENE_VS_MODE = 0x02
	-- MINOR FLAGS
	SCENE_VS_CSS = 0x0
	SCENE_VS_SSS = 0x1
	SCENE_VS_INGAME = 0x2
	SCENE_VS_POSTGAME = 0x4

SCENE_CLASSIC_MODE = 0x03
	SCENE_CLASSIC_LEVEL_1_VS  = 0x00
	SCENE_CLASSIC_LEVEL_1 = 0x01
	SCENE_CLASSIC_LEVEL_2_VS = 0x02
	SCENE_CLASSIC_LEVEL_2 = 0x03
	SCENE_CLASSIC_LEVEL_3_VS = 0x04
	SCENE_CLASSIC_LEVEL_3 = 0x05
	SCENE_CLASSIC_LEVEL_4_VS = 0x06
	SCENE_CLASSIC_LEVEL_4 = 0x07
	SCENE_CLASSIC_LEVEL_5_VS = 0x08
	SCENE_CLASSIC_LEVEL_5 = 0x09
	SCENE_CLASSIC_LEVEL_5_VS = 0x10
	SCENE_CLASSIC_LEVEL_5 = 0x09

	SCENE_CLASSIC_LEVEL_16 = 0x20
	SCENE_CLASSIC_LEVEL_16_VS = 0x21

	SCENE_CLASSIC_LEVEL_24 = 0x30
	SCENE_CLASSIC_LEVEL_24_VS = 0x31

	SCENE_CLASSIC_BREAK_THE_TARGETS_INTRO = 0x16
	SCENE_CLASSIC_BREAK_THE_TARGETS = 0x17

	SCENE_CLASSIC_TROPHY_STAGE_INTRO = 0x28
	SCENE_CLASSIC_TROPHY_STAGE_TARGETS = 0x29

	SCENE_CLASSIC_RACE_TO_FINISH_INTRO = 0x40
	SCENE_CLASSIC_RACE_TO_FINISH_TARGETS = 0x41

	SCENE_CLASSIC_LEVEL_56 = 0x38
	SCENE_CLASSIC_LEVEL_56_VS = 0x39

	SCENE_CLASSIC_MASTER_HAND = 0x51

	SCENE_CLASSIC_CONTINUE = 0x69
	SCENE_CLASSIC_CSS = 0x70

SCENE_ADVENTURE_MODE = 0x04

	SCENE_ADVENTURE_MUSHROOM_KINGDOM_INTRO = 0x00
	SCENE_ADVENTURE_MUSHROOM_KINGDOM = 0x01
	SCENE_ADVENTURE_MUSHROOM_KINGDOM_LUIGI = 0x02
	SCENE_ADVENTURE_MUSHROOM_KINGDOM_BATTLE = 0x03

	SCENE_ADVENTURE_MUSHROOM_KONGO_JUNGLE_INTRO = 0x08
	SCENE_ADVENTURE_MUSHROOM_KONGO_JUNGLE_TINY_BATTLE = 0x09
	SCENE_ADVENTURE_MUSHROOM_KONGO_JUNGLE_GIANT_BATTLE = 0x0A

	SCENE_ADVENTURE_UNDERGROUND_MAZE_INTRO = 0x10
	SCENE_ADVENTURE_UNDERGROUND_MAZE = 0x11
	SCENE_ADVENTURE_HYRULE_TEMPLE_BATTLE = 0x12

	SCENE_ADVENTURE_BRINSTAR_INTRO = 0x18
	SCENE_ADVENTURE_BRINSTAR = 0x19

	SCENE_ADVENTURE_ESCAPE_ZEBES_INTRO = 0x1A
	SCENE_ADVENTURE_ESCAPE_ZEBES = 0x1B
	SCENE_ADVENTURE_ESCAPE_ZEBES_ESCAPE = 0x1C

	SCENE_ADVENTURE_GREEN_GREENS_INTRO = 0x20
	SCENE_ADVENTURE_GREEN_GREENS_KIRBY_BATTLE = 0x21
	SCENE_ADVENTURE_GREEN_GREENS_KIRBY_TEAM_INTRO = 0x22
	SCENE_ADVENTURE_GREEN_GREENS_KIRBY_TEAM_BATTLE = 0x23
	SCENE_ADVENTURE_GREEN_GREENS_GIANT_KIRBY_INTRO = 0x24
	SCENE_ADVENTURE_GREEN_GREENS_GIANT_KIRBY_BATTLE = 0x25

	SCENE_ADVENTURE_CORNARIA_INTRO = 0x28
	SCENE_ADVENTURE_CORNARIA_BATTLE_1 = 0x29
	SCENE_ADVENTURE_CORNARIA_RAID = 0x2A
	SCENE_ADVENTURE_CORNARIA_BATTLE_2 = 0x2B
	SCENE_ADVENTURE_CORNARIA_BATTLE_3 = 0x2C

	SCENE_ADVENTURE_POKEMON_STADIUM_INTRO = 0x30
	SCENE_ADVENTURE_POKEMON_STADIUM_BATTLE = 0x31

	SCENE_ADVENTURE_FZERO_GRAND_PRIX_CARS = 0x38
	SCENE_ADVENTURE_FZERO_GRAND_PRIX_INTRO = 0x39
	SCENE_ADVENTURE_FZERO_GRAND_PRIX_RACE = 0x3A
	SCENE_ADVENTURE_FZERO_GRAND_PRIX_BATTLE = 0x3B

	SCENE_ADVENTURE_ONETT_INTRO = 0x40
	SCENE_ADVENTURE_ONETT_BATTLE = 0x41

	SCENE_ADVENTURE_ICICLE_MOUNTAIN_INTRO = 0x48
	SCENE_ADVENTURE_ICICLE_MOUNTAIN_CLIMB = 0x49

	SCENE_ADVENTURE_BATTLEFIELD_INTRO = 0x50
	SCENE_ADVENTURE_BATTLEFIELD_BATTLE = 0x51
	SCENE_ADVENTURE_BATTLEFIELD_METAL_INTRO = 0x52
	SCENE_ADVENTURE_BATTLEFIELD_METAL_BATTLE = 0x53

	SCENE_ADVENTURE_FINAL_DESTINATION_INTRO = 0x58
	SCENE_ADVENTURE_FINAL_DESTINATION_BATTLE = 0x59
	SCENE_ADVENTURE_FINAL_DESTINATION_POSE = 0x5A
	SCENE_ADVENTURE_FINAL_DESTINATION_WINNER = 0x5B

	SCENE_ADVENTURE_CSS = 0x70

SCENE_ALL_STAR_MODE = 0x05
	SCENE_ALL_STAR_LEVEL_1 = 0x00
	SCENE_ALL_STAR_REST_AREA_1 = 0x01
	SCENE_ALL_STAR_LEVEL_2 = 0x02
	SCENE_ALL_STAR_REST_AREA_2 = 0x03
	SCENE_ALL_STAR_LEVEL_3 = 0x04
	SCENE_ALL_STAR_REST_AREA_3 = 0x05
	SCENE_ALL_STAR_LEVEL_4 = 0x06
	SCENE_ALL_STAR_REST_AREA_4 = 0x07
	SCENE_ALL_STAR_LEVEL_5 = 0x08
	SCENE_ALL_STAR_REST_AREA_5 = 0x09
	SCENE_ALL_STAR_LEVEL_6 = 0x10
	SCENE_ALL_STAR_REST_AREA_6 = 0x11
	SCENE_ALL_STAR_LEVEL_7 = 0x12
	SCENE_ALL_STAR_REST_AREA_7 = 0x13
	SCENE_ALL_STAR_LEVEL_8 = 0x14
	SCENE_ALL_STAR_REST_AREA_8 = 0x15
	SCENE_ALL_STAR_LEVEL_9 = 0x16
	SCENE_ALL_STAR_REST_AREA_9 = 0x17
	SCENE_ALL_STAR_LEVEL_10 = 0x18
	SCENE_ALL_STAR_REST_AREA_10 = 0x19
	SCENE_ALL_STAR_LEVEL_11 = 0x20
	SCENE_ALL_STAR_REST_AREA_11 = 0x21
	SCENE_ALL_STAR_LEVEL_12 = 0x22
	SCENE_ALL_STAR_REST_AREA_12 = 0x23
	SCENE_ALL_STAR_LEVEL_13 = 0x24
	SCENE_ALL_STAR_REST_AREA_13 = 0x25
	SCENE_ALL_STAR_LEVEL_14 = 0x26
	SCENE_ALL_STAR_REST_AREA_14 = 0x27
	SCENE_ALL_STAR_LEVEL_15 = 0x28
	SCENE_ALL_STAR_REST_AREA_15 = 0x29
	SCENE_ALL_STAR_LEVEL_16 = 0x30
	SCENE_ALL_STAR_REST_AREA_16 = 0x31
	SCENE_ALL_STAR_LEVEL_17 = 0x32
	SCENE_ALL_STAR_REST_AREA_17 = 0x33
	SCENE_ALL_STAR_LEVEL_18 = 0x34
	SCENE_ALL_STAR_REST_AREA_18 = 0x35
	SCENE_ALL_STAR_LEVEL_19 = 0x36
	SCENE_ALL_STAR_REST_AREA_19 = 0x37
	SCENE_ALL_STAR_LEVEL_20 = 0x38
	SCENE_ALL_STAR_REST_AREA_20 = 0x39
	SCENE_ALL_STAR_LEVEL_21 = 0x40
	SCENE_ALL_STAR_REST_AREA_21 = 0x41
	SCENE_ALL_STAR_LEVEL_22 = 0x42
	SCENE_ALL_STAR_REST_AREA_22 = 0x43
	SCENE_ALL_STAR_LEVEL_23 = 0x44
	SCENE_ALL_STAR_REST_AREA_23 = 0x45
	SCENE_ALL_STAR_LEVEL_24 = 0x46
	SCENE_ALL_STAR_REST_AREA_24 = 0x47
	SCENE_ALL_STAR_LEVEL_25 = 0x48
	SCENE_ALL_STAR_REST_AREA_25 = 0x49
	SCENE_ALL_STAR_LEVEL_26 = 0x50
	SCENE_ALL_STAR_REST_AREA_26 = 0x51
	SCENE_ALL_STAR_LEVEL_27 = 0x52
	SCENE_ALL_STAR_REST_AREA_28 = 0x53
	SCENE_ALL_STAR_LEVEL_29 = 0x54
	SCENE_ALL_STAR_REST_AREA_29 = 0x55
	SCENE_ALL_STAR_LEVEL_30 = 0x56
	SCENE_ALL_STAR_REST_AREA_30 = 0x57
	SCENE_ALL_STAR_LEVEL_31 = 0x58
	SCENE_ALL_STAR_REST_AREA_31 = 0x59
	SCENE_ALL_STAR_LEVEL_32 = 0x60
	SCENE_ALL_STAR_REST_AREA_32 = 0x61
	SCENE_ALL_STAR_CSS = 0x70

SCENE_DEBUG = 0x06
SCENE_SOUND_TEST = 0x07

SCENE_VS_UNKNOWN = 0x08 -- SLIPPI ONLINE
	SCENE_VS_UNKNOWN_CSS = 0x00
	SCENE_VS_UNKNOWN_SSS = 0x01
	SCENE_VS_UNKNOWN_INGAME = 0x02
	SCENE_VS_UNKNOWN_VERSUS = 0x04

SCENE_UNKOWN_1 = 0x09
SCENE_CAMERA_MODE = 0x0A
SCENE_TROPHY_GALLERY = 0x0B
SCENE_TROPHY_LOTTERY = 0x0C
SCENE_TROPHY_COLLECTION = 0x0D

SCENE_START_MATCH = 0x0E -- Slippi Replays
	SCENE_START_MATCH_INGAME = 0x01 -- Set when the replay is actually playing out
	SCENE_START_MATCH_UNKNOWN = 0x03 -- Seems to be set right before the match loads

SCENE_TARGET_TEST = 0x0F
	SCENE_TARGET_TEST_CSS = 0x00
	SCENE_TARGET_TEST_INGAME = 0x1

SCENE_SUPER_SUDDEN_DEATH = 0x10
	SCENE_SSD_CSS = 0x00
	SCENE_SSD_SSS = 0x01
	SCENE_SSD_INGAME = 0x02
	SCENE_SSD_POSTGAME = 0x04

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

SCENE_CHARACTER_APPROACHING = 0x14

SCENE_CLASSIC_MODE_COMPLETE = 0x15
	SCENE_CLASSIC_MODE_TROPHY = 0x00
	SCENE_CLASSIC_MODE_CREDITS = 0x01
	SCENE_CLASSIC_MODE_CHARACTER_VIDEO = 0x02
	SCENE_CLASSIC_MODE_CONGRATS = 0x03

SCENE_ADVENTURE_MODE_COMPLETE = 0x16
	SCENE_ADVENTURE_MODE_TROPHY = 0x00
	SCENE_ADVENTURE_MODE_CREDITS = 0x01
	SCENE_ADVENTURE_MODE_CHARACTER_VIDEO = 0x02
	SCENE_ADVENTURE_MODE_CONGRATS = 0x03

SCENE_ALL_STAR_COMPLETE = 0x17
	SCENE_ALL_STAR_TROPHY = 0x00
	SCENE_ALL_STAR_CREDITS = 0x01
	SCENE_ALL_STAR_CHARACTER_VIDEO = 0x02
	SCENE_ALL_STAR_CONGRATS = 0x03

SCENE_TITLE_SCREEN_IDLE = 0x18
	SCENE_TITLE_SCREEN_IDLE_INTRO_VIDEO = 0x0
	SCENE_TITLE_SCREEN_IDLE_FIGHT_1 = 0x1
	SCENE_TITLE_SCREEN_IDLE_BETWEEN_FIGHTS = 0x2
	SCENE_TITLE_SCREEN_IDLE_FIGHT_2 = 0x3
	SCENE_TITLE_SCREEN_IDLE_HOW_TO_PLAY = 0x4

SCENE_ADVENTURE_MODE_CINEMEATIC = 0x19
SCENE_CHARACTER_UNLOCKED = 0x1A

SCENE_TOURNAMENT = 0x1B
	SCENE_TOURNAMENT_CSS = 0x0
	SCENE_TOURNAMENT_BRACKET = 0x1
	SCENE_TOURNAMENT_INGAME = 0x4
	SCENE_TOURNAMENT_POSTGAME = 0x6

SCENE_TRAINING_MODE = 0x1C
	SCENE_TRAINING_CSS = 0x0
	SCENE_TRAINING_SSS = 0x1
	SCENE_TRAINING_INGAME = 0x2

SCENE_TINY_MELEE = 0x1D
	SCENE_TINY_MELEE_CSS = 0x0
	SCENE_TINY_MELEE_SSS = 0x1
	SCENE_TINY_MELEE_INGAME = 0x2
	SCENE_TINY_MELEE_POSTGAME = 0x4

SCENE_GIANT_MELEE = 0x1E
	SCENE_GIANT_MELEE_CSS = 0x0
	SCENE_GIANT_MELEE_SSS = 0x1
	SCENE_GIANT_MELEE_INGAME = 0x2
	SCENE_GIANT_MELEE_POSTGAME = 0x4

SCENE_STAMINA_MODE = 0x1F
	SCENE_STAMINA_MODE_CSS = 0x0
	SCENE_STAMINA_MODE_SSS = 0x1
	SCENE_STAMINA_MODE_INGAME = 0x2
	SCENE_STAMINA_MODE_POSTGAME = 0x4

SCENE_HOME_RUN_CONTEST = 0x20
	SCENE_HOME_RUN_CONTEST_CSS = 0x0
	SCENE_HOME_RUN_CONTEST_INGAME = 0x1

SCENE_10_MAN_MELEE = 0x21
	SCENE_10_MAN_MELEE_CSS = 0x00
	SCENE_10_MAN_MELEE_INGAME = 0x01

SCENE_100_MAN_MELEE = 0x22
	SCENE_100_MAN_MELEE_CSS = 0x00
	SCENE_100_MAN_MELEE_INGAME = 0x01

SCENE_3_MINUTE_MELEE = 0x23
	SCENE_3_MINUTE_MELEE_CSS = 0x00
	SCENE_3_MINUTE_MELEE_INGAME = 0x01

SCENE_15_MINUTE_MELEE = 0x24
	SCENE_15_MINUTE_MELEE_CSS = 0x00
	SCENE_15_MINUTE_MELEE_INGAME = 0x01

SCENE_ENDLESS_MELEE = 0x25
	SCENE_ENDLESS_MELEE_CSS = 0x00
	SCENE_ENDLESS_MELEE_INGAME = 0x01

SCENE_CRUEL_MELEE = 0x26
	SCENE_CRUEL_MELEE_CSS = 0x00
	SCENE_CRUEL_MELEE_INGAME = 0x01
	
SCENE_PROGRESSIVE_SCAN = 0x27
SCENE_PLAY_INTRO_VIDEO = 0x28
SCENE_MEMORY_CARD_OVERWRITE = 0x29

SCENE_FIXED_CAMERA_MODE = 0x2A
	SCENE_FIXED_CAMERA_MODE_CSS = 0x0
	SCENE_FIXED_CAMERA_MODE_SSS = 0x1
	SCENE_FIXED_CAMERA_MODE_INGAME = 0x2
	SCENE_FIXED_CAMERA_MODE_POSTGAME = 0x4

SCENE_EVENT_MATCH = 0x2B
	SCENE_EVENT_MATCH_SELECT = 0x0
	SCENE_EVENT_MATCH_INGAME = 0x1

SCENE_SINGLE_BUTTON_MODE = 0x2C
	SCENE_SINGLE_BUTTON_MODE_CSS = 0x0
	SCENE_SINGLE_BUTTON_MODE_SSS = 0x1
	SCENE_SINGLE_BUTTON_MODE_INGAME = 0x2

local character_selections = {
	[0x00] = {
		name = "captain",
		skin = {"original", "black", "red", "white", "green", "blue", "teal"},
		team_skin = {3, 6, 5},
		series = "fzero"
	},
	[0x01] = {
		name = "donkey",
		skin = {"original", "black", "red", "blue", "green", "gold"},
		team_skin = {3, 4, 5},
		series = "donkey_kong"
	},
	[0x02] = {
		name = "fox",
		skin = {"original", "red", "blue", "green", "gold"},
		team_skin = {2, 3, 4},
		series = "star_fox"
	},
	[0x03] = {
		name = "gamewatch",
		skin = {"original", "red", "blue", "green", "white"},
		team_skin = {2, 3, 4},
		series = "game_and_watch"
	},
	[0x04] = {
		name = "kirby",
		skin = {"original", "yellow", "blue", "red", "green", "white", "purple"},
		team_skin = {4, 3, 5},
		series = "kirby"
	},
	[0x05] = {
		name = "koopa",
		skin = {"green", "red", "blue", "black", "orange"},
		team_skin = {2, 3, 1},
		series = "mario"
	},
	[0x06] = {
		name = "link",
		skin = {"green", "red", "blue", "black", "white", "gold"},
		team_skin = {2, 3, 1},
		series = "zelda"
	},
	[0x07] = {
		name = "luigi",
		skin = {"green", "white", "blue", "red", "purple"},
		team_skin = {4, 3, 1},
		series = "mario"
	},
	[0x08] = {
		name = "mario",
		skin = {"red", "yellow", "black", "blue", "green", "teal"},
		team_skin = {1, 4, 5},
		series = "mario"
	},
	[0x09] = {
		name = "marth",
		skin = {"original", "red", "green", "black", "white", "gold"},
		team_skin = {2, 1, 3},
		series = "fire_emblem"
	},
	[0x10] = {
		name = "samus",
		skin = {"red", "pink", "black", "green", "blue", "teal"},
		team_skin = {1, 5, 4},
		series = "metroid"
	},
	[0x11] = {
		name = "yoshi",
		skin = {"green", "red", "blue", "yellow", "pink", "light_blue", "black"},
		team_skin = {2, 3, 1},
		series = "yoshi"
	},
	[0x12] = {
		name = "zelda",
		skin = {"original", "red", "blue", "green", "white", "gold"},
		team_skin = {2, 3, 4},
		series = "zelda"
	},
	[0x13] = {
		name = "sheik",
		skin = {"original", "red", "blue", "green", "white", "gold"},
		team_skin = {2, 3, 4},
		series = "zelda"
	},
	[0x14] = {
		name = "falco",
		skin = {"original", "red", "blue", "green", "pink"},
		team_skin = {2, 3, 4},
		series = "star_fox"
	},
	[0x15] = {
		name = "younglink",
		skin = {"green", "red", "blue", "white", "black", "purple"},
		team_skin = {2, 3, 1},
		series = "zelda"
	},
	[0x16] = {
		name = "mariod",
		skin = {"white", "red", "blue", "green", "black", "purple"},
		team_skin = {2, 3, 4},
		series = "mario"
	},
	[0x17] = {
		name = "roy",
		skin = {"original", "red", "blue", "green", "yellow", "purple"},
		team_skin = {2, 3, 4},
		series = "fire_emblem"
	},
	[0x18] = {
		name = "pichu",
		skin = {"original", "red", "blue", "green", "hat"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x19] = {
		name = "ganon",
		skin = {"original", "red", "blue", "green", "purple", "gold"},
		team_skin = {2, 3, 4},
		series = "zelda"
	},
	[0x0A] = {
		name = "mewtwo",
		skin = {"original", "red", "blue", "green", "black"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x0B] = {
		name = "ness",
		skin = {"original", "yellow", "blue", "green", "pink"},
		team_skin = {1, 3, 4},
		series = "earthbound"
	},
	[0x0C] = {
		name = "peach",
		skin = {"original", "daisy", "white", "blue", "green", "red"},
		team_skin = {1, 4, 5},
		series = "mario"
	},
	[0x0D] = {
		name = "pikachu",
		skin = {"original", "red", "blue", "green", "detective"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x0E] = {
		name = "ice_climber",
		skin = {"original", "green", "orange", "red", "blue"},
		team_skin = {4, 1, 2},
		series = "ice_climbers"
	},
	[0x0F] = {
		name = "purin",
		skin = {"original", "red", "blue", "green", "crown", "pink"},
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

local beyondmelee_selection = {
	[0x00] = {
		name = "captain",
		skin = {"original", "black", "red", "white", "green", "blue", "maskless"},
		team_skin = {3, 6, 5},
		series = "fzero"
	},
	[0x05] = {
		name = "koopa",
		skin = {"green", "red", "blue", "black", "bones"},
		team_skin = {2, 3, 1},
		series = "mario"
	},
	[0x06] = {
		name = "link",
		skin = {"green", "red", "blue", "black", "white", "fierce"},
		team_skin = {2, 3, 1},
		series = "zelda"
	},
	[0x08] = {
		name = "mario",
		skin = {"red", "yellow", "black", "blue", "green", "builder"},
		team_skin = {1, 4, 5},
		series = "mario"
	},
	[0x0D] = {
		name = "pikachu",
		skin = {"original", "red", "blue", "green", "luchador"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x10] = {
		name = "samus",
		skin = {"red", "pink", "black", "green", "blue", "white"},
		team_skin = {1, 5, 4},
		series = "metroid"
	},
	[0x16] = {
		name = "mariod",
		skin = {"white", "red", "blue", "green", "black", "hazmat"},
		team_skin = {2, 3, 4},
		series = "mario"
	},
	[0x18] = {
		name = "pichu",
		skin = {"original", "red", "blue", "green", "hat"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x19] = {
		name = "ganon",
		skin = {"original", "red", "blue", "green", "purple", "spirit"},
		team_skin = {2, 3, 4},
		series = "zelda"
	},
	[0x1A] = {
		name = "wolf",
		skin = {"neutral", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "star_fox"
	},
	[0x1B] = {
		name = "raichu",
		skin = {"neutral", "king", "beach", "vomit", "warlock"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x1C] = {
		name = "shadowm2",
		skin = {"black", "red", "blue", "green", "purple"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x1D] = {
		name = "fay",
		skin = {"neutral", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "star_fox"
	},
	[0x1E] = {
		name = "skullkid",
		skin = {"neutral", "blue", "green", "black"},
		team_skin = {1, 2, 3},
		series = "zelda"
	},
}

local akaneia_selection = {
	[0x1A] = {
		name = "wolf",
		skin = {"neutral", "pink", "blue", "green", "brown"},
		team_skin = {2, 3, 4},
		series = "star_fox"
	},
}

local textures = {
	series = {},
	stocks = {},
	skinless = {}
}

local graphics = love.graphics
local newImage = graphics.newImage

local melee = {}

function melee.isAkaneia()
	return memory.romstring and memory.romstring.akaneia == "Akaneia"
end

function melee.isBeyondMelee()
	return memory.romstring and memory.romstring.beyondmelee == "Beyond Melee"
end

do
	local function doload(tbl)
		for cid, info in pairs(tbl) do
			if textures.series[cid] then textures.series[cid]:release() end
			textures.series[cid] = newImage(("textures/series/%s.png"):format(info.series))

			if textures.stocks[cid] then
				for skin, text in pairs(textures.stocks[cid]) do
					text:release()
				end
			end

			textures.stocks[cid] = {}
			textures.skinless[cid] = info.skinless

			if info.skin then
				for sid, skin in ipairs(info.skin) do
					local stockf = ("textures/stocks/%s-%s.png"):format(info.name, skin)
					local stockakf = ("textures/stocks/ak/%s-%s.png"):format(info.name, skin)
					local stockbmf = ("textures/stocks/bm/%s-%s.png"):format(info.name, skin)

					if melee.isAkaneia() and love.filesystem.getInfo(stockakf) then
						-- Akaneia icon override
						textures.stocks[cid][sid-1] = newImage(stockakf)
					elseif melee.isBeyondMelee() and love.filesystem.getInfo(stockbmf) then
						-- Beyond Melee icon override
						textures.stocks[cid][sid-1] = newImage(stockbmf)
					elseif love.filesystem.getInfo(stockf) then
						textures.stocks[cid][sid-1] = newImage(stockf)
					end
				end
			else
				if textures.stocks[cid][1] then textures.stocks[cid][1]:release() end
				textures.stocks[cid][1] = newImage(("textures/stocks/%s.png"):format(info.name))
			end
		end
	end

	function melee.loadTextures()
		doload(character_selections)
	end

	function melee.loadRomSpecificTextures()
		doload(character_selections)
		if melee.isAkaneia() then
			print("LOADED AKANEIA TEXTURES")
			doload(akaneia_selection)
		elseif melee.isBeyondMelee() then
			print("LOADED BEYOND MELEE TEXTURES")
			doload(beyondmelee_selection)
		end
	end
end

function melee.getPlayer(port)
	if not memory.player then return end

	if melee.isSinglePlayerGame() and not melee.isNetplayGame() and port == memory.menu.player_one_port + 1 then
		-- Single player games in CSS screen always use PORT 1 character info no matter what port is controlling the menus
		return memory.player[1].select
	elseif not melee.isInGame() then
		return memory.player[port].select
	end

	return memory.player[port]
end

function melee.getCharacterID(port)
	if not memory.player then return end

	local player = melee.getPlayer(port)

	if not player then return end

	local character = player.character

	if melee.isInGame() then
		local transformed = player.transformed == 256

		-- Handle and detect Zelda/Sheik transformations
		if character == 0x13 then
			character = transformed and 0x12 or 0x13
		elseif character == 0x12 then
			character = transformed and 0x13 or 0x12
		end
	end

	return character
end

function melee.getStockTexture(id, skin)
	if textures.skinless[id] == true then
		skin = 1
	end
	if not textures.stocks[id] or not textures.stocks[id][skin] then
		return textures.stocks[id] and textures.stocks[id][0] or textures.stocks[0x21][1]
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
	local series = melee.getSeriesTexture(melee.isPortEnabled(port) and id or 0x21)
	if not series then return end
	graphics.easyDraw(series, ...)
end

function melee.getSinglePlayerPort()
	if melee.isSinglePlayerGame() and not melee.isNetplayGame() then
		return 1
	else
		return memory.menu.player_one_port+1
	end
end

function melee.drawStock(port, ...)
	if not melee.isPortEnabled(port) then return end
	local id = melee.getCharacterID(port)
	if id == 0x21 or not memory.player then return end
	local player = melee.getPlayer(port)
	if not player or not id then return end
	local stock = melee.getStockTexture(id, player.skin)
	if not stock then return end
	graphics.easyDraw(stock, ...)
end

local TEAM_COLORS = {
	[0x00] = color(245, 46, 46, 255),	-- Red
	[0x01] = color(84, 99, 255, 255),	-- Blue
	[0x02] = color(31, 158, 64, 255),	-- Green
	[0x04] = color(200, 200, 200, 255),	-- CPU/Disabled
}

function melee.getPlayerTeamColor(port)
	if not melee.isPortEnabled(port) then return TEAM_COLORS[0x04] end
	local player = melee.isInGame() and melee.getPlayer(port) or memory.player[port].card
	if not player then return TEAM_COLORS[0x04] end
	return TEAM_COLORS[player.team] or color_white
end

local PLAYER_COLORS = {
	[1] = color(245, 46, 46, 255),
	[2] = color(84, 99, 255, 255),
	[3] = color(255, 199, 23, 255),
	[4] = color(31, 158, 64, 255),
}

local PORT_PLAYER = 0x0
local PORT_CPU = 0x1
local PORT_DISABLED = 0x3

function melee.isPortEnabled(port)
	if not port then return false end
	if melee.isInMenus() and melee.isSinglePlayerGame() and port ~= (memory.menu.player_one_port+1) then return false end
	return memory.player[port].card.mode ~= PORT_DISABLED
end

function melee.isPortCPU(port)
	return memory.player[port].card.mode == PORT_CPU
end

function melee.getPlayerColor(port)
	return melee.isPortEnabled(port) and (PLAYER_COLORS[port] or color_white) or TEAM_COLORS[0x04]
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

	-- Akaneia
	[0x4E] = "Wolf Target Test",
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

local AKANEIA_STAGES = {
	[0x47] = "Peach's Castle 64",
	[0x48] = "Hyrule Castle 64",
	[0x49] = "Saffron City 64",
	[0x4A] = "Planet Zebes 64",
	[0x4B] = "Mushroom Kingdom 64",
	[0x4C] = "Metal Cavern",
	[0x4D] = "Volleyball",
}

local AKANEIA_SERIES = {
	[0x47] = "Super Mario",
	[0x48] = "The Legend of Zelda",
	[0x49] = "Pokémon",
	[0x4A] = "Metroid",
	[0x4B] = "Super Mario",
	[0x4C] = "Super Mario",
	[0x4D] = "Super Smash Bros",
}

local BEYOND_MELEE_STAGES = {
	[0x47] = "Volleyball",
	[0x48] = "Smashville",
	[0x49] = "Sprout Tower",
	[0x4A] = "Fountain of Dreams",
	[0x4B] = "Flipper Field",
	[0x4C] = "Brinstar Lab",
	[0x4D] = "Metal Cavern", -- Metal Cavern? (Currently broken in BM-1.0)
	[0x4E] = "Mute Circuit",
	[0x4F] = "Kongo Falls",
	[0x50] = "Town Greens",
	[0x51] = "Kongle Jungle 64",
	[0x52] = "Poké Float Stadium 2",
	[0x53] = "Rainbow Ride",
	[0x54] = "Island Zone",
	[0x55] = "Wasteland",
	[0x56] = "Baby Bowser's Castle",
	[0x57] = "Midnight Destination",
	[0x58] = "Midnight Battlefield",
	[0x59] = "Dual Zone",
	[0x5A] = "Fountain of Dreams", -- Diet (Currently broken in BM-1.0)
	[0x5B] = "Stadium-ville", -- Diet (Currently broken in BM-1.0)
	[0x5C] = "Yoshi's Story", -- Diet
	[0x5D] = "Treasure Hunt",
	[0x5E] = "Realgam Colosseum",
	[0x5F] = "Vapor Story",
	[0x60] = "Final Destination", -- Diet
	[0x61] = "Battlefield", -- Diet
	[0x62] = "Pokémon Stadium", -- Diet
	[0x63] = "Galacta Battleground",
}

local BEYOND_MELEE_SERIES = {
	[0x47] = "Super Smash Bros", -- Volleyball
	[0x48] = "Animal Crossing", -- Smashville
	[0x49] = "Pokémon", -- Sprout Tower
	[0x4A] = "Kirby", -- Fountain of Dreams
	[0x4B] = "Super Smash Bros", -- Flipper Field
	[0x4C] = "Metroid", -- Brinstar Lab
	[0x4D] = "Super Mario", -- Metal Cavern? (Currently broken in BM-1.0)
	[0x4E] = "F-Zero", -- Mute Circuit
	[0x4F] = "Donkey Kong", -- Kongo Falls
	[0x50] = "Kirby", -- Town Greens
	[0x51] = "Donkey Kong", -- Kongle Jungle 64
	[0x52] = "Pokémon", -- Poké Float Stadium 2
	[0x53] = "Super Mario", -- Rainbow Ride
	[0x54] = "Yoshi", -- Island Zone
	[0x55] = "Kirby", -- Wasteland
	[0x56] = "Yoshi", -- Baby Bowser's Castle
	[0x57] = "Super Smash Bros", -- Midnight Destination
	[0x58] = "Super Smash Bros", -- Midnight Battlefield
	[0x59] = "Super Smash Bros", -- Dual Zone
	[0x5A] = "Kirby", -- Fountain of Dreams (Diet) (Currently broken in BM-1.0)
	[0x5B] = "Pokémon", -- Stadium-ville (Diet) (Currently broken in BM-1.0)
	[0x5C] = "Yoshi", -- Yoshi's Story (Diet)
	[0x5D] = "Yoshi", -- Treasure Hunt
	[0x5E] = "Pokémon", -- Realgam Colosseum
	[0x5F] = "Yoshi", -- Vapor Story
	[0x60] = "Super Smash Bros", -- Final Destination (Diet)
	[0x61] = "Super Smash Bros", -- Battlefield (Diet)
	[0x62] = "Pokémon", -- Pokémon Stadium (Diet)
	[0x63] = "Kirby", -- Galacta Battleground
}

function melee.isNetplayGame()
	return memory.scene.major == SCENE_VS_UNKNOWN and (memory.scene.minor == SCENE_VS_UNKNOWN_INGAME or memory.scene.minor == SCENE_VS_UNKNOWN_VERSUS)
end

function melee.isTeams()
	if melee.isSinglePlayerGame() and not melee.isNetplayGame() then
		return false
	elseif melee.isInGame() then
		return memory.match.teams
	else
		return memory.menu.teams
	end
end

function melee.isSinglePlayerGame()
	local major = memory.scene.major
	return	major == SCENE_ALL_STAR_MODE or major == SCENE_TRAINING_MODE or
			major == SCENE_EVENT_MATCH or major == SCENE_CLASSIC_MODE or
			major == SCENE_ADVENTURE_MODE or major == SCENE_TARGET_TEST or
			(major >= SCENE_HOME_RUN_CONTEST and major <= SCENE_CRUEL_MELEE) or
			major == SCENE_VS_UNKNOWN
end

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

function melee.getAkaneiaStages()
	return AKANEIA_STAGES
end

function melee.getAkaneiaSeries()
	return AKANEIA_SERIES
end

function melee.isAkaneiaStage(id)
	if melee.isAkaneia() then
		return AKANEIA_STAGES[id] ~= nil
	end
	return false
end

function melee.getBeyondMeleeStages()
	return BEYOND_MELEE_STAGES
end

function melee.getBeyondMeleeSeries()
	return BEYOND_MELEE_SERIES
end

function melee.isBeyondMeleeStage(id)
	if melee.isBeyondMelee() then
		return BEYOND_MELEE_STAGES[id] ~= nil
	end
	return false
end

function melee.getStageName(id)
	if melee.isAkaneia() and AKANEIA_STAGES[id] then
		return AKANEIA_STAGES[id]
	elseif melee.isBeyondMelee() and BEYOND_MELEE_STAGES[id] then
		return BEYOND_MELEE_STAGES[id]
	end
	return STAGE_NAMES[id] or SINGLEPLAYER_STAGES[id] or BREAK_THE_TARGETS_STAGES[id]
end

function melee.getAllStageSeries()
	return STAGE_SERIES
end

function melee.getStageSeries(id)
	if melee.isAkaneia() and AKANEIA_SERIES[id] then
		return AKANEIA_SERIES[id]
	elseif melee.isBeyondMelee() and BEYOND_MELEE_SERIES[id] then
		return BEYOND_MELEE_SERIES[id]
	end
	return STAGE_SERIES[id]
end

function melee.matchFinsihed()
	return memory.match.finished == true
end

function melee.isInGame()
	if not memory.menu then return false end

	if memory.scene.major == SCENE_ALL_STAR_MODE and memory.scene.minor < SCENE_ALL_STAR_CSS then
		-- Even = playing the match
		-- Odd  = in the rest area
		--return memory.scene.minor % 2 == 0
		return true
	end
	if PANEL_SETTINGS:IsSlippiReplay() and memory.scene.major == SCENE_START_MATCH then
		return memory.scene.minor == SCENE_START_MATCH_INGAME
	end
	if memory.scene.major == SCENE_VS_MODE or memory.scene.major == SCENE_VS_UNKNOWN then
		return memory.scene.minor == SCENE_VS_INGAME
	end
	if memory.scene.major >= SCENE_TRAINING_MODE and memory.scene.major <= SCENE_STAMINA_MODE or memory.scene.major == SCENE_FIXED_CAMERA_MODE then
		return memory.scene.minor == SCENE_TRAINING_INGAME
	end
	if memory.scene.major == SCENE_EVENT_MATCH then
		return memory.scene.minor == SCENE_EVENT_MATCH_INGAME
	end
	if memory.scene.major == SCENE_CLASSIC_MODE and memory.scene.minor < SCENE_CLASSIC_CONTINUE then
		-- Even = Verus screen
		-- Odd  = playing the match
		return memory.scene.minor % 2 == 1
	end
	if memory.scene.major == SCENE_ADVENTURE_MODE then
		return
		memory.scene.minor == SCENE_ADVENTURE_MUSHROOM_KINGDOM or
		memory.scene.minor == SCENE_ADVENTURE_MUSHROOM_KINGDOM_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_MUSHROOM_KONGO_JUNGLE_TINY_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_MUSHROOM_KONGO_JUNGLE_GIANT_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_UNDERGROUND_MAZE or
		memory.scene.minor == SCENE_ADVENTURE_HYRULE_TEMPLE_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_BRINSTAR or
		memory.scene.minor == SCENE_ADVENTURE_ESCAPE_ZEBES or
		memory.scene.minor == SCENE_ADVENTURE_GREEN_GREENS_KIRBY_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_GREEN_GREENS_KIRBY_TEAM_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_GREEN_GREENS_GIANT_KIRBY_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_CORNARIA_BATTLE_1 or
		memory.scene.minor == SCENE_ADVENTURE_CORNARIA_BATTLE_2 or
		memory.scene.minor == SCENE_ADVENTURE_CORNARIA_BATTLE_3 or
		memory.scene.minor == SCENE_ADVENTURE_POKEMON_STADIUM_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_FZERO_GRAND_PRIX_RACE or
		memory.scene.minor == SCENE_ADVENTURE_FZERO_GRAND_PRIX_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_ONETT_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_ICICLE_MOUNTAIN_CLIMB or
		memory.scene.minor == SCENE_ADVENTURE_BATTLEFIELD_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_BATTLEFIELD_METAL_BATTLE or
		memory.scene.minor == SCENE_ADVENTURE_FINAL_DESTINATION_BATTLE
	end
	if memory.scene.major == SCENE_TARGET_TEST then
		return memory.scene.minor == SCENE_TARGET_TEST_INGAME
	end
	if memory.scene.major >= SCENE_SUPER_SUDDEN_DEATH and memory.scene.major <= MENU_LIGHTNING_MELEE then
		return memory.scene.minor == SCENE_SSD_INGAME
	end
	if memory.scene.major >= SCENE_HOME_RUN_CONTEST and memory.scene.major <= SCENE_CRUEL_MELEE then
		return memory.scene.minor == SCENE_HOME_RUN_CONTEST_INGAME
	end
	if memory.scene.major == SCENE_TITLE_SCREEN_IDLE then
		return memory.scene.minor == SCENE_TITLE_SCREEN_IDLE_FIGHT_1 or memory.scene.minor == SCENE_TITLE_SCREEN_IDLE_FIGHT_2
	end
	return false
end

function melee.isInMenus()
	if not memory.menu then return false end
	
	if memory.scene.major == SCENE_MAIN_MENU then
		return true
	end
	if memory.scene.major == SCENE_VS_MODE or memory.scene.major == SCENE_VS_UNKNOWN then
		return memory.scene.minor == SCENE_VS_CSS or memory.scene.minor == SCENE_VS_SSS
	end
	if memory.scene.major >= SCENE_TRAINING_MODE and memory.scene.major <= SCENE_STAMINA_MODE or memory.scene.major == SCENE_FIXED_CAMERA_MODE then
		return memory.scene.minor == SCENE_TRAINING_CSS or memory.scene.minor == SCENE_TRAINING_SSS
	end
	if memory.scene.major == SCENE_EVENT_MATCH then
		return memory.scene.minor == SCENE_EVENT_MATCH_SELECT
	end
	if memory.scene.major == SCENE_CLASSIC_MODE or memory.scene.major == SCENE_ADVENTURE_MODE or memory.scene.major == SCENE_ALL_STAR_MODE then
		-- All the menu_mior values all match in these three modes, so just use the SCENE_CLASSIC_CSS value for simplicity
		return memory.scene.minor == SCENE_CLASSIC_CSS
	end
	if memory.scene.major == SCENE_TARGET_TEST then
		return memory.scene.minor == SCENE_TARGET_TEST_CSS
	end
	if memory.scene.major >= SCENE_SUPER_SUDDEN_DEATH and memory.scene.major <= MENU_LIGHTNING_MELEE then
		return memory.scene.minor == SCENE_SSD_CSS or memory.scene.minor == SCENE_SSD_SSS
	end
	if memory.scene.major >= SCENE_HOME_RUN_CONTEST and memory.scene.major <= SCENE_CRUEL_MELEE then
		return memory.scene.minor == SCENE_HOME_RUN_CONTEST_CSS
	end
	return false
end

function melee.isCountdownTimer()
	return melee.isInGame() and bit.band(memory.match.flags.timer, 0x3) == 0x2
end

return melee