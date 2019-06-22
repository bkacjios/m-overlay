class = {
	structs = {},
	classes = {},
}

local constructor_method = "Initialize"

local OBJECT = {
	__index = function(self, key)
		local self_index = rawget(self, key)

		if self_index then
			return self_index
		end

		local meta_index = rawget(getmetatable(self), key)
		if meta_index then
			return meta_index
		end

		local base = rawget(self, "__baseclass")
		if base then
			return base[key]
		end
	end,

	super = function(self, method, ...)
		local base = self

		for i=1,self.__superscope do
			base = base.__baseclass
		end

		local call = method or constructor_method

		if base[call] == nil then
			return error(string.format("method '%s' is nil", call))
		end
		self.__superscope = self.__superscope + 1
		base[call](self, ...)
		self.__superscope = self.__superscope - 1
	end,

	getSuperClass = function(self)
		return self.__baseclass
	end,

	__tostring = function(self)
		return string.format("%s[]", self.__classname)
	end
}

function class.new(name, ...)
	if class.classes[name] then
		local base = class.classes[name]
		local obj = setmetatable(table.copy(base), OBJECT)
		obj.__superscope = 1
		if obj[constructor_method] then
			obj[constructor_method](obj, ...)
		end
		return obj
	end
	return error(("Unknown class '%s'"):format(name))
end

function table.copy(a)
	local new = {}
	for k,v in pairs(a) do
		new[k] = v
	end
	return new
end

function table.merge(a, b)
	for k, v in pairs(b) do
		if not a[k] then a[k] = v end
	end
	return a
end

function class.register(classname, basename)
	return function(struct)
		struct.__baseclassname = basename
		struct.__classname = classname
		class.structs[classname] = struct
		return struct
	end
end

function class.init()
	-- We need to do this after registering our panels
	for classname, struct in pairs(class.structs) do
		local baseclassname = struct.__baseclassname
		local base = baseclassname and class.structs[baseclassname] or OBJECT
		struct.__baseclass = base
		table.merge(struct, OBJECT)
		class.classes[classname] = struct
	end

	for classname, struct in pairs(class.classes) do
		class.classes[classname] = setmetatable(struct, struct.__baseclass)
	end
end

return class