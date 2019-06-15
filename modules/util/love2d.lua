love.graphics.oldSetColor = love.graphics.setColor

-- Love2D changed color values to be 0-1
-- Allow 0-255 values again..
function love.graphics.setColor(r,g,b,a)
	if type(r) == "table" then
		a, b, g, r = r[4] or 255, r[3] or 255, r[2] or 255, r[1] or 255
	else
		r, g, b, a = r or 255, g or 255, b or 255, a or 255
	end
	love.graphics.oldSetColor(r/255,g/255,b/255,a/255)
end

-- Draw an image using width and height in pixels
-- OriginX and OriginY should be between 0 and 1
-- An origin of 0.5, 0.5 would be the center
function love.graphics.easyDraw(obj, x, y, rotation, width, height, originX, originY, ...)
	if not obj then return end

	local objW, objH = obj:getWidth(), obj:getHeight()

	rotation = rotation or 0
	width = width or objW
	height = height or objH
	originX = originX or 0
	originY = originY or 0

	local scaledW = width / objW
	local scaledH = height / objH
	love.graphics.draw(obj, x, y, r, scaledW, scaledH, objW * originX, objH * originY, ...)
end

--applies a transformation that maps 
--  0,0 => ox, oy
--  1,0 => xx, xy
--  0,1 => yx, yy
-- via love.graphics.translate, .rotate and .scale

local sqrt = math.sqrt
local atan2 = math.atan2
local acos = math.acos
local tan = math.tan
local cos = math.cos
local sin = math.sin

function love.graphics.transform(ox, oy, xx, xy, yx, yy)
	local ex, ey, fx,fy = xx - ox, xy - oy, yx - ox, yy - oy

	if ex * fy < ey * fx then
		ex, ey, fx, fy = fx, fy, ex, ey
	end

	local e, f = sqrt(ex * ex + ey * ey), sqrt(fx * fx + fy * fy)

	ex, ey = ex / e, ey / e
	fx, fy = fx / f, fy / f

	local desiredOrientation = atan2(ey + fy, ex + fx)
	local desiredAngle = acos(ex * fx + ey * fy) / 2
	local z = tan(desiredAngle)
	local distortion = sqrt((1 + z * z) / 2)

	graphics.translate(ox, oy)
	graphics.rotate(desiredOrientation)
	graphics.scale(1, z)
	graphics.rotate(-math.pi / 4)
	graphics.scale(e / distortion, f / distortion)
end
