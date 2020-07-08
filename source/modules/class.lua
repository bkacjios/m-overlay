local class = {
	structs = {},
	inherits = {},
}

local constructor_method = "Initialize"

local OBJECT = {}

function OBJECT:__newindex(key, value)
	local accessors = rawget(self, "__accessors")
	if accessors and rawget(accessors, key) ~= nil then
		rawset(accessors, key, value)
	else
		rawset(self, key, value)
	end
end

function OBJECT:__index(key)
	-- Check for any specific, class-based, methods like "super"
	local meta_index = rawget(getmetatable(self), key) -- OBJECT
	if meta_index ~= nil then
		-- Only return if not nil
		return meta_index
	end

	local accessors = rawget(self, "__accessors")
	if accessors then
		-- Only do the lookup once to prevent multiple __index calls
		local value = accessors[key]
		if value ~= nil then
			-- Only return if not nil
			return value
		end
	end

	-- Try the base class next
	local base = rawget(self, "__baseclass")
	if base then
		-- Only do the lookup once to prevent multiple __index calls
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

	local call = method or constructor_method

	if base[call] == nil then
		return error(string.format("attempted to call method '%s' (a nil value)", call))
	end

	-- +1 to the scope
	self.__superscope = self.__superscope + 1

	-- Call the method
	-- This can trigger another super call, so thats why we need __superscope
	base[call](self, ...)

	-- -1 from the scope
	self.__superscope = self.__superscope - 1
end

function OBJECT:MakeAccessor(name, internal, default)
	self.__accessors[internal] = default
	if type(default) == "boolean" then
		self["Is" .. name] = function(this) return this.__accessors[internal] end
	end
	self["Get" .. name] = function(this) return this.__accessors[internal] end
	self["Set" .. name] = function(this, value) this.__accessors[internal] = value end
end

function OBJECT:getBaseClass()
	return self.__baseclass
end

function OBJECT:__tostring()
	local base = self.__baseclass
	return string.format("%s[%s]", base and base.__classname or "Object", self.__classname)
end

function class.new(name, ...)
	if class.structs[name] then
		local struct = class.structs[name]

		-- Create a copy of the struct, with metatable and all
		local obj = table.copy(struct)
		-- Set values that are unique to this instance
		obj.__superscope = 1
		obj.__accessors = {}

		-- Try to call the initializer
		if obj[constructor_method] then
			obj[constructor_method](obj, ...)
		end
		return obj
	end

	return error(("failed to create unknown class '%s'"):format(name))
end

function class.register(classname, basename)
	return function(struct)
		struct.__classname = classname
		class.inherits[classname] = basename
		class.structs[classname] = struct
		return struct
	end
end

function class.init()
	-- We need to do this after registering our classes rather than during,
	-- since we don't know the order in which classes will be registered.
	-- We wan't to be sure that every classes baseclass is ready.

	for classname, struct in pairs(class.structs) do
		-- Set the baseclass
		struct.__baseclass = class.structs[class.inherits[classname]]
		-- Register it as a valid class
		setmetatable(struct, OBJECT)
	end
end

return class