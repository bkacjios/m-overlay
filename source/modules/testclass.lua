local class = require("class")

local FOO = {}

function FOO:Initialize()
	print(self, "FOO Initialize")
	self.m_sFoo = "foo"
end

function FOO:FooMethod()
	print("I LIKE FOO")
end

function FOO:Shared()
	print("Shared from foo..")
end

class.register("FOO")(FOO)

local BAR = {}

function BAR:Initialize()
	print(self, "BAR Initialize")
	self.m_sBar = "bar"
	self:super()
end

function BAR:BarMethod()
	print("I LIKE BAR")
end

class.register("BAR", "FOO")(BAR)

local FOOBAR = {}

function FOOBAR:Initialize()
	print(self, "FOOBAR Initialize")
	self.m_sFooBar = "foobar"
	self:super()
end

function FOOBAR:FooBarMethod()
	print("I LIKE FOOBAR")
end

class.register("FOOBAR", "BAR")(FOOBAR)

class.init()

local foo = class.new("FOO")
foo:FooMethod()
foo:Shared()
print(foo.m_sFoo)
print(foo.m_sBar)
print(foo.m_sFooBar)

local bar = class.new("BAR")
bar:FooMethod()
bar:BarMethod()
bar:Shared()
print(bar.m_sFoo)
print(bar.m_sBar)
print(bar.m_sFooBar)

local foobar = class.new("FOOBAR")
foobar:FooMethod()
foobar:BarMethod()
foobar:FooBarMethod()
foobar:Shared()
print(foobar.m_sFoo)
print(foobar.m_sBar)
print(foobar.m_sFooBar)

return class