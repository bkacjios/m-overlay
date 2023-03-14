require("extensions.table")

local class = require("class")
local object = require("class.object")

io.stdout:setvbuf("no")

local ENTITY = class.create("Entity")

ENTITY:ACCESSOR("Enabled", "m_bEnabled", false)

function ENTITY:Entity()
	print("3 - Entity Constructor")
end

function ENTITY:Bar()
	print("Hello world :)", self)
end


local ANIMAL = class.create("Animal", "Entity")

function ANIMAL:Animal()
	print("2 - Animal Constructor")
	self:super()
end

function ANIMAL:DoThing()
	print("6")
end

function ANIMAL:Think()
	print("5", self)
	self:DoThing() -- self will always be within the current class structure, so we go to line 26 and not line 48
end


local DOG = class.create("Dog", "Animal")

function DOG:Dog()
	print("1 - Dog Constructor")
	self:super()
end

function DOG:Think()
	print("4")
	self:super("Think")
end

function DOG:DoThing()
	print("7")
	self:super("DoThing")
end

local obj = object.new("Dog")
print("BEGINNING TEST", obj)
obj:Bar()
obj:Think()

-- This creates an override at the object level, the class method will remain in tact
obj.Think = function(this)
	print("OVERRIDE")
end

obj:Think()

-- Origial method can still be accessed via the class
obj.class.Think(obj)

print(obj:getClass())
print(obj:getBaseClass())
print(obj:instanceof("Entity"))
print(obj:instanceof("Animal"))
print(obj:instanceof("Dog"))

print(obj:IsEnabled())