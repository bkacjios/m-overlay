local core = {}

local abs = math.abs

-- These functions seem to apply to many games

function core.translateAxis(x, y)
	x = x/72
	y = y/72

	local near = 1 - (abs(abs(x) - abs(y))) * 0.72

	local angle = math.atan2(x, y)
	local mag = math.sqrt(x*x + y*y)

	-- Amplify the magnitute when x,y values are headed towards a diagonal
	return x + math.sin(angle) * mag * near * 0.28, y + math.cos(angle) * mag * near * 0.28
end

local min = math.min

function core.translateTriggers(l, r)
	return min(1, l/125), min(1, r/125)
end

return core