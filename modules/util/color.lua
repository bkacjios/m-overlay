function unpackcolor(col) -- Unpack a color
	return col.r, col.g, col.b, col.a
end

local COLOR = {}
COLOR.__index = COLOR

function color(r, g, b, a)
	if type(r) == "string" then
		local c = {}
		local i = 1
		for hex in r:gmatch("%x%x") do
			c[i] = (tonumber(hex, 16) or 0)
			i = i + 1
		end
		return setmetatable({
			r = math.min(c[1] or 0, 255),
			g = math.min(c[2] or 0, 255),
			b = math.min(c[3] or 0, 255),
			a = math.min(c[4] or 255, 255)
		}, COLOR)
	else
		return setmetatable({
			r = math.min(tonumber(r or 255), 255),
			g = math.min(tonumber(g or 255), 255),
			b = math.min(tonumber(b or 255), 255),
			a = math.min(tonumber(a or 255), 255)
		}, COLOR)
	end
end

function COLOR:__tostring()
	return string.format("color[%i, %i, %i, %i][#%06X]", self.r, self.g, self.b, self.a, self:hex())
end

function COLOR:__add(col)
	return color(math.Clamp(self.r + col.r, 0, 255), math.Clamp(self.g + col.g, 0, 255), math.Clamp(self.b + col.b, 0, 255))
end

function COLOR:__mul(col)
	return color(((self.r / 255) * (col.r / 255)) * 255, ((self.g / 255) * (col.g / 255)) * 255, ((self.b / 255) * (col.b / 255)) * 255)
end

function COLOR:__eq(col)
	return self.r == col.r and self.g == col.g and self.b == col.b and self.a == col.a
end

function COLOR:vector()
	return vector(col.r / 255, col.g / 255, col.b / 255)
end

function COLOR:fadeTo(col, frac)
	local faded = color(255, 255, 255)
	faded.r = (self.r * (1 - frac)) + col.r * frac
	faded.g = (self.g * (1 - frac)) + col.g * frac
	faded.b = (self.b * (1 - frac)) + col.b * frac
	faded.a = self.a
	return faded
end

function COLOR:hex()
	if type(self) == "number" then return self end
	return bit.lshift(self.r, 16) + bit.lshift(self.g, 8) + bit.lshift(self.b, 0)
end

function COLOR:distance(col)
	local r = self.r - col.r
	local g = self.g - col.g
	local b = self.b - col.b
	return r * r + g * g + b * b
end

color_blank = color(0, 0, 0, 0)
color_white = color(255, 255, 255)
color_black = color(0, 0, 0)
color_red = color(237, 28, 36)
color_green = color(34, 177, 76)
color_blue = color(0, 162, 232)
color_entity = color(151, 211, 255)
color_pink = color(255, 128, 128)
color_hotpink = color(255, 105, 180)
color_orange = color(255, 126, 0)

return color