local class = {
	structs = {},
	inherits = {},
}

local OBJECT = {}

function OBJECT:__call(...)
	if not self[self.__constructor] then
		return error(string.format("can not create object for class %s (no constructor)", self))
	end
	self[self.__constructor](self, ...)
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

function ACCESSOR(object, name, internal, default)
	if not object then
		return error("attempt to call ACCESSOR on a nil value")
	end
	object[internal] = default
	if type(default) == "boolean" then
		object["Is" .. name] = function(this) return this[internal] end
	end
	object["Get" .. name] = function(this) return this[internal] end
	object["Set" .. name] = function(this, value) this[internal] = value end
end

function OBJECT:getBaseClass()
	return self.__baseclass
end

function OBJECT:getClass()
	local super = getmetatable(self)
	return (super ~= OBJECT and super or nil)
end

function OBJECT:__tostring()
	return string.format("%s::%s", self.__baseclass or "", self.__classname)
end

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

	function class.new(name, ...)
		if not class.structs[name] then
			return error(("failed to create unknown class '%s'"):format(name)) 
		end

		-- Get our class structure
		local struct = class.structs[name]

		-- Create a copy of the struct, with metatable and all
		local obj = copy(struct)

		-- Set values that are unique to this instance
		obj.__superscope = 1

		-- Return our new object and call constructor
		return obj(...)
	end
end

function class.create(classname, basename)
	local struct = {}
	struct.__classname = classname
	struct.__constructor = classname
	class.inherits[classname] = basename
	class.structs[classname] = struct
	return struct
end

function class.init()
	-- We need to do this after registering our classes rather than during,
	-- since we don't know the order in which classes will be registered.
	-- We want to be sure that every classes baseclass is ready.

	for classname, struct in pairs(class.structs) do
		-- Set the baseclass
		struct.__baseclass = class.structs[class.inherits[classname]]
		-- Register it as a valid class
		setmetatable(struct, OBJECT)
	end
end

return class