local class = require("class")

local OBJECT = {}

function OBJECT:__call(...)
	local constructor = rawget(self, rawget(self, "__constructor"))
	if not constructor then
		return error(string.format("can not create object for class '%s' (no constructor)", self))
	end
	constructor(self, ...)
	return self
end

function OBJECT:__index(key)
	-- Check for any specific, class-based, methods like "super"
	local meta_index = rawget(getmetatable(self), key) -- OBJECT
	if meta_index ~= nil then
		-- Only return if not nil
		return meta_index
	end

	-- Try the base class next
	local base = rawget(self, "__baseclass")
	if base then
		-- Only do the lookup once to prevent infinite __index calls
		local value = base[key]
		if value ~= nil then
			-- Only return if not nil
			return value
		end
	end

	-- Welp, nothing to find
	return nil
end

function OBJECT:instanceof(other)
	local base = self

	while base do
		if base == rawget(other, "__baseclass") then
			return true
		end
		base = rawget(base, "__baseclass")
	end

	return false
end

function OBJECT:super(method, ...)
	local base = self

	-- Attempt to determine the base via the current scope of the call
	for i=1, self.__superscope do
		base = rawget(base, "__baseclass")
	end

	-- Error if the scope of the call has no baseclass (AKA the main class)
	if not base then return error("attempted to call method 'super' in class with no baseclass") end

	local call = method or base.__constructor

	if base[call] == nil then
		return error(string.format("attempted to call method '%s' (a nil value)", call))
	end

	-- +1 to the scope
	self.__superscope = self.__superscope + 1

	-- Call the method
	-- This can trigger another super call, so thats why we need __superscope
	local ret = base[call](self, ...)

	-- -1 from the scope
	self.__superscope = self.__superscope - 1

	-- return super return
	return ret
end

function OBJECT:getBaseClass()
	return self.__baseclass
end

function OBJECT:getClass()
	local super = getmetatable(self)
	return (super ~= OBJECT and super or nil)
end

function OBJECT:__tostring()
	local classtree = ""
	local base = self
	while base do
		classtree = base.__classname .. "::" .. classtree
		base = base.__baseclass
	end
	return string.format("%s%p", classtree, self)
end

local object = {}

do
	local function copy(object)
		local lookup_table = {}
		local function _copy(object)
			if type(object) ~= "table" then
				return object
			elseif lookup_table[object] then
				return lookup_table[object]
			end
			local new_table = {}
			lookup_table[object] = new_table
			for index, value in pairs(object) do
				new_table[_copy(index)] = _copy(value)
			end
			return setmetatable(new_table, getmetatable(object))
		end
		return _copy(object)
	end

	local function createObject(name)
		local main = class.getStruct(name)
		local base = class.getBaseClassname(name)
		local obj = setmetatable(copy(main), OBJECT)
		if base then
			obj.__baseclass = createObject(base)
		end
		return obj
	end

	function object.new(name, ...)
		if not class.getStruct(name) then
			return error(("failed to create object for unknown class '%s'"):format(name)) 
		end

		-- Create a copy of the struct, with metatable and all
		local obj = createObject(name)

		-- Set values that are unique to this instance
		obj.__superscope = 1

		-- Return our new object and call constructor
		return obj(...)
	end
end

return object