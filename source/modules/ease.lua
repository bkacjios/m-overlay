local ease = {}

local abs = math.abs
local cos = math.cos
local exp = math.exp
local sqtr = math.sqrt
local PI = math.pi

function ease.cerp(a,b,t)
	local f=(1-cos(t*PI))*.5
	return a*(1-f)+b*f
end

function ease.lerp(from, to, t)
	return t < 0.5 and from + (to-from)*t or to + (from-to)*(1-t)
end

local lerp = ease.lerp

function ease.elastic(t, times)
 	return (1 - (exp(-12*t) + exp(-6*t) * cos(((times or 6) + 0.5) * PI * t))/2)/0.99999692789382332858
end

function ease.outback(t, param)
	t = 1-t
	return 1-t*t*(t+(t-1)*(param or 1.701540198866824))
end

function ease.inback(t, param)
	return 1-(1-t)^2*(1+t*(param or 3.48050701420725))
end

function ease.calcOutbackParam(h)
	local P = (91.125 * h + 410.0625 * h ^ 2 + 307.546875 * h ^ 3 + 0.5 * sqrt(33215.0625 * h ^ 2 * (h + 1))) ^ (1/3)
	return 2.25 * h + (13.5 * h + 15.1875 * h ^ 2) / P + P / 3
end

-- Slope at centre: 1.5
function ease.sigmoid(t)
	return t*t*(3-t*2)
end

local sigmoid = ease.sigmoid

-- Slope at centre: 1.5708
function ease.sigmoidSinusoidal(t)
  return (1-cos(t*math.pi))/2
end

-- Slope at centre: 2
function ease.sigmoidExp(t)
	local partial = exp((-1)/t)
	return partial/(exp((-1)/(1 - t)) + partial)
end

function ease.sigmoidParam(t, param)
	param = param or 6
	return lerp(t^param, (1-(1-t)^param), t)
end

function ease.sigmoidFast(t)
	-- Slope at the middle: 1.875
	return t^3*(10+t*(-15+t*6))
end

-- Slope at the middle: 2.1875
function ease.sigmoidFaster(t)
	return t^4*(35+t*(-84+t*(70+t*-20)))
end

-- Slope at the middle: m=3.142
function ease.sigmoidFastest(t)
	return t^8*(6435+t*(-40040+t*(108108+t*(-163800+t*(150150+t*(-83160+t*(25740+t*-3432)))))))
end

-- Slope at centre: 2.25 (=1.5^2)
function ease.sigmoidDouble(t)
  return sigmoid(sigmoid(t))
end

function ease.bounce(t)
  -- Adjust the window to grab a better range. Plenty of magic numbers here,
  -- sorry. These were obtained by doing the math for the adjustment.
  t = (1-t*0.999999999)*0.5271666475893665
  return 1-abs(cos(PI/t))*t^2*3.79559296602621
end

return ease