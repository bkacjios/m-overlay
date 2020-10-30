local music = {}

local log = require("log")
local melee = require("melee")
local memory = require("memory")
local notification = require("notification")

local STAGE_TRACKS_LOADED = {}
local STAGE_TRACKS = {}
local TRACK_NUMBER = {}
local STAGE_ID = 0
local PLAYING_SONG = nil

local function moveFolderContentsTo(from, to)
	local info = love.filesystem.getInfo(from)

	if info and info.type == "directory" then
		-- Upgrade to new folder layout
		local configdir = love.filesystem.getSaveDirectory()

		local files = love.filesystem.getDirectoryItems(from)
		for k, file in ipairs(files) do
			os.rename(("%s/%s/%s"):format(configdir, from, file), ("%s/%s/%s"):format(configdir, to, file))
		end

		love.filesystem.remove(from)
	end
end

function music.init()
	love.filesystem.setSymlinksEnabled(true)

	love.filesystem.createDirectory("Melee")

	local info = love.filesystem.getInfo("Stage Music")

	if info and info.type == "directory" then
		-- Upgrade to new folder layout
		local configdir = love.filesystem.getSaveDirectory()
		os.rename(("%s/Stage Music"):format(configdir), ("%s/Melee/Stage Music"):format(configdir))
	end

	local info = love.filesystem.getInfo("Melee/Stage Music/Menu")

	if info and info.type == "directory" then
		-- Upgrade to new folder layout
		local configdir = love.filesystem.getSaveDirectory()
		os.rename(("%s/Melee/Stage Music/Menu"):format(configdir), ("%s/Melee/Menu Music"):format(configdir))
	else
		love.filesystem.createDirectory("Melee/Menu Music")
	end

	-- VS mode folders

	for stageid, name in pairs(melee.getAllStages()) do
		love.filesystem.createDirectory(("Melee/Stage Music/%s"):format(name))
	end
	moveFolderContentsTo("Melee/Stage Music/All", "Melee/Stage Music")

	-- Single player folders

	love.filesystem.createDirectory("Melee/Single Player Music")
	
	for stageid, name in pairs(melee.getSinglePlayerStages()) do
		love.filesystem.createDirectory(("Melee/Single Player Music/%s"):format(name))
	end

	-- Series folders

	for stageid, series in pairs(melee.getAllStageSeries()) do
		love.filesystem.createDirectory(("Melee/Series Music/%s"):format(series))
	end
	moveFolderContentsTo("Melee/Series Music/All", "Melee/Series Music")

	love.filesystem.createDirectory("Melee/Single Player Music/Break the Targets")
end

function music.isInGame()
	if not memory.menu_major or not memory.menu_minor then return false end

	if memory.menu_major == MENU_ALL_STAR_MODE and memory.menu_minor < MENU_ALL_STAR_CSS then
		-- Even = playing the match
		-- Odd  = in the rest area
		--return memory.menu_minor % 2 == 0
		return true
	end
	if memory.menu_major == MENU_VS_MODE then
		return memory.menu_minor == MENU_VS_INGAME and not memory.match.finished
	end
	if memory.menu_major >= MENU_TRAINING_MODE and memory.menu_major <= MENU_STAMINA_MODE or memory.menu_major == MENU_FIXED_CAMERA_MODE then
		return memory.menu_minor == MENU_TRAINING_INGAME
	end
	if memory.menu_major == MENU_EVENT_MATCH then
		return memory.menu_minor == MENU_EVENT_MATCH_INGAME
	end
	if memory.menu_major == MENU_CLASSIC_MODE and memory.menu_minor < MENU_CLASSIC_CONTINUE then
		-- Even = Verus screen
		-- Odd  = playing the match
		return memory.menu_minor % 2 == 1
	end
	if memory.menu_major == MENU_TARGET_TEST then
		return memory.menu_minor == MENU_TARGET_TEST_INGAME
	end
	if memory.menu_major >= MENU_SUPER_SUDDEN_DEATH and memory.menu_major <= MENU_LIGHTNING_MELEE then
		return memory.menu_minor == MENU_SSD_INGAME
	end
	if memory.menu_major >= MENU_HOME_RUN_CONTEST and memory.menu_major <= MENU_CRUEL_MELEE then
		return memory.menu_minor == MENU_HOME_RUN_CONTEST_INGAME
	end
	return false
end

function music.isInMenus()
	if not memory.menu_major or not memory.menu_minor then return false end
	
	if memory.menu_major == MENU_MAIN_MENU then
		return true
	end
	if memory.menu_major == MENU_VS_MODE then
		return memory.menu_minor == MENU_VS_CSS or memory.menu_minor == MENU_VS_SSS
	end
	if memory.menu_major >= MENU_TRAINING_MODE and memory.menu_major <= MENU_STAMINA_MODE or memory.menu_major == MENU_FIXED_CAMERA_MODE then
		return memory.menu_minor == MENU_TRAINING_CSS or memory.menu_minor == MENU_TRAINING_SSS
	end
	if memory.menu_major == MENU_EVENT_MATCH then
		return memory.menu_minor == MENU_EVENT_MATCH_SELECT
	end
	if memory.menu_major == MENU_CLASSIC_MODE or memory.menu_major == MENU_ADVENTURE_MODE or memory.menu_major == MENU_ALL_STAR_MODE then
		-- All the menu_mior values all match in these three modes, so just use the MENU_CLASSIC_CSS value for simplicity
		return memory.menu_minor == MENU_CLASSIC_CSS
	end
	if memory.menu_major == MENU_TARGET_TEST then
		return memory.menu_minor == MENU_TARGET_TEST_CSSS
	end
	if memory.menu_major >= MENU_SUPER_SUDDEN_DEATH and memory.menu_major <= MENU_LIGHTNING_MELEE then
		return memory.menu_minor == MENU_SSD_CSS or memory.menu_minor == MENU_SSD_SSS
	end
	if memory.menu_major >= MENU_HOME_RUN_CONTEST and memory.menu_major <= MENU_CRUEL_MELEE then
		return memory.menu_minor == MENU_HOME_RUN_CONTEST_CSS
	end
	return false
end

function music.kill()
	if PLAYING_SONG and PLAYING_SONG:isPlaying() then
		PLAYING_SONG:stop()
	end
end

local LOOPING_OFF = 1
local LOOPING_MENU = 2
local LOOPING_STAGE = 3
local LOOPING_ALL = 4

-- Set to true when the announcer says 'GAME!'
local MATCH_SOFT_END = false

function music.shouldPlayMusic()
	return music.isInMenus() or (music.isInGame() and not MATCH_SOFT_END)
end

function music.onLoopChange(mode)
	if PLAYING_SONG and PLAYING_SONG:isPlaying() then
		local loop = false
		-- Handle the different loop settings properly
		if mode == LOOPING_MENU and music.isInMenus() then
			loop = true
		elseif mode == LOOPING_STAGE and music.isInGame() then
			loop = true
		elseif mode == LOOPING_ALL then
			loop = true
		end
		PLAYING_SONG:setLooping(loop)
	end
end

function music.getVolume()
	return PANEL_SETTINGS:GetVolume()
end

function music.setVolume(vol)
	if PLAYING_SONG and PLAYING_SONG:isPlaying() then
		PLAYING_SONG:setVolume((vol/100) * (memory.match.paused and 0.35 or 1))
	end
end

function music.playNextTrack()
	if not memory.isMelee() or not PANEL_SETTINGS:PlayStageMusic() then return end
	if PLAYING_SONG ~= nil and PLAYING_SONG:isPlaying() then return end
	if not STAGE_ID or not STAGE_TRACKS[STAGE_ID] then return end
	if not music.shouldPlayMusic() then return end

	local songs = STAGE_TRACKS[STAGE_ID]

	if songs and #songs > 0 then
		TRACK_NUMBER[STAGE_ID] = ((TRACK_NUMBER[STAGE_ID] or -1) + 1) % #songs
		local track = TRACK_NUMBER[STAGE_ID] + 1
		PLAYING_SONG = songs[track]

		-- Every time we play a song, we randomly place it towards the start of the playlist
		local newpos = math.random(1, track)

		table.remove(songs, track)
		table.insert(songs, newpos, PLAYING_SONG)

		if PLAYING_SONG then
			if STAGE_ID == 0x0 then
				log.info("[MUSIC] Playing track #%d for menu", track)
			else
				log.info("[MUSIC] Playing track #%d for stage %q", track, melee.getStageName(STAGE_ID))
			end

			local loop = PANEL_SETTINGS:GetMusicLoopMode()

			if STAGE_ID == 0 then
				PLAYING_SONG:setLooping(loop == LOOPING_MENU or loop == LOOPING_ALL)
			else
				PLAYING_SONG:setLooping(loop == LOOPING_STAGE or loop == LOOPING_ALL)
			end

			PLAYING_SONG:setVolume((PANEL_SETTINGS:GetVolume()/100) * (memory.match.paused and 0.35 or 1))
			PLAYING_SONG:play()
		end
	end
end

function music.onStateChange()
	if music.isInGame() then
		music.loadForStage(memory.stage)
	elseif music.isInMenus() then
		music.loadForStage(0)
	end
end

memory.hook("frame", "Melee - Music Think", music.playNextTrack)

memory.hook("OnGameClosed", "Dolphin - Game closed", function()
	music.kill()
end)

memory.hook("menu_major", "Melee - Menu state", function(menu)
	if music.isInMenus() then
		music.loadForStage(0)
	elseif not music.isInGame() then
		music.kill()
	end
end)

memory.hook("menu_minor", "Melee - Menu state", function(menu)
	if music.isInMenus() then
		music.loadForStage(0)
	elseif music.isInGame() then
		MATCH_SOFT_END = false
		music.loadForStage(memory.stage)
	else
		music.kill()
	end
end)

memory.hook("stage", "Melee - Stage loaded", function(stage)
	if music.isInGame() then
		music.loadForStage(stage)
	end
end)

memory.hook("match.playing", "Melee - Classic Mode Master Hand Fix?", function(playing)
	if memory.menu_major == MENU_CLASSIC_MODE and memory.stage == 0x25 and not playing then
		MATCH_SOFT_END = true
		music.kill()
	end
end)

memory.hook("match.paused", "Melee - Pause volume", function(paused)
	music.setVolume(music.getVolume())
end)

memory.hook("match.result", "Melee - GAME kill music", function(result)
	if result ~= MATCH_NO_RESULT and result ~= MATCH_NO_CONTEST then
		MATCH_SOFT_END = true
		music.kill()
	end
end)

memory.hook("controller.*.buttons.pressed", "Melee - Music skipper", function(port, pressed)
	if PANEL_SETTINGS:IsBinding() then return end -- Don't skip when the user is setting a button combination..
	local mask = PANEL_SETTINGS:GetMusicSkipMask()
	if mask ~= 0x0 and port == love.getPort() and bit.band(pressed, mask) == mask and STAGE_TRACKS[STAGE_ID] and #STAGE_TRACKS[STAGE_ID] > 1 then
		log.debug("[MUSIC] [MASK = 0x%X] Button combo pressed, stopping music.", mask)
		music.kill()
	end
end)

local valid_music_ext = {
	["mp3"] = true,
	["ogg"] = true,
	["wav"] = true,
	["flac"] = true
}

function music.loadStageMusicInDir(stageid, name)
	local loaded = 0
	local files = love.filesystem.getDirectoryItems(name)
	for k, file in ipairs(files) do
		local filepath = ("%s/%s"):format(name, file)
		local info = love.filesystem.getInfo(filepath)
		local ext = string.getFileExtension(file)
		if info.type == "file" and valid_music_ext[ext:lower()] and not STAGE_TRACKS_LOADED[stageid][file] then
			local success, source = pcall(love.audio.newSource, filepath, "stream")
			if success and source then
				loaded = loaded + 1
				STAGE_TRACKS_LOADED[stageid][file] = true

				-- Insert the newly loaded track into a random position in the playlist
				local pos = math.random(1, #STAGE_TRACKS[stageid])
				table.insert(STAGE_TRACKS[stageid], pos, source)
			else
				local err = ("invalid music file \"%s/%s\""):format(name, file)
				log.error("[MUSIC] %s", err)
				notification.error(err)
			end
		end
	end
	if loaded > 0 then
		log.debug("[MUSIC] Loaded %d songs in %q", loaded, name)
	end
end

function music.loadForStage(stageid)
	if STAGE_ID ~= stageid then
		music.kill()
	end

	if not memory.isMelee() or not PANEL_SETTINGS:PlayStageMusic() then return end

	STAGE_ID = stageid
	STAGE_TRACKS[stageid] = STAGE_TRACKS[stageid] or {}
	STAGE_TRACKS_LOADED[stageid] = STAGE_TRACKS_LOADED[stageid] or {}

	music.loadStageMusicInDir(stageid, "Melee")

	if stageid == 0x0 then
		music.loadStageMusicInDir(stageid, "Melee/Menu Music")
		return
	elseif melee.isBTTStage(stageid) then
		music.loadStageMusicInDir(stageid, "Melee/Single Player Music/Break the Targets")
		return
	end

	local name = melee.getStageName(stageid)
	local series = melee.getStageSeries(stageid)
	local sp = melee.isSinglePlayerStage(stageid)

	if not name then STAGE_ID = nil return end

	if sp then
		music.loadStageMusicInDir(stageid, ("Melee/Single Player Music/%s"):format(name)) -- Load everything in the stages folder
		music.loadStageMusicInDir(stageid, "Melee/Single Player Music") -- Load everything that's not in a stage folder as well
	else
		music.loadStageMusicInDir(stageid, ("Melee/Stage Music/%s"):format(name)) -- Load everything in the stages folder
		music.loadStageMusicInDir(stageid, "Melee/Stage Music") -- Load everything in the stage folder
	end

	if series then
		music.loadStageMusicInDir(stageid, ("Melee/Series Music/%s"):format(series)) -- Load everything in the series folder
		music.loadStageMusicInDir(stageid, "Melee/Series Music") -- Load everything that's not in a stage folder as well
	end
end

return music