local COLOR = {}
COLOR.__index = COLOR

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

function COLOR:unpack()
	return self.r, self.g, self.b, self.a
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

function COLOR:toHSV()
	local r = self.r / 255
	local g = self.g / 255
	local b = self.b / 255
	local a = self.a / 255

	local hue, saturation, value

	local max, min = math.max(r, g, b), math.min(r, g, b)

	value = max

	local delta = max - min

	if max == 0 then
		saturation = 0
	else
		saturation = delta / max
	end

	if max == min then
		hue = 0 -- achromatic
	else
		if max == r then
			hue = (g - b) / delta
			if g < b then
				hue = hue + 6
			end
		elseif max == g then
			hue = (b - r) / delta + 2
		elseif max == b then
			hue = (r - g) / delta + 4
		end
		hue = hue / 6
	end

	return hue, saturation, value, a
end

local color = {}
color = setmetatable(color, color)

function color:__call(r, g, b, a)
	if type(r) == "string" then
		local c = {}
		local i = 1
		for hex in r:gmatch("%x%x") do
			c[i] = (tonumber(hex, 16) or 0) -- Convert hex to byte value
			i = i + 1
		end
		return setmetatable({
			r = math.min(c[1] or 0, 255),
			g = math.min(c[2] or 0, 255),
			b = math.min(c[3] or 0, 255),
			a = math.min(c[4] or 255, 255)
		}, COLOR)
	elseif type(r) == "table" then
		return setmetatable(r, COLOR)
	else
		return setmetatable({
			r = math.min(tonumber(r or 255), 255),
			g = math.min(tonumber(g or 255), 255),
			b = math.min(tonumber(b or 255), 255),
			a = math.min(tonumber(a or 255), 255)
		}, COLOR)
	end
end

function color.unpack(col)
	return col.r, col.g, col.b, col.a
end

function color.fromHSV(h, s, v, a)
	assert(type(h) == "number", "bad argument #1 to 'fromHSV' (expected number)")
	s = s or 1
	v = v or 1
	a = a or 1

	local r, g, b

	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)

	i = i % 6

	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end

	return color(r * 255, g * 255, b * 255, a * 255)
end

function color.fromHSL(h, s, l, a)
	assert(type(h) == "number", "bad argument #1 to 'fromHSL' (expected number)")
	s = s or 1
	l = l or 0.5
	a = a or 1

	if s == 0 then return color(l*255, l*255, l*255, a*255) end

	h = h * 6
	s = math.min(math.max(0, s), 1)
	l = math.min(math.max(0, l), 1)

	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-0.5*c), 0,0,0

	if h < 1		then r,g,b = c,x,0
	elseif h < 2	then r,g,b = x,c,0
	elseif h < 3	then r,g,b = 0,c,x
	elseif h < 4	then r,g,b = 0,x,c
	elseif h < 5	then r,g,b = x,0,c
	else				 r,g,b = c,0,x
	end

	return color((r+m)*255, (g+m)*255, (b+m)*255, a*255)
end

color_blank = color(0, 0, 0, 0)
color_clear = color(0, 0, 0, 0)
color_none = color(0, 0, 0, 0)
color_lightgrey = color(200, 200, 200, 255)
color_grey = color(150, 150, 150, 255)
color_darkgrey = color(75, 75, 75, 255)
color_darkgreyblue = color(80, 85, 100)
color_white = color(255, 255, 255)
color_black = color(0, 0, 0)
color_red = color(237, 28, 36)
color_green = color(34, 177, 76)
color_blue = color(0, 162, 232)
color_darkblue = color(60, 90, 135)
color_entity = color(151, 211, 255)
color_pink = color(255, 128, 128)
color_hotpink = color(255, 105, 180)
color_orange = color(255, 126, 0)
color_purple = color(163, 73, 164)

return color