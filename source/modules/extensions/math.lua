function math.gcd(m, n)
	-- greatest common divisor
	while m ~= 0 do
		m, n = n % m, m
	end
	return n
end

do
	local min = math.min
	local max = math.max

	function math.clamp(num, min, max)
		assert(min <= max, "invalid clamp range") -- optional: debug message
		if num < min then
			num = min
		elseif num > max then
			num = max
		end
		return num
	end
end

do
	local pow = math.pow
	local floor = math.floor

	function math.round(num)
		return num + 0.5 - (num + 0.5) % 1
	end

	function math.roundplaces(num, palces)
		local mult = pow(10, (palces or 0))
		return floor(num * mult + 0.5) / mult
	end
end

do
	local random = math.random

	function math.randomFloat(min, max)
		return min + random() * (max - min)
	end
end

do
	local sin = math.sin

	function math.sinlerp(min, max, t)
		local h = (max - min) / 2
		return min + h + math.sin(t) * h
	end

	local cos = math.cos

	function math.coslerp(min, max, t)
		local h = (max - min) / 2
		return min + h + math.cos(t) * h
	end
end

function math.lerp(a,b,t)
	return (1-t)*a + t*b
end

function math.toTimeUnits(seconds)
	return {
		years = seconds/3.154e7,
		months = seconds/2.628e6,
		weeks = seconds/604800,
		days = seconds/86400,
		hours = seconds/3600,
		minutes = seconds/60,
		seconds = seconds,
		milliseconds = seconds * 1000,
	}
end

do
	local format = string.format

	function math.toMinutesSeconds(num, fmt)
		local m = num / 60
		local s = num % 60
		return format(fmt or "%02d:%02d", m, s)
	end

	function math.toMinSecMS(num, fmt)
		local m = num / 60
		local s = num % 60
		local ms = (num % 1) * 100
		return format(fmt or "%02d:%02d:%02d", m, s, ms % 100)
	end
end

do
	local function weighted_total(tbl)
		local total = 0
		for choice, weight in pairs(tbl) do
			total = total + weight
		end
		return total
	end

	function math.weightedRandom(tbl)
		local threshold = math.random(0, weighted_total(tbl))
		local last_choice
		for choice, weight in pairs(tbl) do
			threshold = threshold - weight
			if threshold <= 0 then return choice end
			last_choice = choice
		end
		return last_choice
	end
end