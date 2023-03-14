local class = require("class")

local OBJECT = {}

function OBJECT:__call(...)
	local class = rawget(self, "class")
	local classname = rawget(class, "classname")
	local constructor = rawget(class, classname)
	if not constructor then
		-- constructor doesn't exist, error
		return error(string.format("can not create object for class '%s' (no constructor)", classname))
	end
	-- call our constructor method
	constructor(self, ...)
	-- return the object
	return self
end

local function recursiveIndex(class, key)
	local value = rawget(class, key)
	if value ~= nil then
		return value
	else
		class = rawget(class, "class")
		if class then
			-- Check the inherited class
			return recursiveIndex(class, key)
		end
	end
	return nil
end

function OBJECT:__index(key)
	-- Check for any specific, class-based, methods like "super"
	local meta_index = rawget(getmetatable(self), key) -- OBJECT
	if meta_index ~= nil then
		-- Only return if not nil
		return meta_index
	end

	-- Get our "self" class structure
	local class = rawget(self, "__self")

	-- Recursive lookup down the class line
	return recursiveIndex(class, key)
end

function OBJECT:instanceof(other)
	local class = rawget(self, "class")
	local name
	local tp = type(other)

	if tp == "table" then
		-- User passed another object, get the classname
		name = rawget(rawget(self, "class"), "classname")
	elseif tp == "string" then
		-- User passed the classname
		name = other
	end

	-- Handle invalid arguments
	if not name then return error(string.format("unexpected argument #2 (string or object expected, got %s", tp)) end

	while class do
		-- Loop through the class tree and see if any match
		if class:getName() == name then
			return true
		end
		class = rawget(class, "class")
	end

	-- Nothing found
	return false
end

function OBJECT:super(method, ...)
	local this = rawget(self, "__self")
	local class = rawget(this, "class")

	-- Error if the scope of the super call has no inheritance (AKA the main class)
	if not class then return error("attempted to call method 'super' in class with no baseclass") end

	-- Use the method name or the class name (for constructor) if nil
	method = method or class.classname

	-- Recursively lookup the method starting at our "self" class
	local func = recursiveIndex(class, method)

	if func == nil or type(func) ~= "function" then
		-- Method doesn't exist, throw an error
		return error(string.format("attempted to call method '%s' (a %s value)", method, type(func)))
	end

	-- The "self" is now inside the inherited class structure
	rawset(self, "__self", class)

	-- Call the method
	-- This can trigger another super call, so thats why we need "self" as our defined scope
	local ret = func(self, ...)

	-- The "self" is back to the main class structure
	rawset(self, "__self", this)

	-- return whatever our method returned
	return ret
end

function OBJECT:getBaseClass()
	return rawget(rawget(self, "class"), "class")
end

function OBJECT:getClass()
	return rawget(self, "class")
end

function OBJECT:type()
	return "object"
end

function OBJECT:__tostring()
	return string.format("%s: %p", rawget(rawget(self, "class"), "classname"), self)
end

local CLASS = {}
CLASS.__index = CLASS

function CLASS:getBaseClass()
	return rawget(self, "class")
end

function CLASS:getName()
	return rawget(self, "classname")
end

function OBJECT:type()
	return "class"
end

function CLASS:__tostring()
	return string.format("Class[%q]: %p", self:getName(), self)
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

	local function createObjectClass(name)
		local main = class.get(name)
		local base = class.getBase(name)
		local struct = setmetatable(copy(main), CLASS)
		if base then
			struct.class = createObjectClass(base)
		end
		return struct
	end

	function object.new(name, ...)
		if not class.get(name) then
			return error(("failed to create object for unknown class '%s'"):format(name)) 
		end

		-- Create a copy of the class structure, with metatable and all
		local obj = setmetatable({class=createObjectClass(name)}, OBJECT)

		-- Set our current "self" to our class structure
		obj.__self = obj.class

		-- Return our new object and call constructor
		return obj(...)
	end
end

return object