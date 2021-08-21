local music = {
	PLAYLIST = {},
	PLAYLIST_ID = -1,
	PLAYING = nil,
	FINISHED = true,
	LOOP = false,
	USE_WEIGHTS = false,
	TRACK_NUMBER = {},
	RNG_OFFSET = 0,
}

local log = require("log")
local melee = require("melee")
local memory = require("memory")
local notification = require("notification")
local overlay = require("overlay")
local wav = require("wav")
local bit = require("bit")

require("extensions.math")

-- Given a list of {element, weight} pairs, do a weighted random sample
-- of the elements (returns an index, not the element itself)
local function weightedRandomChoice(list)
	if not list or #list == 0 then return nil end
	if #list == 1 then return 1 end

	local sum = 0
	for i=1, #list do
		sum = sum + list[i].WEIGHT
	end

	local choice = math.random(1, sum)
	for idx=1,#list do
		choice = choice - list[idx].WEIGHT
		if choice <= 0 then
			return idx
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
end

function music.kill()
	if music.PLAYING and music.PLAYING.STREAM:isPlaying() then
		music.PLAYING.STREAM:stop()
		music.FINISHED = true
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
	if music.PLAYING and music.PLAYING.STREAM:isPlaying() then
		local loop = false
		-- Handle the different loop settings properly
		if mode == LOOPING_MENU and melee.isInMenus() then
			loop = true
		elseif mode == LOOPING_STAGE and melee.isInGame() then
			loop = true
		elseif mode == LOOPING_ALL then
			loop = true
		end
		--music.PLAYING.STREAM:setLooping(loop)
		music.LOOP = loop
	end
end

function music.getVolume()
	return PANEL_SETTINGS:GetVolume()
end

local LOADED = false
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

	if music.PLAYING and music.PLAYING.STREAM:isPlaying() then
		music.PLAYING.STREAM:setVolume((vol/100) * (memory.match.paused and 0.35 or 1))
	end
end

function music.playNextTrack()
	if not memory.isMelee() or not PANEL_SETTINGS:PlayStageMusic() then return end
	if music.PLAYING ~= nil and not music.FINISHED then return end
	if not music.PLAYLIST_ID then return end
	if not music.shouldPlayMusic() then return end

	local songs = music.PLAYLIST

	if #music.PLAYLIST > 0 then
		local track

		if music.USE_WEIGHTS then
			track = weightedRandomChoice(songs)
			if not track or not songs[track] then return end
			music.PLAYING = songs[track]
		else
			music.TRACK_NUMBER[music.PLAYLIST_ID] = ((music.TRACK_NUMBER[music.PLAYLIST_ID] or -1) + 1) % #songs
			track = music.TRACK_NUMBER[music.PLAYLIST_ID] + 1
			music.PLAYING = songs[track]

			-- Every time we play a song, we randomly place it towards the start of the playlist
			local newpos = math.random(1, track)

			table.remove(songs, track)
			table.insert(songs, newpos, music.PLAYING)
		end
		
		if music.PLAYING then
			if music.PLAYLIST_ID == 0x0 then
				log.info("[MUSIC] Playing track #%d for menu", track)
			else
				log.info("[MUSIC] Playing track #%d for stage %q", track, melee.getStageName(music.PLAYLIST_ID))
			end

			local loop = PANEL_SETTINGS:GetMusicLoopMode()

			if music.PLAYLIST_ID == 0 then
				music.LOOP = loop == LOOPING_MENU or loop == LOOPING_ALL
			else
				music.LOOP = loop == LOOPING_STAGE or loop == LOOPING_ALL
			end

			music.PLAYING.STREAM:setVolume((PANEL_SETTINGS:GetVolume()/100) * (memory.match.paused and 0.35 or 1))
			music.PLAYING.STREAM:play()
			music.FINISHED = false
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
	if mask ~= 0x0 and port == overlay.getPort() and pressed == mask and #music.PLAYLIST > 1 then
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
	table.sort(files) -- Sort our list of files alphabetically, giving our table a deterministic state
	for k, file in ipairs(files) do
		local filepath = ("%s/%s"):format(name, file)
		local info = love.filesystem.getInfo(filepath)
		if info then
			if info.type == "file" then
				local ext = string.getFileExtension(file):lower()

				if valid_music_ext[ext] then
					local success, source = pcall(love.audio.newSource, filepath, "stream")
					if success and source then
						loaded = loaded + 1

						-- Insert the newly loaded track into a random position in the playlist
						local pos = math.random(1, #music.PLAYLIST)
						local prob = tonumber(string.match(filepath, "[^%._\n]+_(%d+)%.%w+$")) or 1

						if prob > 1 then
							music.USE_WEIGHTS = true
						end

						local wavinfo
						if ext == "wav" then
							wavinfo = wav.parse(filepath)
						end
						table.insert(music.PLAYLIST, pos, {STREAM = source, WEIGHT = prob, WAV = wavinfo})
					else
						local err = ("invalid music file \"%s/%s\""):format(name, file)
						log.error("[MUSIC] %s", err)
						notification.error(err)
					end
				end
			end
		else
			log.warn("[MUSIC] Unable to get file information for file %q", filepath)
		end
	end
	if loaded > 0 then
		log.info("[MUSIC] Loaded %d songs in %q", loaded, name)
	end
end

function music.setRngOffset(seed)
	music.RNG_OFFSET = seed
	math.randomseed(seed)

	local values = {}
	for i=1,8 do
		table.insert(values, math.random(1, 255))
	end
	local data = string.char(unpack(values))

	log.debug("[RANDOM] Flushing random of initial values (0x%s)", string.tohex(data))
end

function music.loadForStage(stageid)
	if music.PLAYLIST_ID == stageid then return end

	music.kill()
	if not memory.isMelee() or not PANEL_SETTINGS:PlayStageMusic() then return end

	local seed
	if stageid == 0x0 then
		seed = music.RNG_OFFSET
		if seed == 0 then
			seed = os.time()
		else
			-- Advance the seed in a deterministic but unpredictable way using xor
			seed = bit.bxor(seed, 397)
		end
	else
		seed = memory.online.rng_offset
		if seed == 0 then seed = os.time() end
	end
	music.setRngOffset(seed)

	music.PLAYLIST_ID = stageid

	for k,v in pairs(music.PLAYLIST) do
		v.STREAM:release()
	end

	music.PLAYING = nil
	music.PLAYLIST = {}
	music.USE_WEIGHTS = false

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
	local bm = melee.isBeyondMeleeStage(stageid)

	if not name then music.PLAYLIST_ID = nil return end

	if sp then
		music.loadStageMusicInDir(stageid, ("Melee/Single Player Music/%s"):format(name)) -- Load everything in the stage specific folder
		music.loadStageMusicInDir(stageid, "Melee/Single Player Music") -- Load everything that's not in a stage folder as well
	elseif aka then
		music.loadStageMusicInDir(stageid, ("Melee/Akaneia Stage Music/%s"):format(name)) -- Load everything in the stage specific folder
		music.loadStageMusicInDir(stageid, "Melee/Akaneia Stage Music") -- Load everything in the akaneia folder
		music.loadStageMusicInDir(stageid, "Melee/Stage Music") -- Load everything in the stage folder
	elseif bm then
		music.loadStageMusicInDir(stageid, ("Melee/Beyond Melee Stage Music/%s"):format(name)) -- Load everything in the stage specific folder
		music.loadStageMusicInDir(stageid, "Melee/Beyond Melee Stage Music") -- Load everything in the akaneia folder
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
