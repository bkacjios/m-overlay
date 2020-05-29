local bit = require("bit")
local log = require("log")
local memory = require("memory." .. jit.os:lower())
local clones = require("games.clones")
local notification = require("notification")
local filesystem = love.filesystem

local configdir = filesystem.getSaveDirectory()

if filesystem.createDirectory(configdir) then
	log.debug("Created %s config directory: %s", filesystem.getIdentity(), configdir)
end

local clones_file = "clones.lua"
log.info("Load: %s/%s", configdir, clones_file)

if filesystem.getInfo(clones_file, "file") then
	local status, chunk = pcall(filesystem.load, clones_file)

	if not status then
		-- Failed loading chunk, chunk is an error string
		log.error(chunk)
		notification.error(chunk)
	elseif chunk then
		-- Create a sandboxed lua environment
		local env = {}
		env._G = env

		-- Set the loaded chunk inside the sandbox
		setfenv(chunk, env)

		local status, custom_clones = pcall(chunk)
		if not status then
			-- Failed calling the chunk, custom_clones is an error string
			log.error(custom_clones)
			notification.error(custom_clones)
		else
			local num_clones = 0
			for clone_id, info in pairs(custom_clones) do
				num_clones = num_clones + 1
				clones[clone_id] = info
			end
			log.info("Loaded %d clones from %s", num_clones, clones_file)
			notification.coloredMessage(("Loaded %d clones from %s"):format(num_clones, clones_file))
		end
	end
end

require("extensions.string")

local watcher = {
	debug = false,
	initialized = false,
	gameid = "\0\0\0\0\0\0",
	version = 0,
	process = memory.init(),
	hooks = {},
	wildcard_hooks = {},
	values_memory = {},
	values_pointer = {},
	watching_addr = {},
	watching_str_addr = {},
	watching_ptr_addr = {},
	pointer_loc = {},
	named = {},
}

watcher.permissions = watcher.process:hasPermissions()

-- Allow us to do things such as watcher.players.name without having to do watcher.named.player.name
setmetatable(watcher, {__index = watcher.named})

local TYPE_NULL = 0
local TYPE_BOOL = 1
local TYPE_BYTE = 2
local TYPE_SHORT = 3
local TYPE_INT = 4
local TYPE_FLOAT = 5
local TYPE_POINTER = 6
local TYPE_DATA = 7
local TYPE_SIGNED_BYTE = 8

local TYPE_NAME = {
	["bool"] = TYPE_BOOL,
	["byte"] = TYPE_BYTE,
	["sbyte"] = TYPE_SIGNED_BYTE,
	["short"] = TYPE_SHORT,
	["int"] = TYPE_INT,
	["float"] = TYPE_FLOAT,
	["pointer"] = TYPE_POINTER,
}

local READ_TYPES = {
	[TYPE_BOOL] = "readBool",
	[TYPE_BYTE] = "readUByte",
	[TYPE_SIGNED_BYTE] = "readByte",
	[TYPE_SHORT] = "readShort",
	[TYPE_INT] = "readInt",
	[TYPE_FLOAT] = "readFloat",
}

function watcher.init()
	log.info("Mapping game memory..")
	watcher.initialized = true
	for address, info in pairs(watcher.game.memorymap) do
		if info.type == "pointer" and info.struct then
			watcher.pointer_loc[address] = 0x00000000
			watcher.values_pointer[address] = {}
			watcher.watching_ptr_addr[address] = {}
			for offset, struct in pairs(info.struct) do
				watcher.watching_ptr_addr[address][offset] = TYPE_NAME[struct.type]
				local name = ("%s.%s"):format(info.name, struct.name)
				watcher.setTableValue(name, info.init)
			end
		else
			watcher.values_memory[address] = info.init or 0
			watcher.watching_addr[address] = TYPE_NAME[info.type]
			watcher.setTableValue(info.name, watcher.values_memory[address])
		end
	end
end

function watcher.reset()
	watcher.initialized = false
	watcher.values_memory = {}
	watcher.values_pointer = {}
	watcher.watching_addr = {}
	watcher.watching_str_addr = {}
	watcher.watching_ptr_addr = {}
	watcher.pointer_loc = {}
	watcher.named = {}
	watcher.gameid = "\0\0\0\0\0\0"
	watcher.version = 0
	watcher.game = nil
	setmetatable(watcher, {__index = watcher.named})
end

function watcher.getGame()
	return watcher.game
end

-- Creates or updates a tree of values for easy indexing
-- Example a path of "player.name" will become watcher.players = { name = value }
function watcher.setTableValue(path, value)
	local last = watcher.named

	local keys = {}
	for key in string.gmatch(path, "[^%.]+") do
		keys[#keys + 1] = tonumber(key) or key
	end

	for i, key in ipairs(keys) do
		if i < #keys then
			last[key] = last[key] or {}
			last = last[key]
		else
			if type(last) ~= "table" then
				return error(("Failed to index a %s value (%q)"):format(type(last), keys[i-1]))
			end
			last[key] = value
		end
	end
end

function watcher.hook(name, desc, callback)
	if string.find(name, "*", 1, true) then
		-- Convert '*' into capture patterns
		local pattern = '^' .. name:escape():gsub("%%%*", "([^.]-)") .. '$'
		watcher.wildcard_hooks[pattern] = watcher.wildcard_hooks[pattern] or {}
		watcher.wildcard_hooks[pattern][desc] = callback
	else
		watcher.hooks[name] = watcher.hooks[name] or {}
		watcher.hooks[name][desc] = callback
	end
end

function watcher.unhook(name, desc)
	watcher.hook(name, desc, nil)
end

local args = {}
local matches = {}

function watcher.hookRun(name, ...)
	-- Normal hooks
	if watcher.hooks[name] then
		for desc, callback in pairs(watcher.hooks[name]) do
			local succ, err
			if type(desc) == "table" then
				-- Assume a table is an object, so call it as so
				succ, err = xpcall(callback, debug.traceback, desc, ...)
			else
				succ, err = xpcall(callback, debug.traceback, ...)
			end
			if not succ then
				log.error("watcher hook error: %s (%s)", desc, err)
			end
		end
	end

	local varargs = {...}

	-- Allow for wildcard hooks
	for pattern, hooks in pairs(watcher.wildcard_hooks) do
		if string.find(name, pattern) then
			args = {}
			matches = {name:match(pattern)}

			for k, match in ipairs(matches) do
				table.insert(args, tonumber(match) or match)
			end
			for k, arg in ipairs(varargs) do
				table.insert(args, arg)
			end

			for desc, callback in pairs(hooks) do
				local succ, err
				if type(desc) == "table" then
					-- Assume a table is an object, so call it as so
					succ, err = xpcall(callback, debug.traceback, desc, unpack(args))
				else
					succ, err = xpcall(callback, debug.traceback, unpack(args))
				end
				if not succ then
					log.error("watcher wildcard hook error: %s (%s)", desc, err)
				end
			end
		end
	end
end

function watcher.toHex(address)
	return ("%08X"):format(address)
end

function watcher.hasPermissions()
	return watcher.permissions
end

function watcher.readGameID()
	return tostring(watcher.process:read(0x0, 0x06))
end

function watcher.readGameVersion()
	return watcher.process:readUByte(0x7)
end

function watcher.readType(type, address)
	return watcher.process[READ_TYPES[type]](watcher.process, address)
end

function watcher.isReady()
	return watcher.process:hasProcess() and watcher.process:isProcessActive() and watcher.process:hasGamecubeRAMOffset()
end

function watcher.update(exe)
	if not watcher.permissions then return end

	if not watcher.process:isProcessActive() and watcher.process:hasProcess() then
		watcher.process:close()
		love.window.setTitle("M'Overlay - Waiting for Dolphin..")
		log.info("Unhooked: %s", exe)
	end

	if watcher.process:findprocess(exe) then
		log.info("Hooked: %s", exe)
		love.window.setTitle("M'Overlay - Dolphin hooked")
	elseif not watcher.process:hasGamecubeRAMOffset() and watcher.process:findGamecubeRAMOffset() then
		log.info("Watching process ram: %s", exe)
	elseif watcher.process:hasProcess() and watcher.process:hasGamecubeRAMOffset() then
		watcher.checkmemoryvalues()
	end
end

function watcher.checkmemoryvalues()
	local frame = watcher.frame or 0
	local gid = watcher.readGameID()
	local version = watcher.readGameVersion()

	if watcher.gameid ~= gid or watcher.version ~= version then
		watcher.reset()
		watcher.gameid = gid
		watcher.version = version

		if gid ~= "\0\0\0\0\0\0" then
			log.debug("GAMEID: %q (Version %d)", gid, version)
			love.window.setTitle(("M'Overlay - Dolphin hooked (%s-%d)"):format(gid, version))

			-- See if this GameID is a clone of another
			local clone = clones[gid]

			if clone then
				version = clone.version
				gid = clone.id
			end

			-- Try to load the game table
			local status, game = xpcall(require, debug.traceback, string.format("games.%s-%d", gid, version))

			if status then
				watcher.game = game
				log.info("Loaded game config: %s-%d", gid, version)
				watcher.init()
			else
				notification.error(("Unsupported game %s-%d"):format(gid, version))
				log.error(game)
			end
		else
			love.window.setTitle("M'Overlay - Dolphin hooked")
			log.info("Game closed..")
		end
	end

	for address, type in pairs(watcher.watching_addr) do
		local value = watcher.readType(type, address)
		if watcher.values_memory[address] ~= value then
			local info = watcher.game.memorymap[address]
			local numValue = tonumber(value) or (value and 1 or 0)

			if watcher.debug or info.debug then
				log.debug("[%d][%08X = %08X] %s = %s", frame, address, numValue, info.name, value)
			end

			watcher.values_memory[address] = value
			watcher.setTableValue(info.name, watcher.values_memory[address])
			watcher.hookRun(info.name, value)
		end
	end

	for address, pointing in pairs(watcher.pointer_loc) do
		local ptr_addr = watcher.process:readInt(address)
		if watcher.pointer_loc[address] ~= ptr_addr then
			watcher.pointer_loc[address] = ptr_addr

			log.debug("[%d] pointer at %08X changed location to %08X", frame, address, ptr_addr)

			if ptr_addr == 0x00000000 then
				watcher.values_pointer[address] = {}
			end
		end
	end

	for address, offsets in pairs(watcher.watching_ptr_addr) do
		local ptr_addr = watcher.pointer_loc[address]
		if ptr_addr and ptr_addr ~= 0x00000000 then

			local info = watcher.game.memorymap[address]

			for offset, type in pairs(offsets) do

				local value = watcher.readType(type, ptr_addr + offset)

				-- If the location of the pointer changed, or our value changed..
				if watcher.values_pointer[address][offset] ~= value then
				
					if info and info.struct and info.struct[offset] then
						local name = string.format("%s.%s", info.name, info.struct[offset].name)
						local numValue = tonumber(value) or (value and 1 or 0)

						if watcher.debug or info.debug or info.struct[offset].debug then
							log.debug("[%d][%08X->%08X->%08X = %08X] %s = %s", frame, address, ptr_addr, ptr_addr + offset, numValue, name, value)
						end

						watcher.values_pointer[address][offset] = value
						watcher.setTableValue(name, watcher.values_pointer[address][offset])
						watcher.hookRun(name, value)
					end
				end
			end
		end
	end
end

return watcher