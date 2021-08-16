local class = {
	structs = {},
	inherits = {},
}

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

local CLASS = {}
CLASS.__index = CLASS

function CLASS:ACCESSOR(name, internal, default)
	return ACCESSOR(self, name, internal, default)
end

function CLASS:extends(basename)
	class.inherits[self.__classname] = basename
	return self
end

function class.create(classname, basename)
	local struct = {}
	struct.__classname = classname
	struct.__constructor = classname
	class.structs[classname] = struct
	class.inherits[classname] = basename
	return setmetatable(struct, CLASS)
end

function class.getStruct(classname)
	return class.structs[classname]
end

function class.getBaseClassname(classname)
	return class.inherits[classname]
end

return class