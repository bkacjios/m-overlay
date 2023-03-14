local class = {
	structs = {},
	inherits = {},
}

function ACCESSOR(object, field, internal, default)
	if not object then
		return error("attempt to call ACCESSOR on a nil value")
	end
	object[internal] = default

	local getter = function(this) return this[internal] end
	local setter = function(this, value) this[internal] = value end

	if type(default) == "boolean" then
		object["Is" .. field] = getter
	end
	object["Get" .. field] = getter
	object["Set" .. field] = setter
end

local STRUCT = {}
STRUCT.__index = STRUCT

function STRUCT:ACCESSOR(field, internal, default)
	if type(field) == "table" then
		for k,v in pairs(field) do
			ACCESSOR(self, v, internal, default)
		end
	elseif type(field) == "string" then
		ACCESSOR(self, field, internal, default)
	end
end

function STRUCT:extends(basename)
	class.inherits[self.classname] = basename
	return self
end

function class.create(classname, basename)
	local struct = {}
	struct.classname = classname
	class.structs[classname] = struct
	class.inherits[classname] = basename
	return setmetatable(struct, STRUCT)
end

function class.get(classname)
	return class.structs[classname]
end

function class.getBase(classname)
	return class.inherits[classname]
end

return class