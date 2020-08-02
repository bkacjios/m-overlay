local music = {}

local log = require("log")
local melee = require("melee")
local memory = require("memory")
local notification = require("notification")

local MENU_CSS = 0
local MENU_STAGE_SELECT = 1
local MENU_INGAME = 2
local MENU_POSTGAME_SCORES = 4

local STAGE_TRACKS_LOADED = {}
local STAGE_TRACKS = {}
local TRACK_NUMBER = {}
local STAGE_ID = 0
local PLAYING_SONG = nil

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
	end

	for stageid, name in pairs(melee.getAllStages()) do
		love.filesystem.createDirectory(("Melee/Stage Music/%s"):format(name))
	end
	love.filesystem.createDirectory("Melee/Stage Music/All")

	for stageid, series in pairs(melee.getAllStageSeries()) do
		love.filesystem.createDirectory(("Melee/Series Music/%s"):format(series))
	end
	love.filesystem.createDirectory("Melee/Series Music/All")
end


function music.kill()
	if PLAYING_SONG and PLAYING_SONG:isPlaying() then
		PLAYING_SONG:stop()
	end
end

function music.onLoopChange(on)
	if PLAYING_SONG and PLAYING_SONG:isPlaying() then
		PLAYING_SONG:setLooping(on)
	end
end

function music.setVolume(vol)
	if PLAYING_SONG and PLAYING_SONG:isPlaying() then
		PLAYING_SONG:setVolume(vol/100)
	end
end

function music.playNextTrack()
	if not memory.isMelee() or not PANEL_SETTINGS:PlayStageMusic() then return end
	if PLAYING_SONG ~= nil and PLAYING_SONG:isPlaying() then return end
	if not STAGE_ID or not STAGE_TRACKS[STAGE_ID] then return end

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
			if STAGE_ID ~= 0 then
				PLAYING_SONG:setLooping(PANEL_SETTINGS:LoopStageMusic())
			end
			PLAYING_SONG:setVolume(PANEL_SETTINGS:GetVolume()/100)
			PLAYING_SONG:play()
		end
	end
end

function music.onStateChange()
	if memory.menu == MENU_INGAME then
		music.loadForStage(memory.stage)
		music.playNextTrack()
	elseif memory.menu == MENU_CSS or memory.menu == MENU_STAGE_SELECT then
		music.loadForStage(0)
		music.playNextTrack()
	end
end

memory.hook("OnGameClosed", "Dolphin - Game closed", function()
	music.kill()
end)

memory.hook("menu", "Melee - Menu state", function(menu)
	if menu == MENU_CSS or menu == MENU_STAGE_SELECT then
		music.loadForStage(0)
		music.playNextTrack()
	elseif menu == MENU_INGAME then
		music.loadForStage(memory.stage)
		music.playNextTrack()
	else
		music.kill()
	end
end)

memory.hook("stage", "Melee - Stage loaded", function(stage)
	if memory.menu == MENU_INGAME then
		music.loadForStage(stage)
		music.playNextTrack()
	end
end)

memory.hook("match.playing", "Melee - Match ended", function(playing)
	if not playing then
		music.kill()
	end
end)

memory.hook("controller.*.buttons.pressed", "Melee - Music skipper", function(port, pressed)
	if PANEL_SETTINGS:IsBinding() then return end -- Don't skip when the user is setting a button combination..
	local mask = PANEL_SETTINGS:GetMusicSkipMask()
	if mask ~= 0x0 and port == love.getPort() and bit.band(pressed, mask) == mask and STAGE_TRACKS[STAGE_ID] and #STAGE_TRACKS[STAGE_ID] > 1 then
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
			if success then
				loaded = loaded + 1
				STAGE_TRACKS_LOADED[stageid][file] = true

				-- Insert the newly loaded track into a random position in the playlist
				table.insert(STAGE_TRACKS[stageid], math.random(1, #STAGE_TRACKS[stageid]), source)
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

	if stageid == 0x0 then
		music.loadStageMusicInDir(stageid, "Melee/Menu Music")
		music.loadStageMusicInDir(stageid, "Melee/All Music")
		music.loadStageMusicInDir(stageid, "Melee")
		return
	end

	local name = melee.getStageName(stageid)
	local series = melee.getStageSeries(stageid)

	if not name then STAGE_ID = nil return end

	music.loadStageMusicInDir(stageid, ("Melee/Stage Music/%s"):format(name)) -- Load everything in the stages folder
	music.loadStageMusicInDir(stageid, "Melee/Stage Music/All") -- Load everything in the 'All' folder
	music.loadStageMusicInDir(stageid, "Melee/Stage Music") -- Load everything in the stage folder
	if series then
		music.loadStageMusicInDir(stageid, ("Melee/Series Music/%s"):format(series)) -- Load everything in the series folder
		music.loadStageMusicInDir(stageid, "Melee/Series Music/All") -- Load everything in the 'All' folder
		music.loadStageMusicInDir(stageid, "Melee/Series Music") -- Load everything in the series folder
	end
end

return music