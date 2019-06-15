function math.Clamp(num, low, high)
	if num < low then return low end
	if num > high then return high end
	return num
end

function string.CapFirst(str)
	return str:sub(1,1):upper() .. str:sub(2)
end

function string.AddCommas(str)
	str = tostring(str)
    return str:reverse():gsub("(...)", "%1,"):gsub(",$", ""):reverse()
end

function string.NiceNumber(num)
	return string.AddCommas(string.format("%0.0f", num))
end

function string.SingularOrMuliple(str, num)
	local fmt = ("%i %s"):format(num, str)
	return num == 1 and fmt or (fmt .. "s")
end

function string.AOrAn(s)
	return string.match(s, "^h?[AaEeIiOoUu]") and "an" or "a"
end

function string.SecondsToHuman(sec, accuracy)

	local accuracy = accuracy or 2

	local years = sec/31536000
	local yearsRemainder = sec%31536000
	local days = yearsRemainder/86400
	local daysRemainder = sec%86400
	local hours = daysRemainder/3600
	local hourRemainder = (sec - 86400)%3600
	local min = hourRemainder/60
	local sec = sec%60
	
	years = math.floor(years)
	days = math.floor(days)
	hours = math.floor(hours)
	min = math.floor(min)
	sec = math.floor(sec)
	
	local results = {}
	
	if years >= 1 then
		table.insert(results, string.SingularOrMuliple("year", years))
	end
	if days >= 1 then
		table.insert(results, string.SingularOrMuliple("day", days))
	end
	if hours >= 1 then
		table.insert(results, string.SingularOrMuliple("hour", hours))
	end
	if min >= 1 then
		table.insert(results, string.SingularOrMuliple("minute", min))
	end
	if sec >= 1 then
		table.insert(results, string.SingularOrMuliple("second", sec))
	end
	
	local result = {}
	for i=1,accuracy do
		result[ i ] = results[ i ]
	end
	
	return table.concat(result, ", ")
end

function string.EscapeURL(url)
    return string.gsub(url, "([^A-Za-z0-9_])", function(c)
        return string.format("%%%02x", string.byte(c))
    end)
end

function string.UnescapeURL(url)
	return string.gsub(url, "%%(%x%x)", function(hex)
        return string.char(base.tonumber(hex, 16))
    end)
end