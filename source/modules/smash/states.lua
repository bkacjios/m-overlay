require("smash.enums")

local state = {}

local reactions = {
	-- Actions that SHOULD NOT count towards APM
	[0x000] = "dead (down)",				-- DeadDown
	[0x001] = "dead (left)",				-- DeadLeft
	[0x002] = "dead (right)",				-- DeadRight
	[0x003] = "dead (up)",					-- DeadUp
	[0x004] = "dead (star)",				-- DeadUpStar
	[0x005] = "dead (star)",				-- DeadUpStarIce
	[0x006] = "dead (up, fall)",			-- DeadUpFall
	[0x007] = "dead (up, fall, hit camera)",-- DeadUpFallHitCamera
	[0x008] = "dead (up, fall, hit camera)",-- DeadUpFallHitCameraFlat
	[0x009] = "dead (up, fall)",			-- DeadUpFallIce
	[0x00A] = "dead (up, fall, hit camera)",-- DeadUpFallHitCameraIce
	[0x00B] = "dead (sleep)",				-- Sleep
	[0x00C] = "spawning",					-- Rebirth
	[0x00D] = "spawn platform",				-- RebirthWait
	[0x00E] = "wait",						-- Wait

	-- We bend our knees first before these happen, so, ignore these
	[0x019] = "jump forward",				-- JumpF
	[0x01A] = "jump backward",				-- JumpB

	[0x01D] = "fall",						-- Fall
	[0x01E] = "fall forward",				-- FallF
	[0x01F] = "fall backward",				-- FallB
	[0x020] = "fall areial",				-- FallAerial
	[0x021] = "fall areial forward",		-- FallAerialF
	[0x022] = "fall areial backward",		-- FallAerialB
	[0x023] = "fall special",				-- FallSpecial
	[0x024] = "fall special forward",		-- FallSpecialF
	[0x025] = "fall special backward",		-- FallSpecialB
	[0x026] = "fall damage",				-- DamageFall

	[0x02A] = "landing",					-- Landing

	[0x046] = "landing neutral air",		-- LandingAirN
	[0x047] = "landing forward air",		-- LandingAirF
	[0x048] = "landing back air",			-- LandingAirB
	[0x049] = "landing air high",			-- LandingAirHi
	[0x04A] = "landing air low",			-- LandingAirLw
	[0x04B] = "damage high 1",				-- DamageHi1
	[0x04C] = "damage high 2",				-- DamageHi2
	[0x04D] = "damage high 3",				-- DamageHi3
	[0x04E] = "damage neutral 3",			-- DamageN1
	[0x04F] = "damage neutral 3",			-- DamageN2
	[0x050] = "damage neutral 3",			-- DamageN3
	[0x051] = "damage low 1",				-- DamageLw1
	[0x052] = "damage low 2",				-- DamageLw2
	[0x053] = "damage low 3",				-- DamageLw3
	[0x054] = "damage air 1",				-- DamageAir1
	[0x055] = "damage air 2",				-- DamageAir2
	[0x056] = "damage air 3",				-- DamageAir3
	[0x057] = "damage fly high",			-- DamageFlyHi
	[0x058] = "damage fly neutral",			-- DamageFlyN
	[0x059] = "damage fly low",				-- DamageFlyLw
	[0x05A] = "damage fly top",				-- DamageFlyTop
	[0x05B] = "damage fly roll",			-- DamageFlyRoll

	-- Knocked down animations
	[0x0B7] = "down",						-- DownBoundU
	[0x0B8] = "down",						-- DownWaitU
	[0x0B9] = "down damaged",				-- DownDamageU
	[0x0BF] = "down",						-- DownBoundD
	[0x0C0] = "down idle",					-- DownWaitD
	[0x0C1] = "down damaged",				-- DownDamageD
	[0x0C2] = "down and standing",			-- DownStandD

	-- ???
	[0x0C7] = "Passive",					-- Passive
	[0x0C8] = "PassiveStandF",				-- PassiveStandF
	[0x0C9] = "PassiveStandB",				-- PassiveStandB
	[0x0CA] = "PassiveWall",				-- PassiveWall
	[0x0CB] = "PassiveWallJump",			-- PassiveWallJump
	[0x0CC] = "PassiveCeil",				-- PassiveCeil

	-- Shield breaking
	[0x0CD] = "shield break pop",			-- ShieldBreakFly
	[0x0CE] = "shield break falling",		-- ShieldBreakFall
	[0x0CF] = "shield break fall down",		-- ShieldBreakDownU
	[0x0D0] = "shield break fall down",		-- ShieldBreakDownD
	[0x0D1] = "shield break stand",			-- ShieldBreakStandU
	[0x0D2] = "shield break stand",			-- ShieldBreakStandD
	[0x0D3] = "stunned",					-- FuraFura

	-- When the player is holding another character
	[0x0D8] = "hold",						-- CatchWait

	-- When moves "clink"
	[0x0ED] = "clink",						-- ReboundStop
	[0x0EE] = "clink recoil",				-- Rebound

	-- Character being thrown
	[0x0EF] = "forward thrown",				-- ThrownF
	[0x0F0] = "back thrown",				-- ThrownB
	[0x0F1] = "up thrown",					-- ThrownHi
	[0x0F2] = "down thrown", 				-- ThrownLw
	[0x0F3] = "down thrown",				-- ThrownLwWomen

	[0x0DF] = "pull into grab from air",	-- CapturePulledHi
	[0x0E0] = "hold air",					-- CaptureWaitHi
	[0x0E1] = "hold air damage",			-- CaptureDamageHi
	[0x0E2] = "pulled into grab",			-- CapturePulledLw
	[0x0E3] = "hold ground",				-- CaptureWaitLw
	[0x0E4] = "hold damage",				-- CaptureDamageLw

	[0x0E5] = "release from grab",			-- CaptureCut
	[0x0E6] = "jump from grab",				-- CaptureJump
	[0x0E7] = "grab neck",					-- CaptureNeck
	[0x0E8] = "grab foot",					-- CaptureFoot

	-- DK Grab stuff
	[0x10A] = "shouldered",					-- ShoulderedWait
	[0x10B] = "shouldered walk",			-- ShoulderedWalkSlow
	[0x10C] = "shouldered run",				-- ShoulderedWalkMiddle
	[0x10D] = "shouldered dash",			-- ShoulderedWalkFast
	[0x10E] = "Shouldered turn",			-- ShoulderedTurn

	-- Being thrown
	[0x10F] = "forward thrown",				-- ThrownFF
	[0x110] = "backward thrown",			-- ThrownFB
	[0x111] = "up thrown",					-- ThrownFHi
	[0x112] = "down thrown",				-- ThrownFLw

	[0x113] = "grabbed by cpt. falcon",		-- CaptureCaptain

	[0x114] = "grabbed by yoshi",			-- CaptureYoshi
	[0x115] = "yoshi egg",					-- YoshiEgg

	[0x116] = "grabbed by bowser",			-- CaptureKoopa
	[0x117] = "hit by bowser while grabbed",-- CaptureDamageKoopa
	[0x118] = "held by bowser",				-- CaptureWaitKoopa
	[0x119] = "forward thrown by bowser",	-- ThrownKoopaF
	[0x11A] = "backwards thrown by bowser",	-- ThrownKoopaB
	[0x11B] = "areial grabbed by bowser",	-- CaptureKoopaAir
	[0x11C] = "areial hit by bowser while grabbed", -- CaptureDamageKoopaAir
	[0x11D] = "areial held by bowser",		-- CaptureWaitKoopaAir
	[0x11E] = "areial thrown forward by bowser",	-- ThrownKoopaAirF
	[0x11F] = "areial thrown backwards by bowser",	-- ThrownKoopaAirB

	[0x120] = "inhaled by kirby",			-- CaptureKirby
	[0x121] = "held by kirby",				-- CaptureWaitKirby
	[0x122] = "spat out as star", 			-- ThrownKirbyStar
	[0x123] = "kirby stole ability",		-- ThrownCopyStar
	[0x124] = "spat out",					-- ThrownKirby

	[0x125] = "barrel idle",				-- BarrelWait

	[0x126] = "burried",					-- Bury
	[0x127] = "burried idle",				-- BuryWait
	[0x128] = "burried jump",				-- BuryJump

	[0x129] = "fall asleep",				-- DamageSong
	[0x12A] = "sleeping",					-- DamageSongWait
	[0x12B] = "wake up",					-- DamageSongRv

	[0x12C] = "damaged by bind",			-- DamageBind

	[0x12D] = "grabbed by mewtwo",			-- CaptureMewtwo
	[0x12E] = "areial grabbed by mewtwo",	-- CaptureMewtwoAir
	[0x12F] = "thrown by mewtwo",			-- ThrownMewtwo
	[0x130] = "areial thrown by mewtwo",	-- ThrownMewtwoAir

	[0x131] = "warp star jump",					-- WarpStarJump
	[0x132] = "warp star fall",					-- WarpStarFall

	[0x133] = "hammer idle",					-- HammerWait
	[0x137] = "hammer fall",					-- HammerFall
	[0x139] = "hammer landing",					-- HammerLanding

	[0x13A] = "giant mushroom start",			-- KinokoGiantStart
	[0x13B] = "areial giant mushroom start",	-- KinokoGiantStartAir
	[0x13C] = "giant mushroom end",				-- KinokoGiantEnd
	[0x13D] = "areial giant mushroom end",		-- KinokoGiantEndAir
	[0x13E] = "mini mushroom start",			-- KinokoSmallStart
	[0x13F] = "areial mini mushroom start",		-- KinokoSmallStartAir
	[0x140] = "mini mushroom end",				-- KinokoSmallEnd
	[0x141] = "areial mini mushroom end",		-- KinokoSmallEndAir

	[0x142] = "spawn start",					-- Entry
	[0x143]	= "Spawn drop in",					-- EntryStart
	[0x144] = "spawn end",						-- EntryEnd

	[0x145] = "damaged by ice",					-- DamageIce
	[0x146] = "damaged and launced by ice",		-- DamageIceJump

	[0x147] = "grabbed by master hand",		-- CaptureMasterhand
	[0x148] = "squeezed by master hand",	-- CapturedamageMasterhand
	[0x149] = "held by master hand",		-- CapturewaitMasterhand
	[0x14A] = "thrown by master hand",		-- ThrownMasterhand

	[0x14B] = "grabbed by kirby",			-- CaptureKirbyYoshi
	[0x14C] = "KirbyYoshiEgg",				-- KirbyYoshiEgg
	[0x14D] = "grabbed by redead",			-- CaptureLeadead
	[0x14E] = "grabbed by likelike",		-- CaptureLikelike

	[0x14F] = "DownReflect",				-- DownReflect

	[0x150] = "grabbed by crazy hand",		-- CaptureCrazyhand
	[0x151] = "squeezed by crazy hand",		-- CapturedamageCrazyhand
	[0x152] = "held by crazy hand",			-- CapturewaitCrazyhand
	[0x153] = "thrown by crazy hand",		-- ThrownCrazyhand

	[0x154] = "barrel cannon wait",			-- BarrelCannonWait

	[0x155] = "wait 1",		-- Wait1
	[0x156] = "wait 2",		-- Wait2
	[0x157] = "wait 3",		-- Wait3
	[0x158] = "wait 4",		-- Wait4
	[0x159] = "wait item",	-- WaitItem

	[0x15A] = "crouch wait 1",			-- SquatWait1
	[0x15B] = "crouch wait 2",			-- SquatWait2
	[0x15C] = "crouch wait with item",	-- SquatWaitItem

	[0x15D] = "shield damaged",			-- GuardDamage

	[0x15E] = "EscapeN",				-- EscapeN

	[0x15F] = "AttackS4Hold",			-- AttackS4Hold

	[0x160] = "heavy walk",				-- HeavyWalk1
	[0x161] = "heavy walk",				-- HeavyWalk2

	[0x162] = "ItemHammerWait",			-- ItemHammerWait

	[0x164] = "invisible",				-- ItemBlind

	[0x165] = "damaged by electricity",	-- DamageElec

	[0x166] = "stunned start",			-- FuraSleepStart
	[0x167] = "stunned",				-- FuraSleepLoop
	[0x168] = "stunned end",			-- FuraSleepEnd

	[0x169] = "wall damage",			-- WallDamage

	[0x16A] = "ledge hold",				-- CliffWait1
	[0x16B] = "ledge hold",				-- CliffWait2

	[0x16C] = "slip fall down",			-- SlipDown
	[0x16D] = "slip",					-- Slip
	[0x170] = "slip idle",				-- SlipWait
	[0x171] = "slip stand up",			-- SlipStand

	[0x176] = "struggle", -- Zitabata

	[0x177] = "hit by bowser while grabbed",	-- CaptureKoopaHit
	[0x178] = "thrown forward by bowser",		-- ThrownKoopaEndF
	[0x179] = "thrown backward by bowser",		-- ThrownKoopaEndB
	[0x17A] = "hit by bowser while grabbed",	-- CaptureKoopaAirHit
	[0x17B] = "thrown forward by bowser",		-- ThrownKoopaAirEndF
	[0x17C] = "thrown backward by bowser",		-- ThrownKoopaAirEndB

	[0x17D] = "ThrownKirbyDrinkSShot",			-- ThrownKirbyDrinkSShot
	[0x17E] = "ThrownKirbySpitSShot",			-- ThrownKirbySpitSShot
}

local character_states = {
	[CHARACTER_INTERNAL.CPTFALCON] = {
		[0x155] = "falcon unknown 1",
		[0x156] = "falcon unknown 2",
		[0x157] = "falcon unknown 3",
		[0x158] = "falcon unknown 4",
		[0x159] = "falcon unknown 5",
		[0x15A] = "falcon unknown 6",
		[0x15B] = "falcon unknown 7",

		[0x15B] = "falcon punch",
		[0x15C] = "aerial falcon punch",
		[0x15D] = "raptor boost",
		[0x15E] = "raptor boost uppercut", -- (collision)
		[0x15F] = "aerial raptor boost",
		[0x160] = "aerial raptor boost dunked", -- (collision)
		[0x161] = "falcon dive",
		[0x162] = "aerial falcon dive",
		[0x165] = "falcon kick",
		[0x166] = "falcon kick end", -- (finish)
		[0x167] = "aerial falcon kick",
		[0x168] = "aerial falcon kick end", -- (finish)
	},
	[CHARACTER_INTERNAL.GANONDORF] = {
		[0x155] = "ganon unknown 1",
		[0x156] = "ganon unknown 2",
		[0x157] = "ganon unknown 3",
		[0x158] = "ganon unknown 4",
		[0x159] = "ganon unknown 5",
		[0x15A] = "ganon unknown 6",
		[0x15B] = "ganon unknown 7",

		[0x15B] = "warlock punch",
		[0x15C] = "aerial warlock punch",
		[0x15D] = "gerudo dragon",
		[0x15E] = "gerudo dragon uppercut", -- (collision)
		[0x15F] = "aerial gerudo dragon",
		[0x160] = "aerial gerudo dragon dunk", -- (collision)
		[0x161] = "dark dive",
		[0x162] = "aerial dark dive",
		[0x165] = "wizards foot",
		[0x166] = "wizards foot end", -- (finish)
		[0x167] = "aerial wizards foot",
		[0x168] = "aerial wizards foot end", -- (finish)
	},
	[CHARACTER_INTERNAL.MARIO] = {
		[0x155] = "mario unknown 1",
		[0x156] = "mario unknown 2",

		[0x157] = "fireball",
		[0x158] = "aerial fireball",
		[0x159] = "cape",
		[0x15A] = "aerial cape",
		[0x15B] = "coin uppercut",
		[0x15C] = "aerial coin uppercut",
		[0x15D] = "spin punch",
		[0x15E] = "aerial spin punch",
	},
	[CHARACTER_INTERNAL.BOWSER] = {
		[0x155] = "fire breath start", -- (start)
		[0x156] = "fire breath",
		[0x157] = "fire breath finish", -- (finish)

		[0x158] = "aerial fire breath start", -- (start)
		[0x159] = "aerial fire breath",
		[0x15A] = "aerial fire breath finish", -- (finish)

		[0x15B] = "koopa klaw swipe",
		[0x15C] = "koopa klaw grab",
		[0x15D] = "koopa klaw bite",
		[0x15E] = "koopa klaw hold",
		[0x15F] = "koopa klaw throw headbutt",
		[0x160] = "koopa klaw throw backwards",

		[0x161] = "aerial koopa klaw swipe",
		[0x162] = "aerial koopa klaw grab",
		[0x163] = "aerial koopa klaw bite",
		[0x164] = "aerial koopa klaw hold",
		[0x165] = "aerial koopa klaw throw headbutt",
		[0x166] = "aerial koopa klaw throw backwards",

		[0x167] = "whirling fortress",
		[0x168] = "aerial whirling fortress",

		[0x169] = "bowser bomb start", -- (start)
		[0x16A] = "bowser bomb",
		[0x16B] = "bowser bomb end", -- (finish)
	},
	[CHARACTER_INTERNAL.LUIGI] = {
		[0x155] = "fireball",
		[0x156] = "aerial fireball",

		[0x157] = "diving headbutt windup",
		[0x158] = "diving headbutt charge",
		[0x159] = "diving headbutt fly", -- Grounded "flying" (I think this isn't possible, but who knows!)
		[0x15A] = "diving headbutt fall",
		[0x15B] = "diving headbutt launch",
		[0x15C] = "diving headbutt misfire",

		[0x15D] = "aerial diving headbutt windup",
		[0x15E] = "aerial diving headbutt charge",
		[0x15F] = "aerial diving headbutt fly",
		[0x160] = "aerial diving headbutt fall",
		[0x161] = "aerial diving headbutt launch",
		[0x162] = "areial diving headbutt misfire",

		[0x163] = "coin uppercut",
		[0x164] = "aerial coin uppercut",
		[0x165] = "spin punch",
		[0x166] = "aerial spin punch",
	},
	[CHARACTER_INTERNAL.PEACH] = {
		[0x155] = "hover start", -- (start)
		[0x156] = "hover finish", -- (finish)
		[0x157] = "hover timeout", -- (timeout)

		[0x158] = "peach unknown 1",
		[0x159] = "peach unknown 2",

		[0x160] = "pull turnip",
		[0x161] = "aerial pull turnip", -- I think this isn't possible..

		[0x162] = "peach bomber windup", -- (start)
		[0x163] = "peach bomber finish", -- (finish)
		[0x164] = "peach bomber explosion", -- (finish)

		[0x165] = "aerial peach bomber windup", -- (start)
		[0x166] = "aerial peach bomber finish", -- (finish)
		[0x167] = "aerial peach bomber explosion", -- (bounce back)
		[0x168] = "aerial peach bomber fly",

		[0x169] = "parasol jump",
		[0x16B] = "aerial parasol jump",

		[0x16C] = "peach unknown 3",

		[0x16D] = "toad",
		[0x16E] = "toad recoil",
		[0x16F] = "aerial toad",
		[0x170] = "aerial toad recoil",

		[0x171] = "parasol open start", -- (start)
		[0x172] = "parasol open finish", -- (finish)
	},
	[CHARACTER_INTERNAL.YOSHI] = {
		[0x155] = "egg shield windup",				-- GuardOn
		[0x156] = "egg shield",						-- Guard
		[0x157] = "egg unshield",					-- GuardOff
		[0x158] = "egg shield off",					-- GuardSetOff
		[0x159] = "egg shield reflect",				-- GuardReflect

		[0x15A] = "tongue",
		[0x15B] = "tongue grab",
		[0x15D] = "lay egg",

		[0x15F] = "aerial tongue",
		[0x160] = "aerial tongue grab",
		[0x161] = "aerial lay egg",
		[0x162] = "aerial tongue pull",

		[0x163] = "yoshi unknown 1",
		[0x164] = "yoshi unknown 2",

		[0x165] = "egg roll accelerate", -- (accelerate)
		[0x166] = "egg roll turn", -- (turn)
		[0x167] = "egg roll finish", -- (finish)
		[0x168] = "egg roll windup", -- (start)
		[0x169] = "egg roll airborn", -- (airborn)
		[0x16A] = "egg roll collide", -- (collision)

		[0x16B] = "yoshi unknown 3",

		[0x16C] = "throw egg",
		[0x16D] = "aerial throw egg",
		[0x16E] = "yoshi bomb jump", -- (jump)
		[0x16F] = "yoshi bomb slam", -- (finish)
		[0x170] = "yoshi bomb fall",
	},
	[CHARACTER_INTERNAL.DK] = {
		[0x155] = "DK unknown 1",
		[0x156] = "DK unknown 2",
		[0x157] = "DK unknown 3",
		[0x158] = "DK unknown 4",
		[0x159] = "DK unknown 5",
		[0x160] = "DK unknown 6",
		[0x161] = "DK unknown 7",
		[0x162] = "DK unknown 8",
		[0x163] = "DK unknown 9",
		[0x164] = "DK unknown 10",
		[0x165] = "DK unknown 11",
		[0x166] = "DK unknown 12",
		[0x167] = "DK unknown 13",
		[0x168] = "DK unknown 14",
		[0x169] = "DK unknown 15",
		[0x170] = "DK unknown 16",

		[0x171] = "giant punch start", -- (start)
		[0x172] = "giant punch charge", -- (charge)
		[0x174] = "giant punch release",
		[0x175] = "giant PUNCH", -- (fully charged)

		[0x176] = "aerial giant punch start", -- (start)
		[0x177] = "aerial giant punch charge", -- (charge)
		[0x179] = "aerial giant punch",
		[0x17A] = "aerial giant PUNCH", -- (fully charged)

		[0x17B] = "headbutt",
		[0x17C] = "aerial headbutt",

		[0x17D] = "spinning kong",
		[0x17E] = "aerial spinning kong",

		[0x17F] = "hand slap start", -- (start)
		[0x180] = "hand slap",
		[0x181] = "hand slap end", -- (finish)
	},
	[CHARACTER_INTERNAL.FOX] = {
		[0x155] = "pull gun", -- (start)
		[0x156] = "laser",
		[0x157] = "holster gun", -- (finish)
		[0x158] = "aerial pull gun", -- (start)
		[0x159] = "aerial laser",
		[0x15A] = "aerial holster gun", -- (finish)

		[0x15B] = "illusion start", -- (start)
		[0x15C] = "illusion",
		[0x15D] = "illusion end", -- (finish)
		[0x15E] = "aerial illusion", -- (start)
		[0x15F] = "aerial illusion",
		[0x160] = "aerial illusion", -- (finish)

		[0x161] = "firefox start", -- (start)
		[0x162] = "aerial firefox start", -- (start)
		[0x163] = "firefox",
		[0x164] = "aerial firefox",
		[0x165] = "firefox end", -- (finish)
		[0x166] = "aerial firefox end", -- (finish)
		[0x167] = "firefox collision", -- (collision)

		[0x168] = "shine start", -- (start)
		[0x169] = "shine",
		[0x16A] = "shine reflected", -- (reflect)
		[0x16B] = "shine end", -- (finish)
		[0x16C] = "shine turn", -- (turn)

		[0x16D] = "aerial shine start", -- (start)
		[0x16E] = "aerial shin",
		[0x16F] = "aerial shine reflected", -- (reflect)
		[0x170] = "aerial shin end", -- (finish)
		[0x171] = "aerial shine turn", -- (turn)
	},
	[CHARACTER_INTERNAL.FALCO] = {
		[0x155] = "pull gun", -- (start)
		[0x156] = "laser",
		[0x157] = "holster gun", -- (finish)
		[0x158] = "aerial pull gun", -- (start)
		[0x159] = "aerial laser",
		[0x15A] = "aerial holster gun", -- (finish)

		[0x15B] = "illusion start", -- (start)
		[0x15C] = "illusion",
		[0x15D] = "illusion end", -- (finish)
		[0x15E] = "aerial illusion", -- (start)
		[0x15F] = "aerial illusion",
		[0x160] = "aerial illusion", -- (finish)

		[0x161] = "firebird start", -- (start)
		[0x162] = "aerial firebird start", -- (start)
		[0x163] = "firebird",
		[0x164] = "aerial firebird",
		[0x165] = "firebird end", -- (finish)
		[0x166] = "aerial firebird end", -- (finish)
		[0x167] = "firebird collision", -- (collision)

		[0x168] = "shine start", -- (start)
		[0x169] = "shine",
		[0x16A] = "shine reflected", -- (reflect)
		[0x16B] = "shine end", -- (finish)
		[0x16C] = "shine turn", -- (turn)

		[0x16D] = "aerial shine start", -- (start)
		[0x16E] = "aerial shine",
		[0x16F] = "aerial shine reflected", -- (reflect)
		[0x170] = "aerial shine end", -- (finish)
		[0x171] = "aerial shine turn", -- (turn)
	},
	[CHARACTER_INTERNAL.DRMARIO] = {
		[0x157] = "vitamin",
		[0x158] = "aerial vitamin",

		[0x159] = "super sheet",
		[0x15A] = "aerial super sheet",

		[0x15B] = "super jump punch",
		[0x15C] = "aerial super jump punch",

		[0x15D] = "Dr. Tornado",
		[0x15E] = "aerial Dr. Tornado",
	},
	[CHARACTER_INTERNAL.NESS] = {
		[0x15C] = "PK flash windup", -- (start)
		[0x15D] = "PK flash charge", -- (charge)
		[0x15E] = "PK flash explosion", -- (explode)
		[0x15F] = "PK flash end", -- (finish)

		[0x160] = "aerial PK flash windup", -- (start)
		[0x161] = "aerial PK flash charge", -- (charge)
		[0x162] = "aerial PK flash explosion", -- (explode)
		[0x163] = "aerial PK flash end", -- (finish)

		[0x164] = "PK fire",
		[0x165] = "aerial PK fire",

		[0x166] = "PK thunder start", -- (start)
		[0x167] = "PK thunder",
		[0x168] = "PK thunder end", -- (finish)
		[0x169] = "PK thunder boosted", -- (self)

		[0x16A] = "aerial PK thunder start", -- (start)
		[0x16B] = "aerial PK thunder",
		[0x16C] = "aerial PK thunder end", -- (finish)
		[0x16D] = "aerial PK thunder boosted", -- (self)

		[0x16E] = "PK thunder collision", -- (self)

		[0x16F] = "PSI magnet windup", -- (start)
		[0x170] = "PSI magnet",
		[0x171] = "PSI magnet absorb", -- (absorb)
		[0x172] = "PSI magnet end", -- (finish)
		[0x174] = "aerial PSI magnet windup", -- (start)
		[0x175] = "aerial PSI magnet",
		[0x176] = "aerial PSI magnet absorb", -- (absorb)
		[0x177] = "aerial PSI magnet end", -- (finish)
	},
	[CHARACTER_INTERNAL.POPO] = {
		[0x155] = "ice shot",
		[0x156] = "aerial ice shot",

		[0x157] = "squall hammer", -- (main solo)
		[0x158] = "squall hammer", -- (main)
		[0x159] = "aerial squall hammer", -- (main solo)
		[0x15A] = "aerial squall hammer", -- (main)
		
		[0x15B] = "belay windup", -- (main start)
		[0x15C] = "belay",

		[0x15E] = "fail belay", -- (no latch start on ground)
		[0x15F] = "fail belay", -- (no latch start on ground finish)

		[0x160] = "aerial belay", -- (main start)
		[0x161] = "aerial belay",

		[0x162] = "belay launch", -- (launched)

		[0x163] = "fail belay", -- (no latch start)
		[0x164] = "fail belay", -- (no latch finish)

		[0x166] = "aerial blizzard",
		[0x165] = "blizzard",

		[0x167] = "partner squall hammer", -- (partner)
		[0x168] = "partner aerial squall hammer", -- (partner)

		[0x169] = "partner belay", -- (partner start)
		[0x16D] = "partner belay",
	},
	[CHARACTER_INTERNAL.KIRBY] = {
		[0x155] = "jump 1",
		[0x156] = "jump 2",
		[0x157] = "jump 3",
		[0x158] = "jump 4",
		[0x159] = "jump 5",

		[0x160] = "kirby unknown 1",

		[0x161] = "open mouth", -- (start)
		[0x162] = "inhale",
		[0x163] = "close mouth", -- (finish)
		[0x164] = "pull in", -- (sucked in player)

		[0x165] = "kirby unknown 2",

		[0x166] = "swallow", -- (fully swallowed player)
		[0x167] = "swallow stop", -- (sucked in player now walking)
		[0x168] = "swallow start walk", -- (started to walk while holding a swallowed player)
		[0x169] = "swallow walking", -- (walking while holding a swallowed player)
		[0x16A] = "swallow slow", -- (slowing down to a stop while holding a swallowed player)
		[0x16B] = "swallow turn", -- (turned around while holding a swallowed player)

		[0x16C] = "inhale jump windup", -- (start)
		[0x16D] = "inhale jump",
		[0x16E] = "inhale land", -- (finish)

		[0x16F] = "gain power", -- (spit out and gained their power)
		[0x170] = "areial gain power",

		[0x171] = "spit out", -- (spit out with star animation)
		[0x172] = "areial spit out",

		[0x173] = "aerial open mouth", -- (start)
		[0x174] = "aerial inhale",
		[0x175] = "aerial close mouth", -- (finish)

		[0x176] = "aerial suck in", -- (sucked in player)
		[0x165] = "kirby unknown 3",
		[0x178] = "aerial inhale", -- (fully swallowed player)
		[0x179] = "aerial gain power", -- (spit out and gained their power)
		[0x17A] = "aerial inhale release", -- (spit out and gained their power)

		[0x17B] = "kirby unknown 4",

		[0x17C] = "aerial spit out", -- (spit out with star animation)

		[0x17D] = "kirby unknown 5",

		[0x17F] = "hammer",
		[0x180] = "aerial hammer",

		[0x181] = "final cutter windup", -- (start)
		[0x182] = "final cutter jump",
		[0x183] = "final cutter fall",
		[0x184] = "final cutter slam", -- (finish)

		[0x185] = "aerial final cutter windup", -- (start)
		[0x186] = "aerial final cutter jump", -- (fall?)
		[0x187] = "aerial final cutter fall", -- (fall?)
		[0x188] = "aerial final cutter slam",

		[0x189] = "stone", -- (start)
		[0x18A] = "stone fall", -- (fall)
		[0x18B] = "stone revert", -- (finish)

		[0x18C] = "aerial stone", -- (start)
		[0x18D] = "aerial stone fall", -- (fall)
		[0x18E] = "aerial stone revert", -- (finish)

		-- Mario
		[0x18F] = "fireball",
		[0x190] = "aerial fireball",

		-- Link
		[0x191] = "link bow ready",
		[0x192] = "link bow fully charged",
		[0x193] = "link bow shot",
		[0x194] = "aerial link bow ready",
		[0x195] = "aerial link bow fully charged",
		[0x196] = "aerial link bow shot",

		-- Samus
		[0x197] = "samus pull gun",
		[0x198] = "samus charging shot",
		[0x199] = "samus charge complete",
		[0x19A] = "samus charge shot",
		[0x19B] = "aerial samus pull gun",
		[0x19C] = "aerial samus charge shot",

		-- Yoshi
		[0x19D] = "yoshi tongue",
		[0x19E] = "yoshi tongue grab",
		[0x19F] = "kirby/yoshi unknown egg 1",
		[0x1A0] = "lay egg",
		[0x1A1] = "kirby/yoshi unknown egg 2",
		[0x1A2] = "aerial yoshi tongue",
		[0x1A3] = "aerial yoshi tongue grab",
		[0x1A4] = "kirby/yoshi unknown egg 4",
		[0x1A5] = "aerial yoshi lay egg",
		[0x1A6] = "kirby/yoshi unknown egg 5",

		-- Fox
		[0x1A7] = "fox pull gun",
		[0x1A8] = "fox laser",
		[0x1A9] = "fox holster gun",
		[0x1AA] = "aerial fox pull gun",
		[0x1AB] = "aerial fox laser",
		[0x1AC] = "aerial fox holster gun",

		-- Pikachu
		[0x1AD] = "pikachu thunder jolt",
		[0x1AE] = "aerial pikachu thunder jolt",

		-- Luigi
		[0x1AF] = "green fireball",
		[0x1B0] = "aerial green fireball",

		-- Captain Falcon
		[0x1B1] = "falcon punch",
		[0x1B2] = "aerial falcon punch",

		-- Ness
		[0x1B3] = "PK flash windup", -- (start)
		[0x1B4] = "PK flash charge", -- (charge)
		[0x1B5] = "PK flash explosion", -- (explode)
		[0x1B6] = "PK flash end", -- (finish)
		[0x1B7] = "aerial PK flash windup", -- (start)
		[0x1B8] = "aerial PK flash charge", -- (charge)
		[0x1B9] = "aerial PK flash explosion", -- (explode)
		[0x1BA] = "aerial PK flash end", -- (finish)

		-- Bowser
		[0x1BB] = "bowser breath inhale",
		[0x1BC] = "bowser breathe fire",
		[0x1BD] = "bowser breath stop",
		[0x1BE] = "aerial breath inhale",
		[0x1BF] = "aerial breathe fire",
		[0x1C0] = "aerial breath stop",

		-- Peach
		[0x1C1] = "toad",
		[0x1C2] = "toad recoil",
		[0x1C3] = "aerial toad",
		[0x1C4] = "aerial toad recoil",

		-- Ice-Climbers
		[0x1C5] = "ice shot",
		[0x1C6] = "aerial ice shot",

		-- Donkey Kong
		[0x1C7] = "giant punch start",
		[0x1C8] = "giant punch windup",
		[0x1C9] = "giant punch charge",
		[0x1CA] = "giant punch",
		[0x1CB] = "giant PUNCH", -- (Fully charged)
		[0x1CC] = "aerial giant punch windup",
		[0x1CD] = "aerial giant punch charge",
		[0x1CF] = "aerial giant punch",
		[0x1D0] = "aerial giant PUNCH",

		-- Zelda
		[0x1D1] = "Nayru's love",
		[0x1D2] = "aerial Nayru's love",

		-- Sheik
		[0x1D3] = "sheik needles ready",
		[0x1D4] = "sheik needles charge",
		[0x1D5] = "sheik needles stop",
		[0x1D6] = "sheik needles",
		[0x1D7] = "aerial sheik needles ready",
		[0x1D8] = "aerial sheik needles charge",
		[0x1D9] = "aerial sheik needles stop",
		[0x1DA] = "aerial sheik needles",

		-- Jigglypuff
		[0x1DB] = "jigglypuff rollout prepare",
		[0x1DC] = "jigglypuff rollout start",
		[0x1DD] = "jigglypuff rollout windup",
		[0x1DE] = "jigglypuff rollout charge",
		[0x1DF] = "jigglypuff rollout release",
		[0x1E0] = "jigglypuff rollout turn",
		[0x1E1] = "jigglypuff rollout skid stop",
		[0x1E2] = "jigglypuff rollout accelerate",

		[0x1E3] = "aerial jigglypuff rollout prepare",
		[0x1E4] = "aerial jigglypuff rollout start",
		[0x1E5] = "aerial jigglypuff rollout windup",
		[0x1E6] = "aerial jigglypuff rollout charge",
		[0x1E7] = "aerial jigglypuff rollout release",
		[0x1E8] = "aerial jigglypuff rollout turn",
		[0x1E9] = "aerial jigglypuff rollout skid stop",
		[0x1EA] = "aerial jigglypuff rollout accelerate",

		[0x1EB] = "jigglypuff rollout collision",

		-- Marth
		[0x1EC] = "marth shield breaker ready",
		[0x1ED] = "marth shield breaker charge",
		[0x1EE] = "marth shield breaker release",
		[0x1EF] = "marth shield breaker max power",

		[0x1F0] = "aerial marth shield breaker ready",
		[0x1F1] = "aerial marth shield breaker charge",
		[0x1F2] = "aerial marth shield breaker release",
		[0x1F3] = "aerial marth shield breaker max power",

		-- Mewtwo
		[0x1F4] = "mewtwo shadow ball prepare",
		[0x1F5] = "mewtwo shadow ball ready",
		[0x1F6] = "mewtwo shadow ball charge",
		[0x1F7] = "mewtwo shadow ball stop",
		[0x1F8] = "mewtwo shadow ball release",

		[0x1F9] = "aerial mewtwo shadow ball prepare",
		[0x1FA] = "aerial mewtwo shadow ball ready",
		[0x1FB] = "aerial mewtwo shadow ball charge",
		[0x1FC] = "aerial mewtwo shadow ball stop",
		[0x1FD] = "aerial mewtwo shadow ball release",

		-- Mr. Game&Watch
		[0x1FE] = "game&watch bacon",
		[0x1FF] = "aerial game&watch bacon",

		-- Dr. Mario
		[0x200] = "vitamin",
		[0x201] = "aerial vitamin",

		-- Young Link
		[0x202] = "young link bow ready",
		[0x203] = "young link bow fully charge",
		[0x204] = "young link bow shot",
		[0x205] = "aerial young link bow ready",
		[0x206] = "aerial young link bow fully charge",
		[0x207] = "aerial young link bow shot",

		-- Falco
		[0x208] = "falco pull gun",
		[0x209] = "falco laser",
		[0x20A] = "falco holster gun",
		[0x20B] = "aerial falco pull gun",
		[0x20C] = "aerial falco laser",
		[0x20D] = "aerial falco holster gun",

		-- pichu
		[0x20E] = "pichu thunder jolt",
		[0x20F] = "aerial pichu thunder jolt",

		-- Ganondorf
		[0x210] = "warlock punch",
		[0x211] = "aerial warlock punch",

		-- Roy
		[0x212] = "roy flare blade ready",
		[0x213] = "roy flare blade charge",
		[0x214] = "roy flare blade release",
		[0x215] = "roy flare blade max power",
	
		[0x216] = "aerial roy flare blade ready",
		[0x217] = "aerial roy flare blade charge",
		[0x218] = "aerial roy flare blade release",
		[0x219] = "aerial roy flare blade max power",
	},
	[CHARACTER_INTERNAL.SAMUS] = {
		[0x155] = "samus unknown 1",
		[0x156] = "bomb jump",
		[0x157] = "pull gun",
		[0x158] = "charging shot",
		[0x159] = "charge complete",
		[0x15A] = "charge shot",
		[0x15B] = "aerial pull gun",
		[0x15C] = "aerial charge shot",
		[0x15D] = "homing missile",
		[0x15E] = "power missile",
		[0x15F] = "aerial homing missile",
		[0x160] = "aerial power missile",
		[0x161] = "screw attack",
		[0x162] = "aerial screw attack",
		[0x163] = "bomb bounce",
		[0x164] = "bomb",
	},
	[CHARACTER_INTERNAL.ZELDA] = {
		[0x155] = "Nayru's love",
		[0x156] = "aerial Nayru's love",

		[0x157] = "Din's fire ready",
		[0x158] = "Din's fire end",
		[0x159] = "Din's fire explosion",

		[0x15A] = "aerial Din's fire ready",
		[0x15B] = "aerial Din's fire end",
		[0x15C] = "aerial Din's fire explosion",

		[0x15D] = "Farore's wind cast",
		[0x15E] = "Farore's wind",
		[0x15F] = "Farore's wind end",

		[0x160] = "aerial Farore's wind cast",
		[0x161] = "aerial Farore's wind",
		[0x162] = "aerial Farore's wind end",

		[0x163] = "transform sheik",
		[0x164] = "awaken",
		[0x165] = "aerial transform sheik",
		[0x166] = "aerial awaken",
	},
	[CHARACTER_INTERNAL.SHEIK] = {
		[0x155] = "sheik needles ready",
		[0x156] = "sheik needles charge",
		[0x157] = "sheik needles stop",
		[0x158] = "sheik needles",

		[0x159] = "aerial sheik needles ready",
		[0x15A] = "aerial sheik needles charge",
		[0x15B] = "aerial sheik needles stop",
		[0x15C] = "aerial sheik needles",

		[0x15D] = "whip cast",
		[0x15E] = "whip",
		[0x15F] = "whip end",

		[0x160] = "aerial whip cast",
		[0x161] = "aerial whip",
		[0x162] = "aerial whip end",

		[0x163] = "vanish cast",
		[0x164] = "vanish",
		[0x165] = "vanish end",

		[0x166] = "aerial vanish cast",
		[0x167] = "aerial vanish",
		[0x168] = "aerial vanish end",

		[0x169] = "transform zelda",
		[0x16A] = "awaken",
		[0x16B] = "aerial transform zelda",
		[0x16C] = "aerial awaken",
	},
	[CHARACTER_INTERNAL.LINK] = {
		[0x155] = "forward smash (link)",
		[0x156] = "link unknown 1",
		[0x157] = "link unknown 2",

		[0x158] = "bow ready",
		[0x159] = "bow fully charge",
		[0x15A] = "bow shot",

		[0x15B] = "aerial bow ready",
		[0x15C] = "aerial bow fully charge",
		[0x15D] = "aerial bow shot",

		[0x15E] = "boomerang",
		[0x15F] = "boomerang catch",
		[0x160] = "boomerang empty handed",

		[0x161] = "aerial boomerang",
		[0x162] = "aerial boomerang catch",
		[0x163] = "aerial boomerang empty handed",

		[0x164] = "hero spin",
		[0x165] = "aerial hero spin",

		[0x166] = "bomb pull",
		[0x167] = "aerial bomb pull",
	},
	[CHARACTER_INTERNAL.YOUNGLINK] = {
		[0x155] = "forward smash (younglink)",
		[0x156] = "younglink unknown 1",
		[0x157] = "younglink unknown 2",

		[0x158] = "bow ready",
		[0x159] = "bow fully charge",
		[0x15A] = "bow shot",

		[0x15B] = "aerial bow ready",
		[0x15C] = "aerial bow fully charge",
		[0x15D] = "aerial bow shot",

		[0x15E] = "boomerang",
		[0x15F] = "boomerang catch",
		[0x160] = "boomerang empty handed",

		[0x161] = "aerial boomerang",
		[0x162] = "aerial boomerang catch",
		[0x163] = "aerialboomerang empty handed",

		[0x164] = "hero spin",
		[0x165] = "aerial hero spin",

		[0x166] = "bomb pull",
		[0x167] = "aerial bomb pull",
	},
	[CHARACTER_INTERNAL.PICHU] = {
		[0x155] = "thunder jolt",
		[0x156] = "aerial thunder jolt",

		[0x157] = "skull bash cast",
		[0x158] = "skull bash charge",
		[0x159] = "skull bash release",
		[0x15A] = "skull bash end",

		[0x15B] = "aerial skull bash prepare",
		[0x15C] = "aerial skull bash cast",
		[0x15D] = "aerial skull bash charge",
		[0x15E] = "aerial skull bash fly",

		[0x15F] = "skull bash hit",

		[0x160] = "aerial skull bash release",

		[0x161] = "quick attack cast",
		[0x162] = "quick attack",
		[0x163] = "quick attack end",

		[0x164] = "aerial quick attack cast",
		[0x165] = "aerial quick attack",
		[0x166] = "aerial quick attack end",

		[0x167] = "thunder cast",
		[0x168] = "thunder",
		[0x169] = "thunder self",
		[0x16A] = "thunder end",
		[0x16B] = "aerial thunder cast",
		[0x16C] = "aerial thunder",
		[0x16D] = "aerial thunder self",
		[0x16E] = "aerial thunder end",
	},
	[CHARACTER_INTERNAL.PIKACHU] = {
		[0x155] = "thunder jolt",
		[0x156] = "aerial thunder jolt",

		[0x157] = "skull bash cast",
		[0x158] = "skull bash charge",
		[0x159] = "skull bash release",
		[0x15A] = "skull bash end",

		[0x15B] = "aerial skull bash prepare",
		[0x15C] = "aerial skull bash cast",
		[0x15D] = "aerial skull bash charge",
		[0x15E] = "aerial skull bash fly",

		[0x15F] = "skull bash hit",

		[0x160] = "aerial skull bash release",

		[0x161] = "quick attack cast",
		[0x162] = "quick attack",
		[0x163] = "quick attack end",

		[0x164] = "aerial quick attack cast",
		[0x165] = "aerial quick attack",
		[0x166] = "aerial quick attack end",

		[0x167] = "thunder cast",
		[0x168] = "thunder",
		[0x169] = "thunder self",
		[0x16A] = "thunder end",
		[0x16B] = "aerial thunder cast",
		[0x16C] = "aerial thunder",
		[0x16D] = "aerial thunder self",
		[0x16E] = "aerial thunder end",
	},
	[CHARACTER_INTERNAL.JIGGLYPUFF] = {
		[0x155] = "jump 1",
		[0x156] = "jump 2",
		[0x157] = "jump 3",
		[0x158] = "jump 4",
		[0x159] = "jump 5",

		[0x15A] = "rollout prepare",
		[0x15B] = "rollout start",
		[0x15C] = "rollout windup",
		[0x15D] = "rollout charge",
		[0x15E] = "rollout release",
		[0x15F] = "rollout turn",
		[0x160] = "rollout skid stop",
		[0x161] = "rollout accelerate",

		[0x162] = "aerial rollout prepare",
		[0x163] = "aerial rollout start",
		[0x164] = "aerial rollout windup",
		[0x165] = "aerial rollout charge",
		[0x166] = "aerial rollout release",
		[0x167] = "aerial rollout turn",
		[0x168] = "aerial rollout skid stop",
		[0x169] = "aerial rollout accelerate",

		[0x16A] = "rollout collision",

		[0x16B] = "double slap",
		[0x16C] = "aerial double slap",

		[0x16D] = "sing",
		[0x16E] = "aerial sing",

		[0x170] = "jigglypuff unknown 1",
		[0x171] = "jigglypuff unknown 2",
		[0x172] = "jigglypuff unknown 3",

		[0x173] = "rest",
		[0x174] = "aerial rest",
	},
	[CHARACTER_INTERNAL.MEWTWO] = {
		[0x155] = "shadow ball prepare",
		[0x156] = "shadow ball ready",
		[0x157] = "shadow ball charge",
		[0x158] = "shadow ball stop",
		[0x159] = "shadow ball release",

		[0x15A] = "aerial shadow ball prepare",
		[0x15B] = "aerial shadow ball ready",
		[0x15C] = "aerial shadow ball charge",
		[0x15D] = "aerial shadow ball stop",
		[0x15E] = "aerial shadow ball release",

		[0x15F] = "confusion",
		[0x160] = "aerial confusion",

		[0x161] = "teleport cast",
		[0x162] = "teleport",
		[0x163] = "teleport end",

		[0x164] = "aerial teleport cast",
		[0x165] = "aerial teleport",
		[0x166] = "aerial teleport end",

		[0x167] = "disable",
		[0x168] = "aerial disable",
	},
	[CHARACTER_INTERNAL.MRGAMEWATCH] = {
		[0x155] = "jab 1",
		[0x156] = "jab 2",
		[0x157] = "jab 3",
		[0x158] = "jab finish",
		[0x159] = "game&watch unknown 1",
		[0x159] = "down tilt (G&W)",
		[0x15A] = "forward smash (G&W)",
		[0x15B] = "neutral air (G&W)",
		[0x15C] = "foward air (G&W)",
		[0x15D] = "up air (G&W)",
		[0x15E] = "landing neutral air (G&W)",
		[0x15F] = "landing foward air (G&W)",
		[0x160] = "landing up air (G&W)",

		[0x161] = "bacon",
		[0x162] = "aerial bacon",

		[0x163] = "number 1",
		[0x164] = "number 2",
		[0x165] = "number 3",
		[0x166] = "number 4",
		[0x167] = "number 5",
		[0x168] = "number 6",
		[0x169] = "number 7",
		[0x16A] = "number 8",
		[0x16B] = "number 9",
		[0x16C] = "aerial number 1",
		[0x16D] = "aerial number 2",
		[0x16E] = "aerial number 3",
		[0x16F] = "aerial number 4",
		[0x170] = "aerial number 5",
		[0x171] = "aerial number 6",
		[0x172] = "aerial number 7",
		[0x173] = "aerial number 8",
		[0x174] = "aerial number 9",

		[0x175] = "fire jump",
		[0x176] = "aerial fire jump",

		[0x177] = "oil panic empty",
		[0x178] = "oil panic 1/3",
		[0x179] = "oil panic 2/3",
		[0x17A] = "aerial oil panic",
		[0x17B] = "aerial oil panic 1/3",
		[0x17C] = "aerial oil panic 2/3",
		[0x17D] = "oil panic countered",
		[0x17E] = "aerial oil panic countered",
	},
	[CHARACTER_INTERNAL.MARTH] = {
		[0x155] = "shield breaker ready",
		[0x156] = "shield breaker charge",
		[0x157] = "shield breaker release",
		[0x158] = "shield breaker max power",

		[0x159] = "aerial shield breaker ready",
		[0x15A] = "aerial shield breaker charge",
		[0x15B] = "aerial shield breaker release",
		[0x15C] = "aerial shield breaker max power",

		[0x15D] = "sword dance 1",
		[0x15E] = "sword dance 2",
		[0x15F] = "sword dance 3",
		[0x160] = "sword dance 4",
		[0x161] = "sword dance 5",
		[0x162] = "sword dance 6",
		[0x163] = "sword dance 7",
		[0x164] = "sword dance 8",
		[0x165] = "sword dance 9",

		[0x166] = "aerial sword dance 1",
		[0x167] = "aerial sword dance 2",
		[0x168] = "aerial sword dance 3",
		[0x169] = "aerial sword dance 4",
		[0x16A] = "aerial sword dance 5",
		[0x16B] = "aerial sword dance 6",
		[0x16C] = "aerial sword dance 7",
		[0x16D] = "aerial sword dance 8",
		[0x16E] = "aerial sword dance 9",

		[0x16F] = "dolphin slash",
		[0x170] = "aerial dolphin slash",
		[0x171] = "counter",
		[0x172] = "countered",
		[0x173] = "aerial counter",
		[0x174] = "aerial countered",
	},
	[CHARACTER_INTERNAL.ROY] = {
		[0x155] = "flare blade ready",
		[0x156] = "flare blade charge",
		[0x157] = "flare blade release",
		[0x158] = "flare blade max power",

		[0x159] = "aerial flare blade ready",
		[0x15A] = "aerial flare blade charge",
		[0x15B] = "aerial flare blade release",
		[0x15C] = "aerial flare blade max power",

		[0x15D] = "double-edged dance 1",
		[0x15E] = "double-edged dance 2",
		[0x15F] = "double-edged dance 3",
		[0x160] = "double-edged dance 4",
		[0x161] = "double-edged dance 5",
		[0x162] = "double-edged dance 6",
		[0x163] = "double-edged dance 7",
		[0x164] = "double-edged dance 8",
		[0x165] = "double-edged dance 9",

		[0x166] = "aerial double-edged dance 1",
		[0x167] = "aerial double-edged dance 2",
		[0x168] = "aerial double-edged dance 3",
		[0x169] = "aerial double-edged dance 4",
		[0x16A] = "aerial double-edged dance 5",
		[0x16B] = "aerial double-edged dance 6",
		[0x16C] = "aerial double-edged dance 7",
		[0x16D] = "aerial double-edged dance 8",
		[0x16E] = "aerial double-edged dance 9",

		[0x16F] = "blazer",
		[0x170] = "aerial blazer",
		[0x171] = "counter",
		[0x172] = "countered",
		[0x173] = "aerial counter",
		[0x174] = "aerial countered",
	}
}
character_states[CHARACTER_INTERNAL.NANA] = character_states[CHARACTER_INTERNAL.POPO]

local player_states = {
	[0x000] = "dead (down)",				-- DeadDown
	[0x001] = "dead (left)",				-- DeadLeft
	[0x002] = "dead (right)",				-- DeadRight
	[0x003] = "dead (up)",					-- DeadUp
	[0x004] = "dead (star)",				-- DeadUpStar
	[0x005] = "dead (star)",				-- DeadUpStarIce
	[0x006] = "dead (up, fall)",			-- DeadUpFall
	[0x007] = "dead (up, fall, hit camera)",-- DeadUpFallHitCamera
	[0x008] = "dead (up, fall, hit camera)",-- DeadUpFallHitCameraFlat
	[0x009] = "dead (up, fall)",			-- DeadUpFallIce
	[0x00A] = "dead (up, fall, hit camera)",-- DeadUpFallHitCameraIce
	[0x00B] = "dead (sleep)",				-- Sleep

	[0x00C] = "spawning",					-- Rebirth
	[0x00D] = "spawn platform",				-- RebirthWait
	[0x00E] = "wait",						-- Wait

	[0x00F] = "walk slow",					-- WalkSlow
	[0x010] = "walk",						-- WalkMiddle
	[0x011] = "walk fast",					-- WalkFast
	[0x012] = "turn",						-- Turn
	[0x013] = "turn fast",					-- TurnRun
	[0x014] = "dash",						-- Dash

	[0x015] = "run",						-- run
	[0x016] = "run direct",					-- RunDirect
	[0x017] = "run brake",					-- RunBrake

	[0x018] = "jump bend knee",				-- KneeBend
	[0x019] = "jump forward",				-- JumpF
	[0x01A] = "jump backward",				-- JumpB
	[0x01B] = "jump areial forward",		-- JumpAerialF
	[0x01C] = "jump areial backward",		-- JumpAerialB

	[0x01D] = "fall",						-- Fall
	[0x01E] = "fall forward",				-- FallF
	[0x01F] = "fall backward",				-- FallB
	[0x020] = "fall areial",				-- FallAerial
	[0x021] = "fall areial forward",		-- FallAerialF
	[0x022] = "fall areial backward",		-- FallAerialB
	[0x023] = "fall special",				-- FallSpecial
	[0x024] = "fall special forward",		-- FallSpecialF
	[0x025] = "fall special backward",		-- FallSpecialB
	[0x026] = "fall damage",				-- DamageFall

	[0x027] = "crouch",						-- Squat
	[0x028] = "courching",					-- SquatWait
	[0x029] = "stand up",					-- SquatRv

	[0x02A] = "landing",					-- Landing
	[0x02B] = "landing fall special",		-- LandingFallSpecial

	[0x02C] = "jab 1",						-- Attack11
	[0x02D] = "jab 2",						-- Attack12
	[0x02E] = "jab 3",						-- Attack13
	[0x02F] = "flurry punch windup",		-- Attack100Start
	[0x030] = "flurry punch",				-- Attack100Loop
	[0x031] = "flurry punch end",			-- Attack100End
	[0x032] = "dash attack",				-- AttackDash
	[0x033] = "forward tilt (up-angle)",	-- AttackS3Hi
	[0x034] = "forward tilt (up-angle)",	-- AttackS3HiS
	[0x035] = "forward tilt",				-- AttackS3S
	[0x036] = "forward tilt (down-angle)",	-- AttackS3LwS
	[0x037] = "forward tilt (down-angle)",	-- AttackS3Lw
	[0x038] = "up tilt",					-- AttackHi3
	[0x039] = "down tilt",					-- AttackLw3
	[0x03A] = "forward smash (up-angle)",	-- AttackS4Hi
	[0x03B] = "forward smash (up-angle)",	-- AttackS4HiS
	[0x03C] = "forward smash",				-- AttackS4S
	[0x03D] = "forward smash (down-angle)",	-- AttackS4LwS
	[0x03E] = "forward smash (down-angle)",	-- AttackS4Lw
	[0x03F] = "up smash",					-- AttackHi4
	[0x040] = "down smash",					-- AttackLw4
	[0x041] = "neutral air",				-- AttackAirN
	[0x042] = "forward air",				-- AttackAirF
	[0x043] = "back air",					-- AttackAirB
	[0x044] = "up air",						-- AttackAirHi
	[0x045] = "down air",					-- AttackAirLw

	[0x046] = "landing neutral air",		-- LandingAirN
	[0x047] = "landing forward air",		-- LandingAirF
	[0x048] = "landing back air",			-- LandingAirB
	[0x049] = "landing air high",			-- LandingAirHi
	[0x04A] = "landing air low",			-- LandingAirLw

	[0x04B] = "damage high 1",				-- DamageHi1
	[0x04C] = "damage high 2",				-- DamageHi2
	[0x04D] = "damage high 3",				-- DamageHi3
	[0x04E] = "damage neutral 3",			-- DamageN1
	[0x04F] = "damage neutral 3",			-- DamageN2
	[0x050] = "damage neutral 3",			-- DamageN3
	[0x051] = "damage low 1",				-- DamageLw1
	[0x052] = "damage low 2",				-- DamageLw2
	[0x053] = "damage low 3",				-- DamageLw3
	[0x054] = "damage air 1",				-- DamageAir1
	[0x055] = "damage air 2",				-- DamageAir2
	[0x056] = "damage air 3",				-- DamageAir3
	[0x057] = "damage fly high",			-- DamageFlyHi
	[0x058] = "damage fly neutral",			-- DamageFlyN
	[0x059] = "damage fly low",				-- DamageFlyLw
	[0x05A] = "damage fly top",				-- DamageFlyTop
	[0x05B] = "damage fly roll",			-- DamageFlyRoll

	-- Items
	[0x05C] = "light item pickup",			-- LightGet
	[0x05D] = "heavy item pickup",			-- HeavyGet

	[0x05E] = "throw item forward",			-- LightThrowF
	[0x05F] = "throw item backward",		-- LightThrowB
	[0x060] = "throw item up",				-- LightThrowHi
	[0x061]	= "throw item down",			-- LightThrowLw
	[0x062]	= "throw item dash",			-- LightThrowDash
	[0x063]	= "drop item",					-- LightThrowDrop
	[0x064]	= "areial throw item forward",	-- LightThrowAirF
	[0x065]	= "areial throw item backward",	-- LightThrowAirB
	[0x066]	= "areial throw item up",		-- LightThrowAirHi
	[0x067]	= "areial throw item down",		-- LightThrowAirLw

	[0x068]	= "throw heavy item forward",	-- HeavyThrowF
	[0x069]	= "throw heavy item backward",	-- HeavyThrowB
	[0x06A]	= "throw heavy item up",		-- HeavyThrowHi
	[0x06B]	= "throw heavy item down",		-- HeavyThrowLw

	[0x06C]	= "throw light item forward",	-- LightThrowF4
	[0x06D]	= "throw light item backward",	-- LightThrowB4
	[0x06E]	= "throw light item up",		-- LightThrowHi4
	[0x06F]	= "throw light item down",		-- LightThrowLw4
	[0x070]	= "areial throw light item forward",	-- LightThrowAirF4
	[0x071]	= "areial throw light item backward",	-- LightThrowAirB4
	[0x072]	= "areial throw light item up",		-- LightThrowAirHi4
	[0x073]	= "areial throw light item down",		-- LightThrowAirLw4

	[0x074]	= "throw heavy item forward",	-- HeavyThrowF4
	[0x075]	= "throw heavy item backward",	-- HeavyThrowB4
	[0x076]	= "throw heavy item up",		-- HeavyThrowHi4
	[0x077]	= "throw heavy item down",		-- HeavyThrowLw4

	[0x078]	= "sword swing 1",				-- SwordSwing1
	[0x079]	= "sword swing 2",				-- SwordSwing3
	[0x07A]	= "sword swing 3",				-- SwordSwing4
	[0x07B]	= "sword swing dash",			-- SwordSwingDash

	[0x07C]	= "bat swing 1",				-- BatSwing1
	[0x07D]	= "bat swing 2",				-- BatSwing3
	[0x07E]	= "bat swing 3",				-- BatSwing4
	[0x07F]	= "bat swing dash",				-- BatSwingDash

	[0x080]	= "parasol swing 1",			-- ParasolSwing1
	[0x081]	= "parasol swing 2",			-- ParasolSwing3
	[0x082]	= "parasol swing 3",			-- ParasolSwing4
	[0x083]	= "parasol swing dash",			-- ParasolSwingDash

	[0x084]	= "fan swing 1",				-- HarisenSwing1
	[0x085]	= "fan swing 2",				-- HarisenSwing3
	[0x086]	= "fan swing 3",				-- HarisenSwing4
	[0x087]	= "fan swing dash",				-- HarisenSwingDash

	[0x088]	= "star rod swing 1",			-- StarRodSwing1
	[0x089]	= "star rod swing 2",			-- StarRodSwing3
	[0x08A]	= "star rod swing 3",			-- StarRodSwing4
	[0x08B]	= "star rod swing dash",		-- StarRodSwingDash

	[0x08C]	= "lip-stick swing 1",			-- LipStickSwing1
	[0x08D]	= "lip-stick swing 2",			-- LipStickSwing3
	[0x08E]	= "lip-stick swing 3",			-- LipStickSwing4
	[0x08F]	= "lip-stick swing dash",		-- LipStickSwingDash

	[0x090]	= "parasol open",				-- ItemParasolOpen
	[0x091]	= "parasol fall",				-- ItemParasolFall
	[0x092]	= "parasol special",			-- ItemParasolFallSpecial
	[0x093]	= "parasol damage fall",		-- ItemParasolDamageFall

	[0x094] = "gun shoot",					-- LGunShoot
	[0x095] = "aerial gun shoot",			-- LGunShootAir
	[0x096] = "empty gun shoot",			-- LGunShootEmpty
	[0x097] = "aerial empty gun shoot",		-- LGunShootAirEmpty

	[0x098] = "fire flower shoot",			-- FireFlowerShoot
	[0x099] = "areial fire flower shoot",	-- FireFlowerShootAir

	[0x09A] = "screw attack",							-- ItemScrew
	[0x09B] = "areial screw attack",					-- ItemScrewAir
	[0x09C] = "screw attack damage",					-- DamageScrew
	[0x09D] = "areial screw attack damage",				-- DamageScrewAir
	[0x09E] = "super scope start",						-- ItemScopeStart
	[0x09F] = "super scope rapid fire",					-- ItemScopeRapid
	[0x0A0] = "super scope fire",						-- ItemScopeFire
	[0x0A1] = "super scope end",						-- ItemScopeEnd
	[0x0A2] = "areial super scope start",				-- ItemScopeAirStart
	[0x0A3] = "areial super scope rapid fire",			-- ItemScopeAirRapid
	[0x0A4] = "areial super scope fire",				-- ItemScopeAirFire
	[0x0A5] = "areial super scope end",					-- ItemScopeAirEnd
	[0x0A6] = "super scope start empty",				-- ItemScopeStartEmpty
	[0x0A7] = "super scope rapid fire empty",			-- ItemScopeRapidEmpty
	[0x0A8] = "super scope fire empty",					-- ItemScopeFireEmpty
	[0x0A9] = "super scope end empty",					-- ItemScopeEndEmpty
	[0x0AA] = "areial super scope start empty",			-- ItemScopeAirStartEmpty
	[0x0AB] = "areial super scope rapid fire empty",	-- ItemScopeAirRapidEmpty
	[0x0AC] = "areial super scope fire empty",			-- ItemScopeAirFireEmpty
	[0x0AD] = "areial super scope end empty",			-- ItemScopeAirEndEmpty

	[0x0AE] = "lift idle",					-- LiftWait
	[0x0AF] = "lift walk 1",				-- LiftWalk1
	[0x0B0] = "lift walk 2",				-- LiftWalk2
	[0x0B1] = "lift turn",					-- LiftTurn

	-- Shielding
	[0x0B2] = "shield windup",				-- GuardOn
	[0x0B3] = "shield",						-- Guard
	[0x0B4] = "unshield",					-- GuardOff
	[0x0B5] = "shield off",					-- GuardSetOff
	[0x0B6] = "shield reflect",				-- GuardReflect

	-- Knocked down animations
	[0x0B7] = "down",						-- DownBoundU
	[0x0B8] = "down",						-- DownWaitU
	[0x0B9] = "down damaged",				-- DownDamageU
	[0x0BA] = "down stand up",				-- DownStandU
	[0x0BB] = "down attack",				-- DownAttackU
	[0x0BC] = "down roll forward",			-- DownFowardU
	[0x0BD] = "down roll backward",			-- DownBackU
	[0x0BE] = "down spot?",					-- DownSpotU
	[0x0BF] = "down",						-- DownBoundD
	[0x0C0] = "down idle",					-- DownWaitD
	[0x0C1] = "down damaged",				-- DownDamageD
	[0x0C2] = "down and standing",			-- DownStandD
	[0x0C3] = "down attack",				-- DownAttackD
	[0x0C4] = "down roll forward",			-- DownFowardD
	[0x0C5] = "down roll backwards",		-- DownBackD
	[0x0C6] = "down spot?",					-- DownSpotD

	-- ???
	[0x0C7] = "Passive",					-- Passive
	[0x0C8] = "PassiveStandF",				-- PassiveStandF
	[0x0C9] = "PassiveStandB",				-- PassiveStandB
	[0x0CA] = "PassiveWall",				-- PassiveWall
	[0x0CB] = "PassiveWallJump",			-- PassiveWallJump
	[0x0CC] = "PassiveCeil",				-- PassiveCeil

	-- Shield breaking
	[0x0CD] = "shield break pop",			-- ShieldBreakFly
	[0x0CE] = "shield break falling",		-- ShieldBreakFall
	[0x0CF] = "shield break fall down",		-- ShieldBreakDownU
	[0x0D0] = "shield break fall down",		-- ShieldBreakDownD
	[0x0D1] = "shield break stand",			-- ShieldBreakStandU
	[0x0D2] = "shield break stand",			-- ShieldBreakStandD
	[0x0D3] = "stunned",					-- FuraFura

	-- A character grabbing someone
	[0x0D4] = "grab",						-- Catch
	[0x0D5] = "pull grab",					-- CatchPull
	[0x0D6] = "dash grab",					-- CatchDash
	[0x0D7] = "dash pull grab",				-- CatchDashPull
	[0x0D8] = "hold",						-- CatchWait
	[0x0D9] = "grab attack",				-- CatchAttack
	[0x0DA] = "grab release",				-- CatchCut

	-- A character being thrown
	[0x0DB] = "forward throw",				-- ThrowF
	[0x0DC] = "back throw",					-- ThrowB
	[0x0DD] = "up throw",					-- ThrowHi
	[0x0DE] = "down throw",					-- ThrowLw

	[0x0DF] = "pull into grab from air",	-- CapturePulledHi
	[0x0E0] = "hold air",					-- CaptureWaitHi
	[0x0E1] = "hold air damage",			-- CaptureDamageHi
	[0x0E2] = "pulled into grab",			-- CapturePulledLw
	[0x0E3] = "hold ground",				-- CaptureWaitLw
	[0x0E4] = "hold damage",				-- CaptureDamageLw

	[0x0E5] = "release from grab",			-- CaptureCut
	[0x0E6] = "jump from grab",				-- CaptureJump
	[0x0E7] = "grab neck",					-- CaptureNeck
	[0x0E8] = "grab foot",					-- CaptureFoot

	[0x0E9] = "roll forward",				-- EscapeF
	[0x0EA] = "roll backward",				-- EscapeB
	[0x0EB] = "spot dodge",					-- Escape
	[0x0EC] = "air dodge",					-- EscapeAir

	-- When moves "clank"
	[0x0ED] = "clank",						-- ReboundStop
	[0x0EE] = "clank recoil",				-- Rebound

	-- Character being thrown
	[0x0EF] = "forward thrown",				-- ThrownF
	[0x0F0] = "back thrown",				-- ThrownB
	[0x0F1] = "up thrown",					-- ThrownHi
	[0x0F2] = "down thrown", 				-- ThrownLw
	[0x0F3] = "down thrown",				-- ThrownLwWomen

	[0x0F4] = "platform drop",				-- Pass

	[0x0F5] = "teeter start",				-- Ottotto
	[0x0F6] = "teetering",					-- OttottoWait

	[0x0F7] = "wall bounce",				-- FlyReflectWall
	[0x0F8] = "ceiling bounce",				-- FlyReflectCeil
	[0x0F9] = "wall stop",					-- StopWall
	[0x0FA]	= "ceiling stop",				-- StopCeil
	[0x0FB]	= "miss foot",					-- MissFoot

	[0x0FC]	= "ledge grab",					-- CliffCatch
	[0x0FD]	= "ledge hold",					-- CliffWait
	[0x0FE]	= "ledge climb slow",			-- CliffClimbSlow
	[0x0FF]	= "ledge climb fast",			-- CliffClimbQuick
	[0x100]	= "ledge slow-attack",			-- CliffAttackSlow
	[0x101]	= "ledge fast-attack",			-- CliffAttackQuick
	[0x102]	= "ledge roll slow",			-- CliffEscapeSlow
	[0x103]	= "ledge roll fast",			-- CliffEscapeQuick
	[0x104]	= "ledge slow jump",			-- CliffJumpSlow1
	[0x105]	= "ledge slow jump",			-- CliffJumpSlow2
	[0x106]	= "ledge fast jump",			-- CliffJumpQuick1
	[0x107]	= "ledge fast jump",			-- CliffJumpQuick2

	-- Taunting
	[0x108]	= "taunt left face",			-- AppealR
	[0x109]	= "taunt right face",			-- AppealL

	-- DK Grab stuff
	[0x10A] = "shouldered",					-- ShoulderedWait
	[0x10B] = "shouldered walk",			-- ShoulderedWalkSlow
	[0x10C] = "shouldered run",				-- ShoulderedWalkMiddle
	[0x10D] = "shouldered dash",			-- ShoulderedWalkFast
	[0x10E] = "Shouldered turn",			-- ShoulderedTurn

	-- Being thrown
	[0x10F] = "forward thrown",				-- ThrownFF
	[0x110] = "backward thrown",			-- ThrownFB
	[0x111] = "up thrown",					-- ThrownFHi
	[0x112] = "down thrown",				-- ThrownFLw

	[0x113] = "grabbed by cpt. falcon",		-- CaptureCaptain

	[0x114] = "grabbed by yoshi",			-- CaptureYoshi
	[0x115] = "yoshi egg",					-- YoshiEgg

	[0x116] = "grabbed by bowser",			-- CaptureKoopa
	[0x117] = "hit by bowser while grabbed",-- CaptureDamageKoopa
	[0x118] = "held by bowser",				-- CaptureWaitKoopa
	[0x119] = "forward thrown by bowser",	-- ThrownKoopaF
	[0x11A] = "backwards thrown by bowser",	-- ThrownKoopaB
	[0x11B] = "areial grabbed by bowser",	-- CaptureKoopaAir
	[0x11C] = "areial hit by bowser while grabbed", -- CaptureDamageKoopaAir
	[0x11D] = "areial held by bowser",		-- CaptureWaitKoopaAir
	[0x11E] = "areial thrown forward by bowser",	-- ThrownKoopaAirF
	[0x11F] = "areial thrown backwards by bowser",	-- ThrownKoopaAirB

	[0x120] = "inhaled by kirby",			-- CaptureKirby
	[0x121] = "held by kirby",				-- CaptureWaitKirby
	[0x122] = "spat out as star", 			-- ThrownKirbyStar
	[0x123] = "kirby stole ability",		-- ThrownCopyStar
	[0x124] = "spat out",					-- ThrownKirby

	[0x125] = "barrel idle",				-- BarrelWait

	[0x126] = "burried",					-- Bury
	[0x127] = "burried idle",				-- BuryWait
	[0x128] = "burried jump",				-- BuryJump

	[0x129] = "fall asleep",				-- DamageSong
	[0x12A] = "sleeping",					-- DamageSongWait
	[0x12B] = "wake up",					-- DamageSongRv
	[0x12C] = "damaged by bind",			-- DamageBind

	[0x12D] = "grabbed by mewtwo",			-- CaptureMewtwo
	[0x12E] = "areial grabbed by mewtwo",	-- CaptureMewtwoAir
	[0x12F] = "thrown by mewtwo",			-- ThrownMewtwo
	[0x130] = "areial thrown by mewtwo",	-- ThrownMewtwoAir

	[0x131] = "warp star jump",					-- WarpStarJump
	[0x132] = "warp star fall",					-- WarpStarFall

	[0x133] = "hammer idle",					-- HammerWait
	[0x134] = "hammer walk",					-- HammerWalk
	[0x135] = "hammer turn",					-- HammerTurn
	[0x136] = "hammer knee bend",				-- HammerKneeBend
	[0x137] = "hammer fall",					-- HammerFall
	[0x138] = "hammer jump",					-- HammerJump
	[0x139] = "hammer landing",					-- HammerLanding

	[0x13A] = "giant mushroom start",			-- KinokoGiantStart
	[0x13B] = "areial giant mushroom start",	-- KinokoGiantStartAir
	[0x13C] = "giant mushroom end",				-- KinokoGiantEnd
	[0x13D] = "areial giant mushroom end",		-- KinokoGiantEndAir
	[0x13E] = "mini mushroom start",			-- KinokoSmallStart
	[0x13F] = "areial mini mushroom start",		-- KinokoSmallStartAir
	[0x140] = "mini mushroom end",				-- KinokoSmallEnd
	[0x141] = "areial mini mushroom end",		-- KinokoSmallEndAir

	[0x142] = "spawn start",					-- Entry
	[0x143]	= "Spawn drop in",					-- EntryStart
	[0x144] = "spawn end",						-- EntryEnd

	[0x145] = "damaged by ice",					-- DamageIce
	[0x146] = "damaged and launced by ice",		-- DamageIceJump

	[0x147] = "grabbed by master hand",		-- CaptureMasterhand
	[0x148] = "squeezed by master hand",	-- CapturedamageMasterhand
	[0x149] = "held by master hand",		-- CapturewaitMasterhand
	[0x14A] = "thrown by master hand",		-- ThrownMasterhand

	[0x14B] = "grabbed by kirby",			-- CaptureKirbyYoshi
	[0x14C] = "KirbyYoshiEgg",				-- KirbyYoshiEgg
	[0x14D] = "grabbed by redead",			-- CaptureLeadead
	[0x14E] = "grabbed by likelike",		-- CaptureLikelike

	[0x14F] = "down reflect?",				-- DownReflect

	[0x150] = "grabbed by crazy hand",		-- CaptureCrazyhand
	[0x151] = "squeezed by crazy hand",		-- CapturedamageCrazyhand
	[0x152] = "held by crazy hand",			-- CapturewaitCrazyhand
	[0x153] = "thrown by crazy hand",		-- ThrownCrazyhand

	[0x154] = "barrel cannon wait",			-- BarrelCannonWait

	[0x155] = "wait 1",		-- Wait1
	[0x156] = "wait 2",		-- Wait2
	[0x157] = "wait 3",		-- Wait3
	[0x158] = "wait 4",		-- Wait4
	[0x159] = "wait item",	-- WaitItem

	[0x15A] = "crouch wait 1",			-- SquatWait1
	[0x15B] = "crouch wait 2",			-- SquatWait2
	[0x15C] = "crouch wait with item",	-- SquatWaitItem

	[0x15D] = "shield damaged",			-- GuardDamage

	[0x15E] = "escape from grab?",		-- EscapeN

	[0x15F] = "AttackS4Hold",			-- AttackS4Hold

	[0x160] = "heavy walk",				-- HeavyWalk1
	[0x161] = "heavy walk",				-- HeavyWalk2

	[0x162] = "hammer wait?",			-- ItemHammerWait
	[0x163] = "hammer move?",			-- ItemHammerMove

	[0x164] = "invisible",				-- ItemBlind

	[0x165] = "damaged by electricity",	-- DamageElec

	[0x166] = "stunned start",			-- FuraSleepStart
	[0x167] = "stunned",				-- FuraSleepLoop
	[0x168] = "stunned end",			-- FuraSleepEnd

	[0x169] = "wall damage",			-- WallDamage

	[0x16A] = "ledge hold",				-- CliffWait1
	[0x16B] = "ledge hold",				-- CliffWait2

	[0x16C] = "slip fall down",			-- SlipDown
	[0x16D] = "slip",					-- Slip
	[0x16E] = "slip turn",				-- SlipTurn
	[0x16F] = "slip dash",				-- SlipDash
	[0x170] = "slip idle",				-- SlipWait
	[0x171] = "slip stand up",			-- SlipStand
	[0x172] = "slip attack",			-- SlipAttack
	[0x173] = "slip roll forward",		-- SlipEscapeF
	[0x174] = "slip roll backward",		-- SlipEscapeB

	[0x175] = "taunt special", -- AppealS

	[0x176] = "struggle", -- Zitabata

	[0x177] = "hit by bowser while grabbed",	-- CaptureKoopaHit
	[0x178] = "thrown forward by bowser",		-- ThrownKoopaEndF
	[0x179] = "thrown backward by bowser",		-- ThrownKoopaEndB
	[0x17A] = "hit by bowser while grabbed",	-- CaptureKoopaAirHit
	[0x17B] = "thrown forward by bowser",		-- ThrownKoopaAirEndF
	[0x17C] = "thrown backward by bowser",		-- ThrownKoopaAirEndB

	[0x17D] = "ThrownKirbyDrinkSShot",			-- ThrownKirbyDrinkSShot
	[0x17E] = "ThrownKirbySpitSShot",			-- ThrownKirbySpitSShot
}

function state.translate(id)
	return player_states[id] or "unknown state"
end

function state.translateChar(char, id)
	return character_states[char] and character_states[char][id] or player_states[id] or "unknown state"
end

function state.isAction(id)
	return reactions[id] == nil
end

function state.isCharacterAction(char, id)
	return character_states[char] and character_states[char][id]
end

return state