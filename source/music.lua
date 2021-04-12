local music = {}

local log = require("log")
local melee = require("melee")
local memory = require("memory")
local notification = require("notification")
local wav = require("wav")

require("extensions.math")

local STAGE_TRACKS_LOADED = {}
local STAGE_TRACKS = {}
local STAGE_ID = 0
local PLAYING_SONG = nil
local SOURCE_SONG_LOOPS = {}
local SONG_FINISHED_PLAYING = true
local SONG_SHOULD_LOOP = false

-- Given a list of {element, weight} pairs, do a weighted random sample
-- of the elements (returns an index, not the element itself)
local function weightedRandomChoice(list)
	if not list or #list == 0 then return nil end
	if #list == 1 then return 1 end
	local weight_sum = 0
	for idx=1,#list do
		weight_sum = weight_sum + list[idx].weight
	end
	local choice = math.random(1, weight_sum)
	for idx=1,#list do
		choice = choice - list[idx].weight
		if choice <= 0 then
			return idx
		end
	end
	return choice_idx
end

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

function music.update()
	if not PLAYING_SONG or SONG_FINISHED_PLAYING then return end

	local duration = PLAYING_SONG:getDuration("samples")
	local position = PLAYING_SONG:tell("samples")

	if SONG_SHOULD_LOOP then
		local finished = not PLAYING_SONG:isPlaying()

		if finished then
			-- If the song is no longer playing, that means it reached the end
			-- Immediately play it again
			log.debug("[MUSIC] End of song reached, replaying")
			PLAYING_SONG:play()
		end

		local info = SOURCE_SONG_LOOPS[PLAYING_SONG]

		if info then
			for k, loop in pairs(info.loops) do
				if finished or position >= loop.sample_end then
					log.debug("[MUSIC] Loop point reached, seeking to %d", loop.sample_start)
					-- If the song finished playing or reached the looping point, loop back to the start?
					PLAYING_SONG:seek(loop.sample_start, "samples")
					break -- Only handle the first loop for now..
				end
			end
		end
	else
		if not PLAYING_SONG:isPlaying() or position >= duration then
			-- We mark that the song has completed, allowing the next game frame hook to play the next song in the playlist
			SONG_FINISHED_PLAYING = true
		end
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

	for stageid, name in pairs(melee.getAkaneiaStages()) do
		love.filesystem.createDirectory(("Melee/Akaneia Stage Music/%s"):format(name))
	end
end

function music.kill()
	if PLAYING_SONG and PLAYING_SONG:isPlaying() then
		PLAYING_SONG:stop()
		SONG_FINISHED_PLAYING = true
	end
end

local LOOPING_OFF = 1
local LOOPING_MENU = 2
local LOOPING_STAGE = 3
local LOOPING_ALL = 4

-- Set to true when the announcer says 'GAME!'
local MATCH_SOFT_END = false

function music.shouldPlayMusic()
	return melee.isInMenus() or (melee.isInGame() and not melee.matchFinsihed() and not MATCH_SOFT_END)
end

function music.onLoopChange(mode)
	if PLAYING_SONG and PLAYING_SONG:isPlaying() then
		local loop = false
		-- Handle the different loop settings properly
		if mode == LOOPING_MENU and melee.isInMenus() then
			loop = true
		elseif mode == LOOPING_STAGE and melee.isInGame() then
			loop = true
		elseif mode == LOOPING_ALL then
			loop = true
		end
		--PLAYING_SONG:setLooping(loop)
		SONG_SHOULD_LOOP = loop
	end
end

function music.getVolume()
	return PANEL_SETTINGS:GetVolume()
end

local LOADED = false
local IGNORE_CHANGE = false

local ALLOW_INGAME_VOLUME = false

memory.hook("OnGameClosed", "Set state unloaded", function()
	LOADED = false
end)

memory.hook("menu.major", "Load Initial Volume", function(menu)
	if memory.isMelee() and ALLOW_INGAME_VOLUME and not LOADED and menu == MENU_MAIN_MENU then
		LOADED = true
		-- Set the games music value to our value
		music.setVolume(music.getVolume())
	end
end)

memory.hook("volume.slider", "Ingame Volume Adjust", function(volume)
	if memory.isMelee() and ALLOW_INGAME_VOLUME and LOADED then
		PANEL_SETTINGS:SetVolume(100-volume)
	end
end)

function music.setVolume(vol)
	if ALLOW_INGAME_VOLUME and memory.isMelee() then
		-- Melee's slider goes in increments of 5
		-- It seems to add +5 or -5 no matter what, but it can actually take numbers in between and still work
		--local nearest5 = math.round((100-vol) / 5)*5

		-- volume.slider adjust (0-100)
		memory.writeByte(0x8045C384, math.round(100-vol))

		-- volume.music adjust (0-127)
		memory.writeByte(0x804D3887, (vol/100) * 127)
	end

	if PLAYING_SONG and PLAYING_SONG:isPlaying() then
		PLAYING_SONG:setVolume((vol/100) * (memory.match.paused and 0.35 or 1))
	end
end

function music.playNextTrack()
	if not memory.isMelee() or not PANEL_SETTINGS:PlayStageMusic() then return end
	if PLAYING_SONG ~= nil and not SONG_FINISHED_PLAYING then return end
	if not STAGE_ID or not STAGE_TRACKS[STAGE_ID] then return end
	if not music.shouldPlayMusic() then return end

	local songs = STAGE_TRACKS[STAGE_ID]

	if songs and #songs > 0 then
		local track = weightedRandomChoice(songs)
		if not track or not songs[track] then return end

		PLAYING_SONG = songs[track].source

		if PLAYING_SONG then
			if STAGE_ID == 0x0 then
				log.info("[MUSIC] Playing track #%d for menu", track)
			else
				log.info("[MUSIC] Playing track #%d for stage %q", track, melee.getStageName(STAGE_ID))
			end

			local loop = PANEL_SETTINGS:GetMusicLoopMode()

			if STAGE_ID == 0 then
				SONG_SHOULD_LOOP = loop == LOOPING_MENU or loop == LOOPING_ALL
				--PLAYING_SONG:setLooping(loop == LOOPING_MENU or loop == LOOPING_ALL)
			else
				SONG_SHOULD_LOOP = loop == LOOPING_STAGE or loop == LOOPING_ALL
				--PLAYING_SONG:setLooping(loop == LOOPING_STAGE or loop == LOOPING_ALL)
			end

			PLAYING_SONG:setVolume((PANEL_SETTINGS:GetVolume()/100) * (memory.match.paused and 0.35 or 1))
			PLAYING_SONG:play()
			SONG_FINISHED_PLAYING = false
		end
	end
end

function music.onStateChange()
	if melee.isInGame() then
		music.loadForStage(memory.stage)
	elseif melee.isInMenus() then
		music.loadForStage(0)
	end
end

memory.hook("frame", "Melee - Music Think", music.playNextTrack)

memory.hook("OnGameClosed", "Dolphin - Game closed", function()
	music.kill()
end)

memory.hook("menu.major", "Melee - Menu state", function(menu)
	if melee.isInMenus() then
		music.loadForStage(0)
	elseif not melee.isInGame() then
		music.kill()
	end
end)

memory.hook("menu.minor", "Melee - Menu state", function(menu)
	if melee.isInMenus() then
		music.loadForStage(0)
	elseif melee.isInGame() then
		MATCH_SOFT_END = false
		music.loadForStage(memory.stage)
	else
		music.kill()
	end
end)

memory.hook("stage", "Melee - Stage loaded", function(stage)
	if melee.isInGame() then
		music.loadForStage(stage)
	end
end)

memory.hook("match.playing", "Melee - Classic Mode Master Hand Fix?", function(playing)
	-- In classic mode, when you kill masterhand the match result is never set, but the "playing" flag is set to false.
	-- Mute the music right when masterhand is killed.
	if not playing and (memory.menu.major == MENU_CLASSIC_MODE and memory.stage == 0x25) then
		MATCH_SOFT_END = true
		music.kill()
	end
end)

memory.hook("match.paused", "Melee - Pause volume", function(paused)
	music.setVolume(music.getVolume())
end)

memory.hook("match.finished", "Melee - GAME kill music", function(finished)
	if finished then
		-- The match ended, so no matter what the music should be killed
		music.kill()
	end
end)

memory.hook("match.result", "Melee - GAME kill music", function(result)
	-- LRAB+Start/Saltyrunback causes a result of MATCH_NO_CONTEST.. We don't want to end the music in this case only.
	-- The match.finished hook will end the music instead when actually exiting the match using normal LRA+Start.
	-- If the match actually ends normally, we kill the music early when it announces the end of the game.

	if result ~= MATCH_NO_RESULT and (memory.menu.major ~= MENU_VS_MODE or (memory.menu.major == MENU_VS_MODE and result ~= MATCH_NO_CONTEST)) then
		MATCH_SOFT_END = true
		music.kill()
	end
end)

memory.hook("controller.*.buttons.pressed", "Melee - Music skipper", function(port, pressed)
	if PANEL_SETTINGS:IsBinding() or PANEL_SETTINGS:IsSlippiReplay() then return end -- Don't skip when the user is setting a button combination or when watching a replay
	local mask = PANEL_SETTINGS:GetMusicSkipMask()
	if mask ~= 0x0 and port == love.getPort() and bit.band(pressed, mask) == mask and #STAGE_TRACKS[STAGE_ID] > 1 then
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
		if info.type == "file" then
			local ext = string.getFileExtension(file):lower()

			if valid_music_ext[ext] and not STAGE_TRACKS_LOADED[stageid][file] then
				local success, source = pcall(love.audio.newSource, filepath, "stream")
				if success and source then
					loaded = loaded + 1
					STAGE_TRACKS_LOADED[stageid][file] = true

					-- Insert the newly loaded track into a random position in the playlist
					local pos = math.random(1, #STAGE_TRACKS[stageid])
					local prob = tonumber(string.match(filepath, "[^%._\n]+_(%d+)%.%w+$")) or 1

					table.insert(STAGE_TRACKS[stageid], pos, {source = source, weight = prob})

					if ext == "wav" then
						SOURCE_SONG_LOOPS[source] = wav.parse(filepath)
						log.debug("[MUSIC] Parsed %q for loop points: %d found", filepath, #SOURCE_SONG_LOOPS[source].loops)
					end
				else
					local err = ("invalid music file \"%s/%s\""):format(name, file)
					log.error("[MUSIC] %s", err)
					notification.error(err)
				end
			end
		end
	end
	if loaded > 0 then
		log.info("[MUSIC] Loaded %d songs in %q", loaded, name)
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
	local aka = melee.isAkaneiaStage(stageid)

	if not name then STAGE_ID = nil return end

	if sp then
		music.loadStageMusicInDir(stageid, ("Melee/Single Player Music/%s"):format(name)) -- Load everything in the stage specific folder
		music.loadStageMusicInDir(stageid, "Melee/Single Player Music") -- Load everything that's not in a stage folder as well
	elseif aka then
		music.loadStageMusicInDir(stageid, ("Melee/Akaneia Stage Music/%s"):format(name)) -- Load everything in the stage specific folder
		music.loadStageMusicInDir(stageid, "Melee/Akaneia Stage Music") -- Load everything in the akaneia folder
		music.loadStageMusicInDir(stageid, "Melee/Stage Music") -- Load everything in the stage folder
	else
		music.loadStageMusicInDir(stageid, ("Melee/Stage Music/%s"):format(name)) -- Load everything in the stage specific folder
		music.loadStageMusicInDir(stageid, "Melee/Stage Music") -- Load everything in the stage folder
	end

	if series then
		music.loadStageMusicInDir(stageid, ("Melee/Series Music/%s"):format(series)) -- Load everything in the series folder
		music.loadStageMusicInDir(stageid, "Melee/Series Music") -- Load everything that's not in a stage folder as well
	end
end

return music
