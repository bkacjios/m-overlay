local music = {
	PLAYLIST = {},
	SONGS = {},
	PLAYLIST_ID = -1,
	PLAYING = nil,
	FINISHED = true,
	LOOP = false,
	TRACK_ID = {},
	RNG_SEED = nil,
	PROBABILITY_FILE = "probability.json",
	PROBABILITY_SETTINGS = {
		global = {},
		states = {},
	},
	MUTED = false
}

local MUTED_TEXTURE = love.graphics.newImage("textures/gui/muted.png")

local log = require("log")
local melee = require("melee")
local memory = require("memory")
local notification = require("notification")
local overlay = require("overlay")
local wav = require("wav")
local json = require("serializer.json")
local fs = require("util.filesystem")

require("extensions.math")

-- Given a list of {element, weight} pairs, do a weighted random sample
-- of the elements (returns an index, not the element itself)
local function weightedRandomChoice(list)
	if not list or #list == 0 then return nil end
	if #list == 1 then return 1 end

	local sum = 0
	for _, weight in pairs(list) do
		sum = sum + weight
	end

	if sum <= 0 then return nil end

	local choice = math.random(1, sum)
	for k, weight in pairs(list) do
		choice = choice - weight
		if choice <= 0 then
			return k
		end
	end
	return choice
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
	if not music.PLAYING or music.FINISHED then return end

	local duration = music.PLAYING.STREAM:getDuration("samples")
	local position = music.PLAYING.STREAM:tell("samples")

	if music.LOOP then
		local finished = not music.PLAYING.STREAM:isPlaying()

		if finished then
			-- If the song is no longer playing, that means it reached the end
			-- Immediately play it again
			log.debug("[MUSIC] End of song reached, replaying")
			music.PLAYING.STREAM:play()
		end

		local info = music.PLAYING.WAV

		if info then
			for k, loop in pairs(info.loops) do
				if finished or position >= loop.sample_end then
					log.debug("[MUSIC] Loop point reached, seeking to %d", loop.sample_start)
					-- If the song finished playing or reached the looping point, loop back to the start?
					music.PLAYING.STREAM:seek(loop.sample_start, "samples")
					break -- Only handle the first loop for now..
				end
			end
		end
	else
		if not music.PLAYING.STREAM:isPlaying() or position >= duration then
			-- We mark that the song has completed, allowing the next game frame hook to play the next song in the playlist
			music.FINISHED = true
		end
	end
end

function music.init()
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
	for stageid, name in pairs(melee.getBeyondMeleeStages()) do
		love.filesystem.createDirectory(("Melee/Beyond Melee Stage Music/%s"):format(name))
	end

	music.loadProbablitities()
end

function music.kill()
	if music.PLAYING then
		if music.PLAYING.STREAM then
			if music.PLAYING.STREAM:isPlaying() then
				music.PLAYING.STREAM:stop()
				music.FINISHED = true
			end
			music.PLAYING.STREAM:release()
		end
		music.PLAYING = nil
	end
end

-- Set to true when the announcer says 'GAME!'
local MATCH_SOFT_END = false

function music.shouldPlayMusic()
	return melee.isInMenus() or (melee.isInGame() and not melee.matchFinsihed() and not MATCH_SOFT_END)
end

function music.onLoopChange(mode)
	if music.PLAYING and music.PLAYING.STREAM:isPlaying() then
		music.LOOP = music.shouldLoop()
	end
end

function music.getVolume()
	return PANEL_SETTINGS:GetVolume()
end

function music.getPlaylist()
	local playlist = table.copy(music.PLAYLIST)
	table.sort(playlist, function(a, b)
		return a.FILEPATH < b.FILEPATH
	end)
	return playlist
end

function music.getPlaylistTree()
	local playlist = music.getPlaylist()
	local tree = {}
	for k, entry in ipairs(playlist) do
		local directory = string.getFilePath(entry.FILEPATH)
		if not tree[directory] then tree[directory] = {} end
		table.insert(tree[directory], entry)
	end
	return tree
end

local LOADED = false
local ALLOW_INGAME_VOLUME = false

memory.hook("OnGameClosed", "Set state unloaded", function()
	LOADED = false
end)

memory.hook("scene.major", "Load Initial Volume", function(menu)
	if memory.isMelee() and ALLOW_INGAME_VOLUME and not LOADED and menu == SCENE_MAIN_MENU then
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

function music.refreshRNGseed()
	local getSeed = function()
		if not music.RNG_SEED or not memory.isMelee() then return os.time(), "the system time" end
		if melee.isInMenus() then return music.RNG_SEED + 1, "the previous seed" end
		if melee.isNetplayGame() then return memory.online.rng_offset, "Slippi" end
		return memory.rng.seed, "Melee"
	end

	local seed, source = getSeed()
	math.randomseed(seed)
	music.RNG_SEED = seed
	log.debug("[RANDOM] Obtained seed \"0x%X\" from %s", seed, source)
end

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

	if music.PLAYING then
		if music.MUTED then
			vol = 0
		end
		music.PLAYING.STREAM:setVolume((vol/100) * (melee.isPaused() and 0.35 or 1))
	end
end

do
	local LOOPING_NONE = 0
	local LOOPING_MENU = 1
	local LOOPING_STAGE_TIMED = 2
	local LOOPING_STAGE_ENDLESS = 4
	function music.shouldLoop()
		local loop = PANEL_SETTINGS:GetMusicLoopMode()

		if music.PLAYLIST_ID == 0 then
			return bit.band(loop, LOOPING_MENU) == LOOPING_MENU
		elseif melee.isCountdownTimer() then
			return bit.band(loop, LOOPING_STAGE_TIMED) == LOOPING_STAGE_TIMED
		else
			return bit.band(loop, LOOPING_STAGE_ENDLESS) == LOOPING_STAGE_ENDLESS
		end

		return false
	end
end

do
local function getWeightTable(songs)
	local tbl = {}
	local useWeights = false
	local firstValue
	for k, song in pairs(songs) do
		tbl[k] = music.getFileProbability(song.FILEPATH)
		if not firstValue then
			firstValue = tbl[k]
		elseif firstValue ~= tbl[k] then
			useWeights = true
		end
	end
	return tbl, useWeights
end

local function getNextTrack(songs)
	local weightTable, useWeights = getWeightTable(songs)

	if useWeights then
		local track_id = weightedRandomChoice(getWeightTable(songs))
		return track_id, track_id
	end

	music.TRACK_ID[music.PLAYLIST_ID] = ((music.TRACK_ID[music.PLAYLIST_ID] or -1) + 1) % #songs
	local track_id = music.TRACK_ID[music.PLAYLIST_ID] + 1

	-- Only shuffle if we have more than 2 songs..
	if #songs > 2 then
		-- Every time we play a song, we randomly place it towards the start of the playlist
		-- This keeps the playlist in a constantly shuffled order
		local track = table.remove(songs, track_id)
		local newpos = math.random(1, track_id)
		table.insert(songs, newpos, track)
		return track_id, newpos
	end

	return track_id, track_id
end

local function loadTrack(songs, index)
	local track_info = songs[index]

	local filepath = track_info.FILEPATH

	local success, source = pcall(love.audio.newSource, filepath, "stream")
	if not (success and source) then
		log.error("[MUSIC] invalid music file %q", filepath)
		notification.error("invalid music file %q", filepath)
		table.remove(songs, index)
		return nil
	end

	return { STREAM = source, WAV = track_info.IS_WAV and wav.parse(filepath) or nil }
end

function music.playNextTrack()
	if not memory.isMelee() or not PANEL_SETTINGS:PlayStageMusic() then return end
	if music.PLAYING ~= nil and not music.FINISHED then return end
	if not music.PLAYLIST_ID then return end
	if not music.shouldPlayMusic() then return end

	local songs = music.PLAYLIST

	if #songs > 0 then
		local track_id, track_index = getNextTrack(songs)

		if not track_index then return end

		music.PLAYING = loadTrack(songs, track_index)
		
		if music.PLAYING then
			if music.PLAYLIST_ID == 0x0 then
				log.info("[MUSIC] Playing track #%d for menu", track_id)
			else
				log.info("[MUSIC] Playing track #%d for stage %q", track_id, melee.getStageName(music.PLAYLIST_ID))
			end
			music.setVolume(PANEL_SETTINGS:GetVolume())
			music.LOOP = music.shouldLoop()
			music.PLAYING.STREAM:play()
			music.FINISHED = false
		end
	end
end
end

function music.onStateChange()
	if melee.isInGame() then
		music.loadForStage(memory.stage.id)
	elseif melee.isInMenus() then
		music.loadForStage(0)
	end
end

function music.draw()
	if music.MUTED then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.easyDraw(MUTED_TEXTURE, 256 - 16, 256 - 68, 0, 32, 32)
	end
end

memory.hook("frame", "Melee - Music Think", music.playNextTrack)

memory.hook("OnGameClosed", "Dolphin - Game closed", function()
	music.kill()
end)

memory.hook("scene.major", "Melee - Menu state", function(menu)
	if melee.isInMenus() then
		music.loadForStage(0)
	elseif not melee.isInGame() then
		music.kill()
	end
end)

memory.hook("scene.minor", "Melee - Menu state", function(menu)
	if melee.isInMenus() then
		music.loadForStage(0)
	elseif melee.isInGame() then
		MATCH_SOFT_END = false
		music.loadForStage(memory.stage.id)
	else
		music.kill()
	end
end)

memory.hook("stage.id", "Melee - Stage loaded", function(stage)
	if melee.isInGame() then
		music.loadForStage(stage)
	end
end)

memory.hook("match.info.playing", "Melee - Classic Mode Master Hand Fix?", function(playing)
	-- In classic mode, when you kill masterhand the match result is never set, but the "playing" flag is set to false.
	-- Mute the music right when masterhand is killed.
	if not playing and (memory.scene.major == SCENE_CLASSIC_MODE and memory.stage.id == 0x25) then
		MATCH_SOFT_END = true
		music.kill()
	end
end)

memory.hook("match.info.paused", "Melee - Pause volume", function(paused)
	music.setVolume(music.getVolume())
end)

memory.hook("match.info.finished", "Melee - GAME kill music", function(finished)
	if finished then
		-- The match ended, so no matter what the music should be killed
		music.kill()
	end
end)

memory.hook("match.info.result", "Melee - GAME kill music", function(result)
	-- LRAB+Start/Saltyrunback causes a result of MATCH_NO_CONTEST.. We don't want to end the music in this case only.
	-- The match.finished hook will end the music instead when actually exiting the match using normal LRA+Start.
	-- If the match actually ends normally, we kill the music early when it announces the end of the game.

	if result ~= MATCH_NO_RESULT and (memory.scene.major ~= SCENE_VS_MODE or (memory.scene.major == SCENE_VS_MODE and result ~= MATCH_NO_CONTEST)) then
		MATCH_SOFT_END = true
		music.kill()
	end
end)

memory.hook("controller.*.buttons.pressed", "Melee - Music skipper", function(port, pressed)
	if PANEL_SETTINGS:IsBinding() or PANEL_SETTINGS:IsSlippiReplay() then return end -- Don't skip when the user is setting a button combination or when watching a replay
	local skipMask = PANEL_SETTINGS:GetMusicSkipMask()
	local muteMask = PANEL_SETTINGS:GetMusicMuteMask()
	if port == overlay.getPort() then
		if pressed == skipMask and #music.PLAYLIST > 1 then
			log.debug("[MUSIC] [MASK = 0x%X] Skip combo pressed, stopping music.", skipMask)
			music.kill()
		end
		if pressed == muteMask then
			music.MUTED = not music.MUTED
			music.setVolume(music.getVolume())
			log.debug("[MUSIC] [MASK = 0x%X] Mute combo pressed, %s music.", skipMask, music.MUTED and "muting" or "unmuting")
		end
	end
end)

local valid_music_ext = {
	["mp3"] = true,
	["ogg"] = true,
	["wav"] = true,
	["flac"] = true
}

function music.isValidMusicExt(ext)
	return valid_music_ext[ext]
end

function music.loadPlaylistForStage(stageid, name)
	local found = 0
	local files = love.filesystem.getDirectoryItems(name)
	table.sort(files) -- Sort our list of files alphabetically, giving our table a deterministic state
	for k, file in ipairs(files) do
		local filepath = ("%s/%s"):format(name, file)
		local info = love.filesystem.getInfo(filepath)
		if info then
			if info.type == "file" then
				local ext = string.getFileExtension(file):lower()

				if music.isValidMusicExt(ext) then
					found = found + 1

					-- Insert the newly found track into a random position in the playlist
					local pos = math.random(1, #music.PLAYLIST)
					local prob = music.PROBABILITY_SETTINGS["global"][filepath] or tonumber(string.match(filepath, ".-_(%d+)%.%w+$")) or 100

					if prob > 100 then
						log.warn("[MUSIC] Song %q has a probability greater than 100%%", filepath)
					end

					music.PROBABILITY_SETTINGS["global"][filepath] = prob

					table.insert(music.PLAYLIST, pos, {FILEPATH = filepath, FILENAME = file, WEIGHT = prob, IS_WAV = ext == "wav"})
				end
			end
		else
			log.warn("[MUSIC] Unable to get file information for file %q", filepath)
		end
	end
	if found > 0 then
		log.info("[MUSIC] Found %d songs in %q", found, name)
	end
end

function music.loadProbablitities()
	music.PROBABILITY_SETTINGS = {
		global = {},
		states = {},
	}

	local probFile = music.PROBABILITY_FILE

	local f = love.filesystem.newFile(probFile, "r")
	if f then
		local settings = music.PROBABILITY_SETTINGS
		local success, decoded = pcall(json.decode, f:read())
		f:close()
		if not success then
			-- If we failed decoding, decoded is an error string.
			-- Get the last bit of text after the file name and line number.
			-- Error format: "filename.lua:1: (OUR ERROR STRING HERE)"
			local err = string.match(decoded, "^.*:%s*(.*)$") or decoded
			log.error("[MUSIC] Failed parsing %s: ('%s')", probFile, err)
			notification.error("Failed parsing %s: ('%s')", probFile, err)
		elseif decoded.global and decoded.states then
			if decoded.global then
				for file, prob in pairs(decoded.global) do
					settings["global"][file] = prob
				end
			end
			if decoded.states then
				for stateid, files in pairs(decoded.states) do
					stateid = tonumber(stateid)
					settings["states"][stateid] = files
				end
			end
		else
			-- OLD SAVE FORMAT
			for file, prob in pairs(decoded) do
				settings["global"][file] = prob
			end
		end
	end
end

function music.updateGlobalProbabilities(tbl)
	local settings = music.PROBABILITY_SETTINGS

	for file, prob in pairs(tbl) do
		settings["global"][file] = prob
	end
end

function music.updateStateProbabilities(tbl)
	local state = music.PLAYLIST_ID
	local settings = music.PROBABILITY_SETTINGS

	for file, prob in pairs(tbl) do
		if not settings["states"][state] then settings["states"][state] = {} end
		settings["states"][state][file] = prob
	end
end

function music.getFileProbability(file)
	local stateP = music.getStateFileProbability(file)

	if stateP < 100 then
		return stateP
	end

	return music.getGlobalFileProbability(file)
end

function music.getGlobalFileProbability(file)
	local settings = music.PROBABILITY_SETTINGS
	if settings["global"] and settings["global"][file] then
		return settings["global"][file]
	end
	return 100 -- Default to 100% chance
end

function music.getStateFileProbability(file)
	local state = music.PLAYLIST_ID
	local settings = music.PROBABILITY_SETTINGS
	if settings["states"] and settings["states"][state] and settings["states"][state][file] then
		return settings["states"][state][file]
	end
	return 100 -- Default to 100% chance
end

function music.getProbabilitySaveTable()
	local tbl = {
		global = {},
		states = {},
	}

	-- Only get files that have a custom prob. set
	for file, prob in pairs(music.PROBABILITY_SETTINGS["global"]) do
		if prob < 100 then
			tbl["global"][file] = prob
		end
	end
	for stateid, files in pairs(music.PROBABILITY_SETTINGS["states"]) do
		stateid = tostring(stateid) -- JSON objects can only use strings as keys
		for file, prob in pairs(files) do
			if prob < 100 then
				if not tbl["states"][stateid] then tbl["states"][stateid] = {} end
				tbl["states"][stateid][file] = prob
			end
		end
	end
	return tbl
end

function music.saveProbabilities()
	local probFile = music.PROBABILITY_FILE

	local f, err = love.filesystem.newFile(probFile, "w")
	if f then
		log.warn("Writing to %s", probFile)
		notification.warning("Writing to %s", probFile)
		f:write(json.encode(music.getProbabilitySaveTable(), true))
		f:flush()
	else
		log.error("Failed writing to %s: %s", probFile, err)
		notification.error("Failed writing to %s: %s", probFile, err)
	end
end

function music.loadForStage(stageid)
	if music.PLAYLIST_ID == stageid then return end

	music.kill()
	if not memory.isMelee() or not PANEL_SETTINGS:PlayStageMusic() then return end

	music.PLAYLIST_ID = stageid
	music.PLAYLIST = {}

	music.refreshRNGseed()

	music.loadPlaylistForStage(stageid, "Melee")

	if stageid == 0x0 then
		music.loadPlaylistForStage(stageid, "Melee/Menu Music")
		return
	elseif melee.isBTTStage(stageid) then
		music.loadPlaylistForStage(stageid, "Melee/Single Player Music/Break the Targets")
		return
	end

	local name = melee.getStageName(stageid)
	local series = melee.getStageSeries(stageid)
	local sp = melee.isSinglePlayerStage(stageid)
	local aka = melee.isAkaneiaStage(stageid)
	local bm = melee.isBeyondMeleeStage(stageid)

	if not name then music.PLAYLIST_ID = nil return end

	if sp then
		music.loadPlaylistForStage(stageid, ("Melee/Single Player Music/%s"):format(name)) -- Load everything in the stage specific folder
		music.loadPlaylistForStage(stageid, "Melee/Single Player Music") -- Load everything that's not in a stage folder as well
	elseif aka then
		music.loadPlaylistForStage(stageid, ("Melee/Akaneia Stage Music/%s"):format(name)) -- Load everything in the stage specific folder
		music.loadPlaylistForStage(stageid, "Melee/Akaneia Stage Music") -- Load everything in the akaneia folder
		music.loadPlaylistForStage(stageid, "Melee/Stage Music") -- Load everything in the stage folder
	elseif bm then
		music.loadPlaylistForStage(stageid, ("Melee/Beyond Melee Stage Music/%s"):format(name)) -- Load everything in the stage specific folder
		music.loadPlaylistForStage(stageid, "Melee/Beyond Melee Stage Music") -- Load everything in the akaneia folder
		music.loadPlaylistForStage(stageid, "Melee/Stage Music") -- Load everything in the stage folder
	else
		music.loadPlaylistForStage(stageid, ("Melee/Stage Music/%s"):format(name)) -- Load everything in the stage specific folder
		music.loadPlaylistForStage(stageid, "Melee/Stage Music") -- Load everything in the stage folder
	end

	if series then
		music.loadPlaylistForStage(stageid, ("Melee/Series Music/%s"):format(series)) -- Load everything in the series folder
		music.loadPlaylistForStage(stageid, "Melee/Series Music") -- Load everything that's not in a stage folder as well
	end
end

return music
