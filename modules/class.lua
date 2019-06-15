class = {
	classes = {},
}

local constructor_method = "Initialize"

local DEEP = {}

local OBJECT = {
	__index = function(self, key)
		if rawget(self, key) then
			return rawget(self, key)
		end
		local meta = getmetatable(self)
		if rawget(meta, key) then
			return rawget(meta, key)
		end
		return self.__baseclass[key]
	end,

	super = function(self, method, ...)
		local base = self
		for i=1,self.__superscope do
			base = base.__baseclass
		end
		self.__superscope = self.__superscope + 1
		base[method or constructor_method](self, ...)
		self.__superscope = self.__superscope - 1
	end,

	getSuperClass = function(self)
		return self.__baseclass
	end,

	__tostring = function(self)
		return "Object[]"
	end
}

function class.new(name, ...)
	if class.classes[name] then
		local base = class.classes[name]
		local obj = setmetatable({}, base)
		obj.__superscope = 1
		if obj[constructor_method] then
			obj[constructor_method](obj, ...)
		end
		return obj
	end
	return error(("Unknown class '%s'"):format(name))
end

function table.merge(a, b)
	for k, v in pairs(b) do
		if not a[k] then a[k] = v end
	end
	return a
end

function class.register(classname, basename)
	return function(struct)
		local base = class.classes[basename] or OBJECT
		struct.__baseclass = base
		struct.__classname = classname
		table.merge(struct, base)
		class.classes[classname] = setmetatable(struct, base)
		return struct
	end
end

return class