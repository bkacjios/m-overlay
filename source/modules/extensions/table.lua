function table.merge(a,b)
	for k,v in pairs(b) do
		if not a[k] then a[k]=v end
	end
	return a
end

function table.clone(a)
	local ret = {}
	for k,v in pairs(a) do
		ret[k] = type(v) == "table" and table.clone(v) or v
	end
	return ret
end

local function reversedipairsiter(t, i)
    i = i - 1
    if i ~= 0 then
        return i, t[i]
    end
end

function reversedipairs(t)
    return reversedipairsiter, t, #t + 1
end

function table.hasValue(tbl, val)
	for key, value in pairs(tbl) do
		if (value == val) then return true, key end
	end
	return false
end

do
	local recursiveTableString
	local stack = {}
	local cache = {}

	local KEY_TYPE_DOT = 1
	local KEY_TYPE_BRACKET = 2

	local function val_to_str(v, name)
		if type(v) == "string" then
			v = string.gsub(v, "\n", "\\n" )
			if string.match(string.gsub(v,"[^'\"]",""), '^"+$') then
				return "'" .. v .. "'"
			end
			return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
		elseif type(v) == "table" then
			return recursiveTableString(v, name)
		else
			return tostring(v)
		end
	end

	local function key_type(k)
		if type(k) == "string" and string.match(k, "^[_%a][_%a%d]*$") then
			return KEY_TYPE_DOT
		else
			return KEY_TYPE_BRACKET
		end
	end

	local function key_to_str(k, name)
		if key_type(k) == KEY_TYPE_DOT then
			return k
		else
			return "[" .. val_to_str(k, name) .. "]"
		end
	end

	local function getStackName()
		local result = ""
		for pos, name in ipairs(stack) do
			if key_type(name) == KEY_TYPE_DOT and pos > 1 then
				result = result .. "." .. key_to_str(name)
			else
				result = result .. key_to_str(name)
			end
		end
		return result
	end

	local function getTabs()
		return string.rep("\t", #stack)
	end

	recursiveTableString = function (tbl, name)
		name = name or "self"

		local result = "{\n"

		if cache[tbl] then
			return cache[tbl]
		end

		table.insert(stack, name)
		cache[tbl] = getStackName()

		for k, v in pairs(tbl) do
			result = result .. getTabs() .. key_to_str(k, k) .. " = " .. val_to_str(v, k) .. "\n"
		end
		table.remove(stack, #stack)

		return result .. getTabs(stack) .. "}"
	end

	function table.tostring(tbl)
		stack = {}
		cache = {}
		return recursiveTableString(tbl)
	end

	function table.print(tbl)
		print(table.tostring(tbl))
	end
end

--[[local test = {
	1, 2, 5,
	["Kappa 1 2 3 \n lul"] = true,
	data = {
		1337.84239,
		test = {
			7, 8, "NINE"
		}
	}
}

table.insert(test.data, test)
test.data.test[3] = test
test[58] = test.data.test

print(table.tostring(test))]]

function table.copy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

function table.concatNumberedList(tbl, sep, oxford)
	if type(tbl) ~= "table" then
		return tostring(tbl)
	end

	local str = ""
	local num = #tbl
	for i=1,num do
		if i < num then
			-- If we aren't at the end of the list, use commas
			-- If we're one before the end of the list, use an oxford comma if we want it
			str = str .. i .. ". " .. tbl[i] .. ((oxford or i < num - 1) and ", " or " ")
		elseif i > 1 then
			-- If we're the last item and we have more than 1 item already..
			-- Seperate using our defined seperator word
			str = str .. (sep or "and") .. " " .. i .. ". " .. tbl[i]
		else
			-- Single item..
			str = i .. ". " .. tbl[i]
		end
	end
	return str
end

function table.concatList(tbl, sep, oxford)
	if type(tbl) ~= "table" then
		return tostring(tbl)
	end

	local str = ""
	local num = #tbl
	for i=1,num do
		if i < num then
			-- If we aren't at the end of the list, use commas
			-- If we're one before the end of the list, use an oxford comma if we want it
			str = str .. tbl[i] .. ((oxford or i < num - 1) and ", " or " ")
		elseif i > 1 then
			-- If we're the last item and we have more than 1 item already..
			-- Seperate using our defined seperator word
			str = str .. (sep or "and") .. " " .. tbl[i]
		else
			-- Single item..
			-- Don't even bother concating the string
			str = tbl[i]
		end
	end
	return str
end

function table.max(tbl)
	local max_key = nil
	local max_value = -math.huge
	for key, value in pairs(tbl) do
		value = assert(tonumber(value), "expected a table full of numbers")
		if value > max_value then
			max_key = key
			max_value = value
		end
	end
	return max_key, max_value
end

function table.min(tbl)
	local min_key = nil
	local min_value = math.huge
	for key, value in pairs(tbl) do
		value = assert(tonumber(value), "expected a table full of numbers")
		if value < min_value then
			min_key = key
			min_value = value
		end
	end
	return min_key, min_value
end

function table.avg(tbl)
	local num = 0
	local total = 0
	for key, value in pairs(tbl) do
		value = assert(tonumber(value), "expected a table full of numbers")
		total = total + value
		num = num + 1
	end
	return total / num
end

function table.sum(tbl)
	local total = 0
	for key, value in pairs(tbl) do
		value = assert(tonumber(value), "expected a table full of numbers")
		total = total + value
	end
	return total
end

function table.keys(tbl)
	local keys = {}
	for k,v in pairs(tbl) do
		table.insert(keys, k)
	end
	return keys
end

function table.random(tbl)
	return tbl[math.random(1, #tbl)]
end

function table.randomkey(tbl)
	local keys = table.keys(tbl)
	return keys[math.random(1, #keys)]
end

function table.randomkeyvalue(tbl)
	local key = table.randomkey(tbl)
	return key, tbl[key]
end

function table.shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end