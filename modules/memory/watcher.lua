local bit = require("bit")
local log = require("log")
local memory = require("memory.windows")

require("extensions.string")

local watcher = {
	debug = false,
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
	map = require("memory.melee"), -- The map of the game we want to use!
}

local TYPE_NULL = 0
local TYPE_BOOL = 1
local TYPE_BYTE = 2
local TYPE_SHORT = 3
local TYPE_INT = 4
local TYPE_FLOAT = 5
local TYPE_POINTER = 6
local TYPE_DATA = 7

-- Allow us to do things such as watcher.players.name without having to do watcher.named.player.name
setmetatable(watcher, {__index = watcher.named})

local TYPE_NAME = {
	["bool"] = TYPE_BOOL,
	["byte"] = TYPE_BYTE,
	["short"] = TYPE_SHORT,
	["int"] = TYPE_INT,
	["float"] = TYPE_FLOAT,
	["pointer"] = TYPE_POINTER,
}

local READ_TYPES = {
	[TYPE_BOOL] = "readBool",
	[TYPE_BYTE] = "readUByte",
	[TYPE_SHORT] = "readShort",
	[TYPE_INT] = "readInt",
	[TYPE_FLOAT] = "readFloat",
}

function watcher.init()
	for address, info in pairs(watcher.map) do
		if info.type == "pointer" and info.struct then
			watcher.pointer_loc[address] = 0x00000000
			watcher.values_pointer[address] = {}
			watcher.watching_ptr_addr[address] = {}
			for offset, struct in pairs(info.struct) do
				watcher.watching_ptr_addr[address][offset] = TYPE_NAME[struct.type]
				local name = ("%s.%s"):format(info.name, struct.name)
				watcher.setTableValue(name, info.init or 0)
			end
		else
			watcher.values_memory[address] = info.init or 0
			watcher.watching_addr[address] = TYPE_NAME[info.type]
			watcher.setTableValue(info.name, watcher.values_memory[address])
		end
	end
end

function watcher.shutdown()
	watcher.values_memory = {}
	watcher.values_pointer = {}
	watcher.watching_addr = {}
	watcher.watching_ptr_addr = {}

	watcher.named = {}
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
		local pattern = '^' .. name:escapePattern():gsub("%%%*", "([^.]-)") .. '$'
		watcher.wildcard_hooks[pattern] = watcher.wildcard_hooks[pattern] or {}
		watcher.wildcard_hooks[pattern][desc] = callback
	else
		watcher.hooks[name] = watcher.hooks[name] or {}
		watcher.hooks[name][desc] = callback
	end
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

function watcher.readType(type, address)
	return watcher.process[READ_TYPES[type]](watcher.process, address)
end

function watcher.isReady()
	return watcher.process:hasProcess() and watcher.process:isProcessActive() and watcher.process:hasGamecubeRAMOffset()
end

function watcher.update(exe)
	if not watcher.process:isProcessActive() and watcher.process:hasProcess() then
		watcher.process:close()
		love.window.setTitle("M'Overlay - Waiting for Dolphin.exe..")
		log.info("closed: %s", exe)
	end

	if watcher.process:findprocess(exe) then
		log.info("hooked: %s", exe)
		love.window.setTitle("M'Overlay - Dolphin.exe hooked")
	end

	if not watcher.process:hasGamecubeRAMOffset() and watcher.process:findGamecubeRAMOffset() then
		log.info("watching ram: %s", exe)
		watcher.init()
		love.gameLoaded()
	elseif watcher.process:hasProcess() and watcher.process:hasGamecubeRAMOffset() then
		watcher.checkmemoryvalues()
	end
end

function watcher.checkmemoryvalues()
	local frame = watcher.frame

	for address, type in pairs(watcher.watching_addr) do
		local value = watcher.readType(type, address)
		if watcher.values_memory[address] ~= value then
			local info = watcher.map[address]
			local numValue = tonumber(value) or (value and 1 or 0)

			if info.debug then
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

			local info = watcher.map[address]

			for offset, type in pairs(offsets) do

				local value = watcher.readType(type, ptr_addr + offset)

				-- If the location of the pointer changed, or our value changed..
				if watcher.values_pointer[address][offset] ~= value then
				
					if info and info.struct and info.struct[offset] then
						local name = string.format("%s.%s", info.name, info.struct[offset].name)
						local numValue = tonumber(value) or (value and 1 or 0)

						if info.debug or info.struct[offset].debug then
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